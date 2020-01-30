CREATE procedure [dbo].[Spr_list_SKULedger_Detail_ITC](@ItemCode nvarchar(400),@FromDate Datetime,@ToDate DateTime,@ItemCode1 nvarchar(400))  
as 
Begin

declare @FromDate1 as datetime
declare @tmpsql as nvarchar(4000)
declare @prefixSales as nvarchar(255)
declare @prefixDispatch as nvarchar(255)
declare @prefixPurchase as nvarchar(255)
declare @prefixPurchaseReturn as nvarchar(255)
declare @prefixStockAdjustment as nvarchar(255)
declare @prefixStockTransferIn as nvarchar(255)
declare @prefixStockTransferOut as nvarchar(255)
declare @prefixStockDestruction as nvarchar(255)
declare @PhysicalStockReconcilation as nvarchar(255)
declare @cur_ledgerDetail as cursor
declare @cnt as integer
declare @dt as datetime
declare @InvId as nvarchar(255)
declare @custName as nvarchar(2550)
declare @opn as decimal(18,6)
declare @tot as decimal(18,6)
declare @nextDayOpn as decimal(18,6)
declare @opening_Quantity as decimal(18,6)
declare @sal as decimal(18,6)
declare @disposal as decimal(18,6)
declare @close as decimal(18,6)
declare @pur AS DECIMAL(18,6)
declare @sales as decimal(18,6)
declare @StkAdjOthers as nvarchar(50)
declare @StkAdjDamage nvarchar(50)
declare @StkIn as nvarchar(50)
declare @StkOut as nvarchar(50)
Set @StkAdjOthers = dbo.LookupDictionaryItem(N'Stock Adjustment - Others', Default) 
Set @StkAdjDamage = dbo.LookupDictionaryItem(N'Stock Adjustment - Damage', Default) 
Set @StkIn = dbo.LookupDictionaryItem(N'Stock Transfer In', Default) 
Set @StkOut = dbo.LookupDictionaryItem(N'Stock Transfer Out', Default) 
Set @PhysicalStockReconcilation= dbo.LookupDictionaryItem(N'Physical Stock Reconcilation - Saleable',Default)
set dateformat dmy
set @FromDate1=@FromDate

Declare @tmpDetailSales Table(Date DateTime,InvoiceID nvarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS,CustomerName nvarchar(400) COLLATE SQL_Latin1_General_CP1_CI_AS,Opening Decimal(18,6),Purchase Decimal(18,6),Sales Decimal(18,6),Disposals Decimal(18,6),Closing Decimal(18,6))
Select @prefixSales = Prefix From VoucherPrefix Where TranID Like 'INVOICE'
select @prefixDispatch=Prefix From VoucherPrefix Where TranID Like'DISPATCH'
Select @prefixPurchase=Prefix From VoucherPrefix Where TranID like 'GOODS RECEIVED NOTE'
Select @prefixPurchaseReturn=Prefix From VoucherPrefix Where TranID like 'PURCHASE RETURN'
select @prefixStockAdjustment=Prefix From VoucherPrefix Where TranID like 'STOCK ADJUSTMENT'
select @prefixStockTransferIn=Prefix From VoucherPrefix Where TranID like 'STOCK TRANSFER IN'
select @prefixStockTransferOut=Prefix From VoucherPrefix Where TranID like 'STOCK TRANSFER OUT'
select @prefixStockDestruction=Prefix From VoucherPrefix Where TranID like 'STOCK DESTRUCTION'

while @FromDate <= @todate
begin


--insert all purchases
insert Into @tmpDetailSales(Date,InvoiceID,CustomerName,Purchase)
(Select GRNDate,
Case IsNull(DocumentReference,'') When '' Then @prefixPurchase+cast(DocumentID as nvarchar)
Else DocumentReference  End,
Vendor_Name,
sum(ISNULL((IsNull(QuantityReceived, 0) + IsNull(FreeQty, 0) - IsNull(QuantityRejected, 0)),0)) From   
    GRNAbstract ga
	Inner Join GRNDetail gd on ga.GRNID = gd.GRNID
	Left Outer Join Vendors V on ga.VendorID = V.VendorID
	
	Where 
	--ga.GRNID = gd.GRNID And 
	dbo.StripDateFromTime(GRNDate) =@FromDate
    And Product_Code =@itemcode 
	And IsNull(GRNStatus, 0) & 96 = 0 
--And ga.VendorID*=V.VendorID
Group By GRNDate,DocumentID ,DocumentReference,Vendor_Name)
  
