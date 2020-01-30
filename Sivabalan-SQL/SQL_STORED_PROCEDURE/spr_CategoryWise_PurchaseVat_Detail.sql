Create Procedure spr_CategoryWise_PurchaseVat_Detail
( 
@Category nvarchar(510),
@CategoryGroup nVarchar(2550),
@ProductHierarchy nVarchar(510),
@Category1 nVarchar(2550),
@Vendor nvarchar(2550),
@TaxPercentage nVarchar(2550),
@FromDate datetime,
@ToDate datetime,
@TaxBreakup nvarchar(10),
@TaxCompBreakup nvarchar(10),
@TaxType nVARCHAR(100)
)
As

Declare @taxSuffered decimal(18,6)  
Declare @ProductCode nvarchar(30)
Declare @ValAmount decimal(18,6)  
Declare @VatAmount Decimal(18,6)  
Declare @GAmount Decimal(18,6)
Declare @SQL nvarchar(4000)
Declare @CategoryID Int
Declare @Counter Int

--Variables Included for TaxComp Split-Up  
Declare @taxCode Int
Declare @Locality Int  
Declare @TaxDesc nvarchar(1000)  
Declare @ComponentDesc nvarchar(100)  
Declare @ComponentCode Int  
Declare @CompTaxAmt Decimal(18,6)  
Declare @CompTaxPer Decimal(18,6) 
Declare @temp datetime
Set DATEFormat DMY
set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)
if(@FROMDATE > @temp )
begin
select 0,'This report cannot be generated for GST  period' as Reason
goto GSTOut
 end


if(@TODATE > @temp )
begin
set @TODATE  = @temp 
--goto GSTOut
end



Declare @Delimeter nVarchar(1)
Set @Delimeter = Char(15)

Declare @VoucherPrefix nvarchar(20)  
Declare @AVoucherPrefix nvarchar(20)  

Declare @TaxHead nVarchar(1000)
Declare @TaxCompHead nVarchar(1000)

Create Table #tempItems (CategoryID Int , Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create table #tmpVendor(VendorName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS) 
Create Table #tempCategory (CategoryID Int, Status Int)              
Create table #TempTaxSlab(Tax_Code Int,TDesc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Percentage Decimal(18,6))    

    
Create Table #TaxType -- to filter taxtype 
(    
[TaxTypeId] Int,
[TaxTypeName] varchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS
)
If @TaxType = N'%' or @TaxType = N'ALL'
    Insert Into #TaxType select TaxId, TaxType from tbl_mERP_Taxtype 
ELSE
    Insert Into #TaxType select TaxId, TaxType from tbl_mERP_Taxtype Where TaxType
        In ( Select * from dbo.sp_SplitIn2Rows(@TaxType, @Delimeter))


Exec Sp_GetCGLeafCat_ITC @CategoryGroup, @ProductHierarchy, @CATEGORY

