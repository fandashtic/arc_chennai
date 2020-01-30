CREATE Procedure spr_PurchaseVatReport_New (@Fromdate datetime,@Todate datetime)
As
Declare @Columns varchar(8000)
Declare @taxSuffered decimal(18,6)
Declare @tranid int
Declare @ValAmount decimal(18,6)
Declare @VatAmount Decimal(18,6)
Declare @ItemID nvarchar(30)
Declare @taxid int
Declare @VoucherPrefix nvarchar(20)

Set @vatAmount=0
Set @ValAmount=0
Set @Columns =N''


Create Table #VatTempPurchase([TranID] int,[PurchaseDate] datetime,
[SerialNo] Varchar(30),[DocID] nvarchar(510),[Vendor(or)Branch] nvarchar(100),[TotalValue] Decimal(18,6),
[STIExemptedValue] Decimal(18,6) default(0),[STI(0%Value)] decimal(18,6) default(0))
Create Table #BillTemp(tax decimal(18,6))

Insert into #VatTempPurchase([TranId],[PurchaseDate],[SerialNo],[DocID],[Vendor(or)Branch],[TotalValue])
Select StkIn.DocSerial,StkIn.DocumentDate,StkIn.DocPrefix + Cast(StkIn.DocumentId as varchar),
StkIn.DocPrefix + Cast(StkIn.DocumentId as varchar),WareHouse.WareHouse_Name,StkIn.NetValue From StockTransferInAbstract StkIn,WareHouse
Where StkIn.WareHouseID=WareHouse.WareHouseID	And (StkIn.Status & 192)=0
And Stkin.Documentdate between @Fromdate And @Todate

Declare TaxFetch Cursor For
	Select Distinct(StkIndet.TaxSuffered) From StockTransferIndetail StkIndet,#VatTempPurchase
	Where Isnull(StkInDet.TaxSuffered,0)<>0	And StkIndet.DocSerial=#VatTempPurchase.TranID

Open TaxFetch
Fetch next from Taxfetch into @taxsuffered
	While(@@FETCH_STATUS =0)
	begin
    Set @Columns=N'Alter Table #VatTempPurchase Add [STI(' +  Cast(@taxSuffered as varchar) + N'%Value)] decimal(18,6) default(0) not null;'
    Set @Columns= @Columns + N'Alter Table #VatTempPurchase Add [STI(' +  Cast(@taxSuffered as varchar) + N'%VAT)] decimal(18,6) default(0) not null'
	Exec(@Columns)
	Fetch next from Taxfetch into @taxsuffered
	End
Close TaxFetch
Deallocate TaxFetch

Declare TaxUpdate Cursor For
	Select StkinDet.DocSerial,StkinDet.TotalAmount,StkinDet.taxSuffered,StkinDet.TaxAmount,Items.TaxSuffered  
	From StockTransferIndetail StkinDet,Items,#VatTempPurchase	Where StkinDet.Product_Code=Items.Product_Code
	And StkIndet.DocSerial=#VatTempPurchase.TranID

Open TaxUpdate
Fetch next from TaxUpdate into @Tranid,@ValAmount,@taxSuffered,@VatAmount,@taxid
	While(@@FETCH_STATUS =0)
	begin
	If (@taxSuffered=0)
	begin
		If (@taxid=0)
			Update #VatTempPurchase Set [STIExemptedValue]= [STIExemptedValue] + @ValAmount Where TranID=@Tranid			
		Else				
			Update #VatTempPurchase Set [STI(0%Value)]=[STI(0%Value)] + @ValAmount Where TranID=@Tranid			
	End
	Else
	begin		
		Set @Columns=N'Update #VatTempPurchase Set [STI(' +  Cast(@taxSuffered as varchar) + N'%Value)]=[STI(' +  Cast(@taxSuffered as varchar) + N'%Value)] + ' + Cast(@ValAmount as varchar) 
		+ N', [STI(' +  Cast(@taxSuffered as varchar) + N'%VAT)]=[STI(' +  Cast(@taxSuffered as varchar) + N'%VAT)] + ' + Cast(@VatAmount as varchar)
		+ N' Where TranID='+ cast(@TranID as varchar) 
		execute(@Columns)
	End			
	Fetch next from TaxUpdate into @Tranid,@ValAmount,@taxSuffered,@VatAmount,@taxid
	End
Close TaxUpdate
Deallocate TaxUpdate
Update #VatTempPurchase Set Tranid=0

Alter table #VatTempPurchase Add [ExemptedValue] Decimal(18,6) default(0) not null
Alter table #VatTempPurchase Add [0%Value] decimal(18,6) default(0) not null
Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid=N'BILL'


Insert into #VatTempPurchase([TranId],[PurchaseDate],[SerialNo],[DocID],[Vendor(or)Branch],[TotalValue])
Select BillAb.BillID,BillAb.BillDate, @VoucherPrefix + Cast(BillAb.DocumentId as varchar),
null,Vendors.Vendor_Name,(BillAb.Value+BillAb.taxAmount) From BillAbstract BillAb,Vendors
Where BillAb.VendorId=Vendors.VendorId	And (BillAb.Status & 192)=0
And BillAb.BillDate Between @Fromdate And @Todate

Declare TaxFetch Cursor For
	Select Distinct(Bdet.TaxSuffered) From Billdetail Bdet,#VatTempPurchase
	Where Isnull(Bdet.TaxSuffered,0)<>0	And Bdet.BillID=#VatTempPurchase.TranID

Open TaxFetch
Fetch next from Taxfetch into @taxsuffered
	While(@@FETCH_STATUS =0)
	begin
    Set @Columns=N'Alter Table #VatTempPurchase Add [' +  Cast(@taxSuffered as varchar) + N'%Value] decimal(18,6) default(0) not null;'
    Set @Columns= @Columns + N'Alter Table #VatTempPurchase Add [' +  Cast(@taxSuffered as varchar) + N'%VAT] decimal(18,6) default(0) not null'
	Exec(@Columns)
	Fetch next from Taxfetch into @taxsuffered
	End
Close TaxFetch
Deallocate TaxFetch

Declare TaxUpdate Cursor For
	Select BDet.BillID,BDet.Amount+ BDet.TaxAmount,BDet.taxSuffered,BDet.TaxAmount,Items.TaxSuffered  
	From BillDetail BDet,Items,#VatTempPurchase	Where BDet.Product_Code=Items.Product_Code
	And BDet.BillID=#VatTempPurchase.TranID


Open TaxUpdate
Fetch next from TaxUpdate into @Tranid,@ValAmount,@taxSuffered,@VatAmount,@taxid
	While(@@FETCH_STATUS =0)
	begin
	If (@taxSuffered=0)
	begin
		If (@taxid=0)
		Begin
			Set @Columns = N'Update #VatTempPurchase Set [ExemptedValue]= [ExemptedValue] + ' + Cast(@ValAmount As Varchar) + N' Where TranID=' + Cast(@Tranid As Varchar)
			execute(@Columns)
		End
		Else				
		Begin
			Set @Columns = N'Update #VatTempPurchase Set [0%Value]=[0%Value] + ' + Cast(@ValAmount As Varchar) + N' Where TranID=' + Cast(@Tranid	As Varchar)
			execute(@Columns)
		End
	End
	Else
	begin
		Insert into #BillTemp Values(@taxSuffered)		
		Set @Columns=N'Update #VatTempPurchase Set [' +  Cast(@taxSuffered as varchar) + N'%Value]=[' +  Cast(@taxSuffered as varchar) + N'%Value] + ' + Cast(@ValAmount as varchar) 
		+ N', [' +  Cast(@taxSuffered as varchar) + N'%VAT]=[' +  Cast(@taxSuffered as varchar) + N'%VAT] + ' + Cast(@VatAmount as varchar)
		+ N' Where TranID='+ cast(@TranID as varchar) 
		execute(@Columns)
	End			
	Fetch next from TaxUpdate into @Tranid,@ValAmount,@taxSuffered,@VatAmount,@taxid
	End
Close TaxUpdate
Deallocate TaxUpdate


Update #VatTempPurchase Set Tranid=0
Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid=N'PURCHASE RETURN'

Insert into #VatTempPurchase([TranId],[PurchaseDate],[SerialNo],[DocID],[Vendor(or)Branch],[TotalValue])
Select AdjAb.AdjustmentID,AdjAb.AdjustmentDate, @VoucherPrefix + Cast(AdjAb.DocumentId as varchar),
Reference,Vendors.Vendor_Name,(0-AdjAb.Total_Value) From AdjustmentReturnAbstract AdjAb,Vendors
Where AdjAb.VendorId=Vendors.VendorId	And (ISnull(AdjAb.Status,0) & 192)=0
And AdjAb.Adjustmentdate Between @FromDate And @Todate

 Declare TaxFetch Cursor For
 	Select Distinct(Adjdet.Tax) From AdjustmentReturnDetail Adjdet,#VatTempPurchase
 	Where Isnull(Adjdet.Tax,0)<> 0 And Adjdet.AdjustmentID=#VatTempPurchase.TranID
 	And Adjdet.Tax not in (Select tax From #BillTemp)

 Open TaxFetch
 Fetch next from Taxfetch into @taxsuffered
 	While(@@FETCH_STATUS =0)
 	begin
	   Set @Columns=N'Alter Table #VatTempPurchase Add [' +  Cast(@taxSuffered as varchar) + N'%Value] decimal(18,6) default(0) not null;'	
    Set @Columns= @Columns + N'Alter Table #VatTempPurchase Add [' +  Cast(@taxSuffered as varchar) + N'%VAT] decimal(18,6) default(0) not null'
	Exec(@Columns)
	Fetch next from Taxfetch into @taxsuffered
	End
Close TaxFetch
Deallocate TaxFetch



Declare TaxUpdate Cursor For
	Select AdjDet.AdjustmentID,(0-AdjDet.Total_value),AdjDet.tax,
	(Quantity * Rate)-AdjDet.Total_Value,
	Items.TaxSuffered  
	From AdjustmentReturnDetail AdjDet,Items,#VatTempPurchase	Where AdjDet.Product_Code=Items.Product_Code
	And AdjDet.AdjustmentID=#VatTempPurchase.TranID


Open TaxUpdate
Fetch next from TaxUpdate into @Tranid,@ValAmount,@taxSuffered,@VatAmount,@taxid
	While(@@FETCH_STATUS =0)
	begin
	If (@taxSuffered=0)
	begin
		If (@taxid=0)
		Begin
			Set @Columns = N'Update #VatTempPurchase Set [ExemptedValue]= [ExemptedValue] + ' + Cast(@ValAmount As Varchar) + N' Where TranID=' + Cast(@Tranid As Varchar)
			execute(@Columns)
		End
		Else				
		Begin
			Set @Columns = N'Update #VatTempPurchase Set [0%Value]=[0%Value] + ' + Cast(@ValAmount As Varchar) + N' Where TranID=' + Cast(@Tranid	As Varchar)
			execute(@Columns)
		End
	End
	Else
	begin
		Insert into #BillTemp Values(@taxSuffered)		
		Set @Columns=N'Update #VatTempPurchase Set [' +  Cast(@taxSuffered as varchar) + N'%Value]=[' +  Cast(@taxSuffered as varchar) + N'%Value] + ' + Cast(@ValAmount as varchar) 
		+ N', [' +  Cast(@taxSuffered as varchar) + N'%VAT]=[' +  Cast(@taxSuffered as varchar) + N'%VAT] + ' + Cast(@VatAmount as varchar)
		+ N' Where TranID='+ cast(@TranID as varchar) 
		execute(@Columns)
	End			
	Fetch next from TaxUpdate into @Tranid,@ValAmount,@taxSuffered,@VatAmount,@taxid
	End
Close TaxUpdate
Deallocate TaxUpdate

Select * From #VatTempPurchase
Drop table #VatTempPurchase
Drop table #BillTemp