--insert into purchase return
insert Into @tmpDetailSales(Date,InvoiceID,CustomerName,Purchase)
(Select AdjustmentDate,
Case Isnull(Reference,'') When '' Then @prefixPurchaseReturn+cast(Documentid as nvarchar)
Else  Reference  End,
Vendor_Name,
Sum((case IsNull(Quantity, 0) when 0 then 0 else -1 *quantity end))
From AdjustmentReturnAbstract ara
Inner Join AdjustmentReturnDetail ard on ara.AdjustmentID = ard.AdjustmentID
Left Outer Join Vendors V on ara.VendorID = V.VendorID
Where 
--ara.AdjustmentID = ard.AdjustmentID And 
DBO.StripDateFromTime(AdjustmentDate)=@FromDate
And IsNull(Status, 0) & 192 = 0 And Product_Code =@itemcode
--And ara.VendorID*=V.VendorID
Group By AdjustmentDate,DocumentId,Reference,Vendor_Name )

--inserts all invoice Details
insert Into @tmpDetailSales(Date,InvoiceID,CustomerName,Sales)
(select 
InvoiceDate,
Case Isnull(DocReference,'') When '' Then @prefixSales+cast(DocumentID AS NVARCHAR)
Else DocReference  End,
Company_Name,
sum(isnull((Case InvoiceType When 4 Then -1 Else 1 End * Quantity),0))
From InvoiceAbstract inv
Inner Join InvoiceDetail invd on inv.InvoiceID = invd.InvoiceID
Left Outer join Customer C  on inv.CustomerID = C.CustomerID
Where 
--inv.InvoiceID = invd.InvoiceID And 
Product_Code = @itemcode And dbo.StripDateFromTime(InvoiceDate) =@FromDate
--And inv.CustomerID*=C.CustomerID
And IsNull(Status, 0) & 192 = 0 
--And (Case InvoiceType When 4 Then IsNull(Status, 0) & 32 Else 0 End = 0)
Group By InvoiceDate,DocumentID,DocReference,Company_Name)

  
--Inserts All Dispatches
insert Into @tmpDetailSales(Date,InvoiceID,CustomerName,Sales)
(SELECT DispatchDate,
Case Isnull(DocRef,'') When '' Then @prefixDispatch+cast(DocumentID as nvarchar)
Else DocRef  End,
Company_Name,
Sum(IsNull(Quantity, 0))
From DispatchAbstract da
Inner Join DispatchDetail dd on da.DispatchID = dd.DispatchID
Left Outer Join Customer C on da.CustomerID = C.CustomerID
Where   
--da.DispatchID = dd.DispatchID And 
dbo.StripDateFromTime(DispatchDate) =@FromDate
--And da.CustomerID*=C.CustomerID
And dd.Product_Code =@itemcode 
And (IsNull(da.Status, 0) & 192 = 0)
Group By DispatchDate,DocumentID,DocRef,Company_Name)


--StockDestruction
-- insert into #tmpDetailSales(Date,InvoiceID,CustomerName,Disposals)
-- (select DocumentDate,cast(voucherPrefix as nvarchar)+cast(SDA.DocumentID as nvarchar),'Stock Destruction',-1*isnull(DestroyQuantity,0)
-- from StockDestructionAbstract SDA,StockDestructionDetail SDD,ClaimsNote CN
-- Where SDA.DocSerial=SDD.DocSerial
-- And dbo.StripDateFromTime(DocumentDate)=@FromDate
-- And SDD.Product_Code=@itemcode
-- And  SDA.ClaimID = CN.ClaimID
-- And CN.Status & 1 <> 0)

--StockAdjustment - Others
insert into @tmpDetailSales(Date,InvoiceID,CustomerName,Disposals)
(SELECT AdjustmentDate,@prefixStockAdjustment+cast(DocumentId as nvarchar),@StkAdjOthers,
(SELECT SUM(isnull(Quantity,0))-SUM(isnull(OldQty,0)) FROM  STOCKADJUSTMENT WHERE SERIALNO=SA.SerialNO and Product_Code = @itemcode)
From STOCKADJUSTMENTABSTRACT SAA,STOCKADJUSTMENT SA  
Where SAA.AdjustmentID=SA.SerialNO  
And dbo.stripDateFromTime(AdjustmentDate)=@FromDate  
And SA.Product_Code=@itemcode  
--And Quantity>0
And IsNull(AdjustmentType,0) = 1
Group By AdjustmentDate,DocumentId,SA.SerialNO)

/*this is for stock conversion In case of conversion there will no change in stock position*/
--StockAdjustment - Damage
--insert into @tmpDetailSales(Date,InvoiceID,CustomerName,Disposals)
--(SELECT AdjustmentDate,@prefixStockAdjustment+cast(DocumentId as nvarchar),@StkAdjDamage,sum(-1*isnull(Quantity,0))
--From STOCKADJUSTMENTABSTRACT SAA,STOCKADJUSTMENT SA
--Where SAA.AdjustmentID=SA.SerialNO
--And dbo.stripDateFromTime(AdjustmentDate)=@FromDate
--And SA.Product_Code=@itemcode
--And Quantity>0 And IsNull(AdjustmentType,0) = 0
--Group By AdjustmentDate,DocumentId,SA.SerialNO)

--StockReconcilation
insert into @tmpDetailSales(Date,InvoiceID,CustomerName,Disposals)
(SELECT AdjustmentDate,@prefixStockAdjustment+cast(DocumentId as nvarchar),@PhysicalStockReconcilation,
(SELECT SUM(isnull(Quantity,0))-SUM(isnull(OldQty,0)) FROM  STOCKADJUSTMENT WHERE SERIALNO=SA.SerialNO and Product_Code = @itemcode)
From STOCKADJUSTMENTABSTRACT SAA,STOCKADJUSTMENT SA
Where SAA.AdjustmentID=SA.SerialNO
And dbo.stripDateFromTime(AdjustmentDate)=@FromDate
And SA.Product_Code=@itemcode
And IsNull(AdjustmentType,0) = 3
Group By AdjustmentDate,DocumentId,SA.SerialNO)

--Stock Transfer Out
insert into @tmpDetailSales(Date,InvoiceID,CustomerName,Disposals)
(SELECT DocumentDate,@prefixStockTransferOut+cast(DocumentID as nvarchar),@StkOut,sum(-1*isnull(Quantity,0)) from stocktransferoutdetail,stocktransferoutabstract            
where StockTransferOutDetail.Product_Code = @itemcode
and stocktransferoutabstract.docserial = stocktransferoutdetail.docserial            
and IsNull(StockTransferOutAbstract.Status, 0) & 192 = 0    
and dbo.StripDateFromTime(DocumentDate)=@FromDate
Group By DocumentDate,DocumentID)
            
--Stock Transfer In
insert into @tmpDetailSales(Date,InvoiceID,CustomerName,Disposals)
(select DocumentDate,@prefixStockTransferIn+cast(DocumentID as nvarchar),@StkIn,sum(isnull(quantity,0))
 from stocktransferindetail,stocktransferinabstract            
 where StockTransferinDetail.Product_Code = @itemcode
 and stocktransferinabstract.docserial = stocktransferindetail.docserial            
 And StockTransferInAbstract.Status & 192 = 0    
 and dbo.StripDateFromTime(DocumentDate)=@FromDate
Group By DocumentDate,DocumentID)            
set @fromdate= dateadd(d,1,@fromdate)
end
--To Update Opening And Closing Stock After Each Transaction
Select [ID] = Identity(Int, 1, 1), Date,InvoiceId,CustomerName,Opening,Purchase,Sales,Disposals,Closing  inTo #tmpDetailSales1 from @tmpDetailSales
set @cnt=1
set @cur_ledgerDetail = cursor for select Date,InvoiceId,CustomerName,Opening,Purchase,Sales,Disposals,Closing from @tmpDetailSales
open @cur_ledgerDetail
fetch next from @cur_ledgerDetail into @dt,@invId,@custName,@opn,@pur,@sal,@disposal,@close
while @@fetch_status=0
begin
if @cnt=1 
begin
set @opening_Quantity=(Select IsNull(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)  
From OpeningDetails Where Product_Code = @itemcode And Opening_Date = @FromDate1)

update #tmpDetailSales1 set opening=@opening_Quantity where ID=@cnt
set @tot=isnull(@opening_Quantity,0)+isnull(@pur,0)-isnull(@sal,0)+isnull(@disposal,0)+isnull(@close,0)

update #tmpDetailSales1 set Closing=@tot where  ID=@cnt
set @nextDayOpn=@tot
set @cnt=@cnt+1
end 
else
begin
update #tmpDetailSales1 set opening=@nextDayOpn where  ID=@cnt
set @tot=isnull(@nextDayOpn,0)+isnull(@pur,0)-isnull(@sal,0)+isnull(@disposal,0)+isnull(@close,0)
update #tmpDetailSales1 set Closing=@tot where  ID=@cnt
set @nextDayOpn=@tot
set @tot=0
set @cnt=@cnt+1
end
fetch next from @cur_ledgerDetail into @dt,@invId,@custName,@opn,@pur,@sal,@disposal,@close
end
close @cur_ledgerDetail
--Select * From #tmpDetailSales1
Select 
"id"=ID,
"Date"=Date,
"Doc No / Invoice No"=InvoiceID,
"Vendor / Customer Name"=[CustomerName],
"Opening"=Opening,
"Receipt"=Purchase,
"Sales"=Sales,
"Other Disposal"=Disposals,
"Closing"=closing
From #tmpDetailSales1

drop table #tmpDetailSales1
end