Insert Into #TempItems
select CategoryID,Product_Code from Items where CategoryID in (Select CategoryID from #TempCategory)
   
If @Vendor='%'       
  Insert into #tmpVendor select Vendor_Name from Vendors Union select Warehouse_Name from WareHouse      
Else      
  Insert into #tmpVendor select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter)      

If @TaxBreakup = N'%' or Isnull(@TaxBreakup,'') = ''
	Set @TaxBreakup = N'Yes'  

If @TaxBreakup <> 'No' 
	Set @TaxBreakup = N'Yes'  

If @TaxCompBreakup = N'%' or Isnull(@TaxCompBreakup,'') = ''
  Set @TaxCompBreakup = N'No' 
  
If @TaxCompBreakup <> 'Yes' 
  Set @TaxCompBreakup = N'No'


If @TaxBreakUp = N'Yes'
Begin

  If @TaxPercentage = N'%'    
   Begin
    Insert into #TempTaxSlab 
    select Distinct Tax_Code, Tax_Description, Percentage From Tax
    union 
    select Distinct Tax_Code, Tax_Description, cst_Percentage From Tax
    Union
    select 0,'0%',0  
  End
   Else    
	  Insert into #TempTaxSlab select Tax_Code,Tax_Description, Percentage From Tax 
    Where Percentage in (select * from dbo.sp_SplitIn2Rows(@TaxPercentage, @Delimeter)) 
    or CST_Percentage in (select * from dbo.sp_SplitIn2Rows(@TaxPercentage, @Delimeter)) 

  Create Table #VatTempDetails
  (
    [RowID] Int Identity(1,1),
    [TaxCode] Int,
    [TaxSuffered] Decimal(18,6),
    [Product_Code] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
    [VendorName] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
    [Locality] Int,	
    [BillNo] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
    [DocumentDate] Datetime,
    [InvoiceNo] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
    [GoodsValue] Decimal(18,6), 
    [Discount] Decimal(18,6),
    [GrossAmount] Decimal(18,6),
    [ExemptedValue] Decimal(18,6),
    [NetAmount] Decimal(18,6),
    [TaxAmount] Decimal(18,6),
    [taxType] nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
  )  
  
  Create Table #TaxComponentDetail  
	(  
	[TaxCode] Int, [TaxDesc] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, [CompCode] Int,   
	[CompDesc] nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, [CompPercentage] decimal(18,6),  
	[LSTFlag] Int  
	)  
  
  Create table #tempResults
  (
   [ID] Int,
   [Vendor/Branch Name] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
   [Bill No] nvarchar(110),
   [DocumentDate] Datetime,
   [Invoice No.] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
   [Goods Value] Decimal(18,6),
   [Discount] Decimal(18,6),
   [Gross Amount] Decimal(18,6),
   [ExemptedValue] Decimal(18,6),
   [TaxType] nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
   )

  Create Table #TaxLocality
  (
	 [TaxCode] Int, 
   [Locality] Int
  )

  Create table #AdjRetTaxDetail(AdjustmentID Int, Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,BatchCode Int, TaxCode Int)

   --TaxCode retrieved for PurchaseReturn from BatchProducts  
 
	Insert Into #AdjRetTaxDetail
	Select Distinct ARD.AdjustmentID,ARD.Product_Code, Batch_Products.Batch_Code, 
  Isnull(Batch_Products.GRNTaxID,
    Case when IsNull(Batch_Products.Taxtype, 1) = 1  then 
        (Select max(Isnull(Tax.Tax_Code,0)) from Tax left outer join AdjustmentReturnDetail ARD on ARD.Tax = Tax.Percentage) 
        when IsNull(Batch_Products.Taxtype, 1) = 2 then 
        (Select max(Isnull(Tax.Tax_Code,0)) from Tax left outer join AdjustmentReturnDetail ARD on ARD.Tax = Tax.cst_Percentage) 
    End )
	from Batch_Products,AdjustmentReturnDetail ARD, AdjustmentReturnAbstract ARA, Vendors, #TaxType
	where (Isnull(ARA.Status,0) & 192) = 0
  and ARD.BatchCode = Batch_Products.batch_Code 
    and IsNull(Batch_Products.Taxtype, 1) = #TaxType.TaxTypeId
	and ARA.AdjustmentID = ARD.AdjustmentID
	and ARA.VendorID = Vendors.VendorID
	and ARA.AdjustmentDate between @FromDate and @ToDate
	and ARD.Product_Code = Batch_Products.Product_Code
	and ARD.Product_Code in (Select Product_Code from #TempItems)
	and Vendors.Vendor_Name in (Select VendorName from #TmpVendor)


  Insert Into #TaxComponentDetail  
	select tx.Tax_Code,Tax_Description,tc.TaxComponent_Code,  
	TaxComponent_desc,SP_Percentage,tc.LST_Flag  
	from Tax tx, TaxComponents tc,TaxComponentDetail tcd     
	Where Tx.Tax_Code = TC.Tax_Code  
	and Tc.TaxComponent_Code = Tcd.TaxComponent_Code  
	order by tx.Tax_Code,tcd.TaxComponent_Code  
  
  Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid=N'BILL' 
  Select @AVoucherPrefix=Prefix From VoucherPrefix Where TranID =N'BILL AMENDMENT'

  Insert into #VatTempDetails([TaxCode],[TaxSuffered],[Product_Code],[VendorName],[Locality],[BillNo],[DocumentDate],
			[InvoiceNo],[GoodsValue],[Discount],[GrossAmount],[NetAmount],[TaxAmount],[TaxType])  
  Select BD.TaxCode,BD.TaxSuffered,BD.Product_Code,Vendors.Vendor_Name, #TaxType.TaxTypeId as Locality,  
		Case When BA.DocumentReference Is Null Then
		@VoucherPrefix + Cast(BA.DocumentID as nvarchar)  
		Else  
		@AVoucherPrefix + Cast(BA.DocumentID AS nvarchar)  
		End,  
        BA.BillDate,BA.InvoiceReference,"Goods Value" = Sum(Case BA.DiscountOption 
									When 0 Then Cast(BD.Quantity * OrgPTS as Decimal(18,6))
									Else Cast(BD.Quantity * PurchasePrice as Decimal(18,6)) End),
		"Discount" = Sum((Case BA.DiscountOption 
				When 1 Then (BD.Quantity * PurchasePrice) * (BD.Discount / 100)
				When 2 Then  BD.Discount 
				Else (IsNull(DiscPerunit, 0) * BD.Quantity) + ((BD.Quantity * OrgPTS) * (BD.Discount / 100)) 
				End)
				+
                           -- Overall Discount
				(Case BA.Discount 
				When 0 Then 0 
				Else 
					Case BA.DiscountOption 
					When 1 Then 
					((BD.Quantity * PurchasePrice) - ((BD.Quantity * PurchasePrice) * (BD.Discount / 100))) * (BA.Discount / 100)
					When 2 Then	
					((BD.Quantity * PurchasePrice) - (BD.Discount)) * (BA.Discount / 100)
					Else
					((BD.Quantity * OrgPTS) - (IsNull(DiscPerunit, 0)* BD.Quantity) - ((BD.Quantity * OrgPTS) * (BD.Discount / 100))) * (BA.Discount / 100)
					End
				End)),
				"Gross Amount" = Sum(BD.Amount),
				"Net Amount" = Sum(BD.Amount) + Sum(BD.TaxAmount),
         Sum(BD.TaxAmount), TxzType.TaxType      
  From BillDetail BD, BillAbstract BA, Vendors, tbl_mERP_TaxType TxzType, #TaxType
  Where BA.BillID = BD.BillID
  	and BA.VendorID = Vendors.VendorID  
    and TxzType.TaxID = IsNull(BA.TaxType,1)
    and IsNull(BA.Taxtype, 1) = #TaxType.TaxTypeId
	and Vendors.Vendor_Name in (Select VendorName from #TmpVendor)
	and BD.TaxCode in (Select Tax_Code from #TempTaxSlab)
	and BD.Product_Code in (Select Product_Code from #TempItems)
	and BA.BillDate Between @FromDate and @ToDate
	and (Isnull(BA.Status,0) & 192) = 0  
    and not( [TaxCode] = 0 and [TaxSuffered] = 0 )
  Group by 
	BD.TaxCode,BD.TaxSuffered,BD.Product_Code,Vendors.Vendor_Name,#TaxType.TaxTypeId,BA.DocumentID,BA.DocumentReference,
	BA.BillDate,BA.InvoiceReference, TxzType.TaxType

  Insert into #VatTempDetails
  ([TaxCode],[TaxSuffered],[Product_Code],[VendorName],[Locality],[BillNo],[DocumentDate],
	 [InvoiceNo],[GoodsValue],[Discount],[GrossAmount],[NetAmount],[TaxAmount],[TaxType])  
  Select 
   SD.TaxCode,SD.TaxSuffered,SD.Product_Code,"VendorName" = Warehouse.Warehouse_Name,1,
  "Stock Transfer ID" =  IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),   
	"DocumentDate" = SA.DocumentDate,'',"Goods Value" = sum(SD.Amount), "Discount" = 0,
				 "Gross Amount" = sum(SD.Amount),
				 "Net Amount" = sum(SD.TotalAmount),
         "Tax Amount" = sum(SD.TaxAmount), TxzType.TaxType 	 
  from StockTransferInAbstract SA, StockTransferInDetail SD, WareHouse, tbl_mERP_TaxType TxzType, #TaxType
  Where SA.DocSerial = SD.DocSerial 
      and TxzType.TaxID = IsNull(SA.TaxType,1) 
      and IsNull(SA.Taxtype, 1) = #TaxType.TaxTypeId
	  and Warehouse.WareHouseID = SA.WareHouseID
	  and Warehouse.Warehouse_Name in (Select VendorName from #TmpVendor)
	  and SD.Product_Code in (Select Product_Code from #TempItems)
	  and SD.TaxCode in (Select Tax_Code from #TempTaxSlab)
	  and SA.DocumentDate Between @FromDate and @ToDate
	  and (Isnull(SA.Status,0) & 192) = 0 
      and not( [TaxCode] = 0 and [TaxSuffered] = 0 )
  Group By 
	SD.TaxCode,SD.TaxSuffered,SD.Product_Code,Warehouse.Warehouse_Name,SA.DocPrefix,
	SA.DocumentID,SA.DocumentDate, TxzType.TaxType

  Insert into #VatTempDetails([TaxCode],[TaxSuffered],[Product_Code],[VendorName],[Locality],
  [BillNo],[DocumentDate],
										[InvoiceNo],[GoodsValue],[Discount],[GrossAmount],[NetAmount],[TaxAmount],[TaxType])  
  Select 
	"TaxCode" = (select #AdjRetTaxDetail.TaxCode
          from #AdjRetTaxDetail where #AdjRetTaxDetail.AdjustmentID = ARD.AdjustmentID
          and #AdjRetTaxDetail.Product_Code = ARD.Product_Code and ARD.BatchCode = #AdjRetTaxDetail.BatchCode),
	ARD.Tax, ARD.Product_Code, Vendors.Vendor_Name,#TaxType.TaxTypeId as Locality, 
	(Select Prefix From VoucherPrefix Where Tranid=N'PURCHASE RETURN') + Cast(ARA.DocumentID as varchar), 
	ARA.AdjustmentDate, '',   	
	"Goods Value" = sum(0 - Cast((ARD.Quantity * ARD.Rate)as Decimal(18,6))), 
				 "Discount" = 0,
	 			 "Gross Amount" =  sum(0 - (ARD.Quantity * ARD.Rate)),
         "Net Amount" = sum(0 - (ARD.Total_Value)),
				 sum(0 - (ARD.TaxAmount)), N'' as TaxType
	from  AdjustmentReturnAbstract ARA, AdjustmentReturnDetail ARD, Vendors, Batch_Products BP, #TaxType
	Where ARA.AdjustmentID = ARD.AdjustmentID
    and ARD.BatchCode = BP.batch_Code
    and IsNull(BP.Taxtype, 1) = #TaxType.TaxTypeId
    and ARA.VendorID = Vendors.VendorID
	  and ARD.Tax in (Select Percentage from #TempTaxSlab)
	  and ARD.Product_Code in (Select Product_Code from #TempItems)
	  and Vendors.Vendor_Name in (Select VendorName from #TmpVendor)
	  and ARA.AdjustmentDate Between @FromDate and @ToDate
	  and (Isnull(ARA.Status,0) & 192) = 0
      and not( [TaxCode] = 0 and [TaxSuffered] = 0 )
  Group by 
	ARD.Tax,ARD.Product_Code,Vendors.Vendor_Name,#TaxType.TaxTypeId,ARA.DocumentID,
	ARA.AdjustmentDate,ARD.BatchCode,ARD.AdjustmentID

  Insert Into #TaxLocality
  Select Distinct TaxCode,Locality from #VatTempDetails 

  If @TaxPercentage = '%'
  Delete from #TempTaxSlab
  Where Tax_Code Not in (Select Distinct [TaxCode] from #VatTempDetails)

  Delete from #TempTaxSlab Where Tax_Code = 0

  Declare TaxFetch Cursor For
  Select Distinct TaxCode, Case when Locality = 2 then 0 Else 1 End
  From #VatTempDetails where taxsuffered <> 0 order by TaxCode, Case when Locality = 2 then 0 Else 1 End
  Open TaxFetch  
  Fetch next from Taxfetch into @TaxCode,@Locality
  While(@@FETCH_STATUS =0)  
   begin
	Set @TaxHead = dbo.mERP_fn_GetTaxColFormat_Locality(@TaxCode, 0, 0)
    -- Column creation in Intermediate table
    If @Locality = 1 
    begin 
        Set @SQL=N'Alter Table #VatTempDetails Add [T' +  @TaxHead + N' PV] decimal(18,6) ;'  
        Set @SQL= @SQL + N'Alter Table #VatTempDetails Add [T' +  @TaxHead  + N' V] decimal(18,6) '  
    end
    Else
    begin
        Set @SQL=N'Alter Table #VatTempDetails Add [CST_T' + @TaxHead + N' PV] decimal(18,6) ;'  
        Set @SQL= @SQL + N'Alter Table #VatTempDetails Add [CST_T' + @TaxHead + N' V] decimal(18,6) '  
    end
    Exec(@SQL)   

    -- Column creation in Result table
    If @Locality = 1 
    begin
        Set @SQL=N'Alter Table #TempResults Add [' + @TaxHead + N' Purchase Value] decimal(18,6) ;'  
        Set @SQL= @SQL + N'Alter Table #TempResults Add [' + @TaxHead + N' Tax Value] decimal(18,6) '  
    end 
    else
    begin
        Set @SQL=N'Alter Table #TempResults Add [CST_' + @TaxHead + N' Purchase Value] decimal(18,6) ;'  
        Set @SQL= @SQL + N'Alter Table #TempResults Add [CST_' + @TaxHead + N' Tax Value] decimal(18,6) '  
    end
    Exec(@SQL)   

   --//Tax Component Split up Column addition Starts //
   If @TaxCompBreakup = N'Yes'       
    Begin
     If exists(select CompCode from #TaxComponentDetail where TaxCode = @TaxCode)  
      Begin 
        Declare ComponentFetch Cursor For  
        select CompCode from #TaxComponentDetail  
        where TaxCode = @TaxCode and LSTFlag = @Locality
        order by CompCode  
   
       Open ComponentFetch  
       Fetch next from Componentfetch into @ComponentCode  
       While(@@FETCH_STATUS = 0)  
        begin
		 Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat_Locality(@TaxCode, @ComponentCode, @Locality)
         If @Locality = 1
             Set @SQL=  N'Alter Table #VatTempDetails Add [CT' + @TaxCompHead + N'] decimal(18,6) '  
         Else
             Set @SQL = N'Alter Table #VatTempDetails Add [CST_CT' + @TaxCompHead + N'] decimal(18,6) '  
         Exec(@SQL) 
 
         -- Column creation in Result table 
         If @Locality = 1
	       Set @SQL=  N'Alter Table #TempResults Add [' + @TaxCompHead + N'] decimal(18,6) '  
         Else   
           Set @SQL = N'Alter Table #TempResults Add [CST_' + @TaxCompHead + N'] decimal(18,6) '  
         Exec(@SQL)  				
         Fetch next from ComponentFetch into @ComponentCode  
        end  
       Close ComponentFetch  
       Deallocate ComponentFetch  
      End  
    End   
   --//Tax Component Split up Column addition Ends //  

    Fetch next from Taxfetch into @TaxCode, @Locality
   End  
  Close TaxFetch  
  Deallocate TaxFetch 
 
  Declare TaxUpdate Cursor For  
  Select RowID, GrossAmount, Product_Code, #VatTempDetails.TaxCode,#VatTempDetails.TaxSuffered,
         Tax.Tax_Description, TaxAmount,Case when Locality = 2 then 0 Else 1 End
  From #VatTempDetails left outer join Tax
  on #VatTempDetails.TaxCode = Tax.Tax_Code
 
  Open TaxUpdate  
  Fetch next from TaxUpdate into @Counter,@GAmount,@ProductCode,@TaxCode,@TaxSuffered,@TaxDesc,@VatAmount,@Locality
  While(@@FETCH_STATUS =0)  
  begin  
  	If (@TaxSuffered=0)    
      Begin  
        Update #VatTempDetails Set [ExemptedValue]= isnull([ExemptedValue],0) + @GAmount   
        Where RowID = @Counter  
      End   
    Else
    Begin
    Set @TaxHead = dbo.mERP_fn_GetTaxColFormat_Locality(@TaxCode, 0, 0)
    If @Locality = 1 
        Set @SQL=N'Update #VatTempDetails Set [T' + @TaxHead + N' PV]= ' + Cast(@GAmount as varchar) +  
        + N', [T' + @TaxHead + N' V]= (' + Cast(@VatAmount as nvarchar) + ')'
        + N' Where [RowID] = ' + Cast(@Counter AS nvarchar)
    Else 
        Set @SQL = N'Update #VatTempDetails Set [CST_T' + @TaxHead + N' PV]= ' + Cast(@GAmount as varchar) +  
        + N', [CST_T' + @TaxHead + N' V]= (' + Cast(@VatAmount as nvarchar) + ')'
        + N' Where [RowID] = ' + Cast(@Counter AS nvarchar)
    exec(@SQL) 
   
    If @TaxCompBreakup = N'Yes'
    Begin
     If exists(select CompCode from #TaxComponentDetail where TaxCode = @TaxCode)
      Begin
        Declare ComponentFetch Cursor For
        select CompCode,CompPercentage
        from #TaxComponentDetail where TaxCode = @TaxCode
        and LSTFlag = @Locality 
        Order by CompCode
  
        Open ComponentFetch
        Fetch next from Componentfetch into @ComponentCode,@CompTaxPer
          While(@@FETCH_STATUS = 0)
           begin
			  Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat_Locality(@TaxCode, @ComponentCode, @Locality )
	          Set @CompTaxAmt = Cast((@VatAmount * ((@CompTaxPer/@TaxSuffered))) as Decimal(18,6)) 
              If @Locality  = 1 
                Set @SQL=N'Update #VatTempDetails Set [CT' + @TaxCompHead + N']= ' + Cast(Isnull(@CompTaxAmt,0) as nvarchar)
	     				+ N' Where RowID ='+ cast(@Counter as nvarchar)
              Else
                Set @SQL=N'Update #VatTempDetails Set [CST_CT' + @TaxCompHead + N']= ' + Cast(Isnull(@CompTaxAmt,0) as nvarchar)
                + N' Where RowID ='+ cast(@Counter as nvarchar)
              exec(@SQL)
	     	Fetch next from Componentfetch into @ComponentCode,@CompTaxPer
           end
        Close ComponentFetch
        Deallocate ComponentFetch
      End
    End
   --//Tax Component Split up for Tax Amount in Purchase Bill Ends //   
   End
   Fetch next from TaxUpdate into @Counter,@GAmount,@ProductCode,@TaxCode,@TaxSuffered,@TaxDesc,@VatAmount,@Locality
  End  
  Close TaxUpdate  
  Deallocate TaxUpdate 

  Set @SQL = N'Alter Table #TempResults add [Net Amount] Decimal(18,6)'
  Exec(@SQL)

  Set @SQL = N'Insert Into #TempResults '
  Set @SQL = @SQL + N'select 1, "Vendor/Branch Name" = VendorName, "Bill No." = [BillNo],"Date" = [DocumentDate],'
  Set @SQL = @SQL + N'"Invoice No." = [InvoiceNo], "Goods Value" = Sum(GoodsValue), "Discount" = Sum(Discount), "Gross Amount" = Sum(GrossAmount),"Exempted Value"= Sum(Isnull(ExemptedValue,0)),"Tax Type" = [TaxType],' 

    Declare TaxFetch Cursor For
    Select Distinct TaxCode, Case when Locality = 2 then 0 Else 1 End
    From #VatTempDetails where taxsuffered <> 0 order by TaxCode, Case when Locality = 2 then 0 Else 1 End

  Open TaxFetch  
	 Fetch next from Taxfetch into @TaxCode, @Locality
	 While(@@FETCH_STATUS =0)  
	  begin
        Set @TaxHead = dbo.mERP_fn_GetTaxColFormat_Locality(@TaxCode, 0, 0)
        If @Locality = 1 
        begin 
            Set @SQL = @SQL + N'"'+ @TaxHead + '"=' + N'Sum (isnull([T' + @TaxHead + N' PV],0)),'
	        Set @SQL = @SQL + N'Sum (isnull([T' + @TaxHead + N' V],0)),'
        end
        else
        begin 
            Set @SQL = @SQL + N'"'+  Cast(@TaxCode as varchar) + '"=' + N'Sum (isnull([CST_T' + @TaxHead + N' PV],0)),'
            Set @SQL = @SQL + N'Sum (isnull([CST_T' + @TaxHead + N' V],0)),'
        end

			 --//Tax Component Split up Column addition Starts //
   		If @TaxCompBreakup = N'Yes'       
    	Begin
     		If exists(select CompCode from #TaxComponentDetail where TaxCode = @TaxCode)  
      		Begin 
	       		Declare ComponentFetch Cursor For  
                select CompCode from #TaxComponentDetail  
                where TaxCode = @TaxCode and LSTFlag = @Locality
                order by CompCode  
   
			      Open ComponentFetch  
			       Fetch next from Componentfetch into @ComponentCode  
			       While(@@FETCH_STATUS = 0)  
			        begin
                    Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat_Locality(@TaxCode, @ComponentCode, @Locality )
                    If @Locality = 1 
			         Set @SQL = @SQL + N'Sum (Isnull([CT' + @TaxCompHead + N'],0)),'   
                    Else
                        Set @SQL = @SQL + N'Sum (Isnull([CST_CT' + @TaxCompHead + N'],0)),'   
			         Fetch next from ComponentFetch into @ComponentCode  
			        end  
			       Close ComponentFetch  
			       Deallocate ComponentFetch  
			      End  
    		 End   
   		--//Tax Component Split up Column addition Ends //  
        Fetch next from Taxfetch into @TaxCode, @Locality
	  End  
	  Close TaxFetch 
	 Deallocate TaxFetch
	
  Set @SQL = @SQL + N'"NetAmount"= Sum(NetAmount) From #VatTempDetails Group by [VendorName], [BillNo], [DocumentDate], [InvoiceNo], [TaxType]' 
  exec(@SQL)

  Set @SQL =N''
  Set @SQL = 'Select * from #tempResults order by [DocumentDate]'
  Exec(@SQL)


  Drop Table #TaxComponentDetail
  Drop Table #AdjRetTaxDetail
  Drop Table #TempResults
  Drop table #VatTempDetails
  Drop Table #TaxLocality

End

Else If @TaxBreakUp = N'No' 
Begin   
     
  If @TaxPercentage = N'%'    
  Begin
    Insert into #TempTaxSlab 
    select Distinct Tax_Code,Tax_Description, Percentage From Tax
    Union
    select 0,'0%',0  
  End
  Else    
		Insert into #TempTaxSlab select Distinct Tax_Code,Tax_Description, Percentage 
    From Tax 
	 	Where Percentage in (select * from dbo.sp_SplitIn2Rows(@TaxPercentage, @Delimeter)) 
   
Create Table #VatTempPurchase
 (
   [RowID] Int Identity(1,1),
   [TaxPercentage] Decimal(18,6),
   [Product_Code] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
   [VendorName] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,	
   [BillNo] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
   [DocumentDate] Datetime,
   [InvoiceNo] nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
   [GoodsValue] Decimal(18,6), 
   [Discount] Decimal(18,6),
   [GrossAmount] Decimal(18,6),
   [NetAmount] Decimal(18,6),
   [TaxAmount] Decimal(18,6)
  )  
 Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid=N'BILL'
 Select @AVoucherPrefix=Prefix From VoucherPrefix Where TranID =N'BILL AMENDMENT'

 Insert Into #VatTempPurchase ([TaxPercentage],[Product_Code],[VendorName],[BillNo],[DocumentDate],
			[InvoiceNo],[GoodsValue],[Discount],[GrossAmount],[NetAmount],[TaxAmount])  
 Select BD.TaxSuffered,BD.Product_Code,Vendors.Vendor_Name,  
          Case When BA.DocumentReference Is Null Then
		    @VoucherPrefix + Cast(BA.DocumentID as nvarchar)  
	       Else  
		    @AVoucherPrefix + Cast(BA.DocumentID AS nvarchar)  
	  End, BA.BillDate,BA.InvoiceReference, "Goods Value" = Sum(Case BA.DiscountOption 
									When 0 Then Cast(BD.Quantity * OrgPTS as Decimal(18,6))
									Else Cast(BD.Quantity * PurchasePrice as Decimal(18,6)) End),
	  "Discount" = Sum((Case BA.DiscountOption 
				When 1 Then (BD.Quantity * PurchasePrice) * (BD.Discount / 100)
				When 2 Then  BD.Discount 
				Else (IsNull(DiscPerunit, 0)* BD.Quantity) + ((BD.Quantity * OrgPTS) * (BD.Discount / 100))
				End)
				+
                           -- Overall Discount
				(Case BA.Discount 
				When 0 Then 0 
				Else 
					Case BA.DiscountOption 
					When 1 Then 
					((BD.Quantity * PurchasePrice) - ((BD.Quantity * PurchasePrice) * (BD.Discount / 100))) * (BA.Discount / 100)
					When 2 Then	
					((BD.Quantity * PurchasePrice) - (BD.Discount)) * (BA.Discount / 100)
					Else
					((BD.Quantity * OrgPTS) - (IsNull(DiscPerunit, 0)* BD.Quantity) - ((BD.Quantity * OrgPTS) * (BD.Discount / 100))) * (BA.Discount / 100)
					End
			   End)), 
				 "Gross Amount" = Sum(BD.Amount),
				 "Net Amount" = Sum(BD.Amount) + Sum(BD.TaxAmount),
         Sum(BD.TaxAmount)      
  From BillDetail BD, BillAbstract BA, Vendors, #TaxType 
  Where BA.BillID = BD.BillID
      and IsNull(BA.Taxtype, 1) = #TaxType.TaxTypeId
	  and BA.VendorID = Vendors.VendorID  
	  and Vendors.Vendor_Name in (Select VendorName from #TmpVendor)
	  and BD.TaxSuffered in (Select Percentage from #TempTaxSlab)
	  and BD.Product_Code in (Select Product_Code from #TempItems)
	  and BA.BillDate Between @FromDate and @ToDate
	  and (Isnull(BA.Status,0) & 192) = 0  
  Group by BD.TaxSuffered,BD.Product_Code,Vendors.Vendor_Name,BA.DocumentID,
					 BA.DocumentReference,BA.BillDate,BA.InvoiceReference
  
  Insert Into #VatTempPurchase ([TaxPercentage],[Product_Code],[VendorName],[BillNo],[DocumentDate],
										[InvoiceNo],[GoodsValue],[Discount],[GrossAmount],[NetAmount],[TaxAmount])  
  Select SD.TaxSuffered, SD.Product_Code, 
         "VendorName" = Warehouse.Warehouse_Name,
				 "Stock Transfer ID" =  IsNull(SA.DocPrefix, N'') + Cast(SA.DocumentID as nVarchar),  
         "DocumentDate" = SA.DocumentDate,'',   
				 "Goods Value" = sum(SD.Amount),
		     "Discount" = 0,
				 "Gross Amount" = sum(SD.Amount),
				 "Net Amount" = sum(SD.TotalAmount),
         "Tax Amount" = sum(SD.TaxAmount) 
	from StockTransferInAbstract SA, StockTransferInDetail SD, WareHouse, #TaxType
	Where SA.DocSerial = SD.DocSerial
      and IsNull(SA.Taxtype, 1) = #TaxType.TaxTypeId
	  and Warehouse.WareHouseID = SA.WareHouseID
	  and Warehouse.Warehouse_Name in (Select VendorName from #TmpVendor)
	  and SD.Product_Code in (Select Product_Code from #TempItems)
	  and SD.TaxSuffered in (Select Percentage from #TempTaxSlab)
	  and SA.DocumentDate Between @FromDate and @ToDate
	  and (Isnull(SA.Status,0) & 192) = 0 
  Group By SD.TaxSuffered, SD.Product_Code,Warehouse.Warehouse_Name,SA.DocPrefix,
					 SA.DocumentID,SA.DocumentDate
  
  Insert Into #VatTempPurchase ([TaxPercentage],[Product_Code],[VendorName],[BillNo],[DocumentDate],
			       [InvoiceNo],[GoodsValue],[Discount],[GrossAmount],[NetAmount],[TaxAmount])  
  Select ARD.Tax, ARD.Product_Code, Vendors.Vendor_Name, 
  (Select Prefix From VoucherPrefix Where Tranid=N'PURCHASE RETURN') + Cast(ARA.DocumentId as varchar), 
  ARA.AdjustmentDate, '',"Goods Value" = sum(0 - Cast((ARD.Quantity * ARD.Rate)as Decimal(18,6))), 
  "Discount" = 0,"Gross Amount" =  sum(0 - (ARD.Quantity * ARD.Rate)),
  "Net Amount" = sum(0 - (ARD.Total_Value)), sum(0 - (ARD.TaxAmount))
  from  AdjustmentReturnAbstract ARA, AdjustmentReturnDetail ARD, Vendors, Batch_Products BP, #TaxType
  Where ARA.AdjustmentID = ARD.AdjustmentID
    and ARD.BatchCode = BP.batch_Code
    and IsNull(BP.Taxtype, 1) = #TaxType.TaxTypeId
	and ARA.VendorID = Vendors.VendorID
	and ARD.Tax in (Select Percentage from #TempTaxSlab)
	and ARD.Product_Code in (Select Product_Code from #TempItems)
	and Vendors.Vendor_Name in (Select VendorName from #TmpVendor)
	and ARA.AdjustmentDate Between @FromDate and @ToDate
	and (Isnull(ARA.Status,0) & 192) = 0
  Group by ARD.Tax,ARD.Product_Code,Vendors.Vendor_Name,ARA.DocumentId,ARA.AdjustmentDate

  
  Select 1,"Vendor/Branch Name" = [VendorName],"Bill No." = [BillNo], "DocumentDate" = [DocumentDate],
	"Invoice No." = [InvoiceNo], "Goods Value" = Sum([GoodsValue]), "Discount" = Sum([Discount]), 
	"Gross Amount" = Sum([GrossAmount]),
	"Total VAT/Tax Amount" = Sum([TaxAmount]),"Net Amount" = Sum([NetAmount]) 
 From #VatTempPurchase
	Group by [VendorName], [BillNo], [DocumentDate], [InvoiceNo]
  Order by [DocumentDate]

  Drop table #VatTempPurchase

 End

 Drop table #tmpVendor
 Drop table #tempCategory
 Drop table #tempTaxSlab
GSTOut:
