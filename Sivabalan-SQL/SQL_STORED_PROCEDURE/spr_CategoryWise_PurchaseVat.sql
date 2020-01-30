Create Procedure spr_CategoryWise_PurchaseVat
(
@CategoryGroup nVarchar(2550),
@ProductHierarchy nVarchar(510),
@Category nVarchar(4000),
@Vendor nvarchar(2550),
@TaxPercentage nVarchar(2550),
@FromDate datetime,
@ToDate datetime, 
@TaxBreakup nvarchar(10),
@TaxCompBreakup nvarchar(10),
@TaxType nVARCHAR(100)
)
As

Declare @taxSuffered Decimal(18,6)  
Declare @ProductCode nvarchar(30)
Declare @ValAmount decimal(18,6)  
Declare @VatAmount Decimal(18,6)  
Declare @GAmount Decimal(18,6)
Declare @SQL varchar(8000)
Declare @CatID Int
Declare @Counter Int
Declare @ContinueA int        
Declare @CategoryID1 int   
Declare @ValidTax Int
Declare @Delimeter nVarchar(1)

--Variables Included for TaxComp Split-Up  
Declare @taxCode Int
Declare @Locality Int  
Declare @TaxDesc nvarchar(1000)  
Declare @ComponentDesc nvarchar(100)  
Declare @ComponentCode Int  
Declare @CompTaxAmt Decimal(18,6)  
Declare @CompTaxPer Decimal(18,6) 

Declare @TaxHead nVarchar(1000)
Declare @TaxCompHead nVarchar(1000)
Declare @temp datetime
Set DATEFormat DMY
set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)
if(@FROMDATE > @temp )
begin
select 0,'This report cannot be generated for GST period' as Reason
goto GSTOut
 end


if(@TODATE > @temp )
begin
set @TODATE  = @temp 
--goto GSTOut
end


  
Set @Delimeter = Char(15)
Set @ContinueA = 1  
Set @ValidTax = 1    

Create table #tmpVendor(VendorName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)                
Create table #TempTaxSlab(Tax_Code Int,TDesc nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,Percentage Decimal(18,6))         

Create table #TempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)    
Create Table #tempItems (CategoryID Int , Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create Table #tempCategory (CategoryID Int ,Status Int)    
Create Table #AdjRetTaxDetail(AdjustmentID Int,Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, BatchCode Int, TaxCode Int)
        
Create Table #temp2 (IDS Int IDENTITY(1, 1), CatID Int)    
Create Table #temp3 (CatID Int, Status Int)    
Create Table #temp4 (LeafID Int, CatID Int, Parent nVarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)  

    
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


  Create table #tempResults
  (
   [ParentCategory] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
   [Category] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
   [Goods Value] Decimal(18,6),
   [Discount] Decimal(18,6),
   [Gross Amount] Decimal(18,6),
   [Exempted Value] Decimal(18,6)
   )


-- Procedure to implement ITC sorting Logic
		Exec sp_CatLevelwise_ItemSorting  

		If @ProductHierarchy = N'%' 
	  Set @ProductHierarchy = (select distinct HierarchyName from ItemHierarchy where HierarchyID = 2)
		  
    Exec Sp_GetCGLeafCat_ITC @CategoryGroup, @ProductHierarchy, @CATEGORY

		Insert Into #TempItems
   	select CategoryID,Product_Code from Items where CategoryID in 
		(Select Distinct CategoryID from #TempCategory)     
     
		 Insert InTo #temp2 
     Select CatID From dbo.fn_GetCatFrmCG_ITC(@CategoryGroup,@ProductHierarchy,@Delimeter)     

		 Declare @Continue2 Int    
		 Declare @Inc Int    
		 Declare @TCat Int    
		 Set @Inc = 1    
		 Set @Continue2 = IsNull((Select Count(*) From #temp2), 0)    
		    
		 While @Inc <= @Continue2    
		 Begin    
		  Insert InTo #temp3 Select CatID, 0 From #temp2 Where IDS = @Inc    
		  Select @TCat = CatID From #temp2 Where IDS = @Inc    
		  While @ContinueA > 0        
		  Begin        
		    Declare Parent Cursor Keyset For        
		    Select CatID From #temp3  Where Status = 0        
		    Open Parent        
		    Fetch From Parent Into @CategoryID1  
		    While @@Fetch_Status = 0        
		    Begin        
		    Insert into #temp3 Select CategoryID, 0 From ItemCategories         
		    Where ParentID = @CategoryID1        
		    If @@RowCount > 0         
		     Update #temp3 Set Status = 1 Where CatID = @CategoryID1        
		    Else           
		     Update #temp3 Set Status = 2 Where CatID = @CategoryID1        
		    
		    Fetch Next From Parent Into @CategoryID1        
		    End   
		    Close Parent        
		    DeAllocate Parent        
		    Select @ContinueA = Count(*) From #temp3 Where Status = 0        
		  End        
		  Delete #temp3 Where Status not in  (0, 2)
		        
		  Insert InTo #temp4 Select CatID, @TCat,   
		  (Select Category_Name From ItemCategories where CategoryID = @TCat) From #temp3    
		  Delete #temp3    
		  Set @ContinueA = 1    
		  Set @Inc = @Inc + 1    
		 End    
   
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

  If @TaxPercentage <> '%'
  Begin
	 If (Select Isnumeric(Replace(@TaxPercentage,char(15),''))) = 0 
   Begin
     Set @ValidTax = 0 
  	 Goto Result
   End 
  End

--TaxCode retrieved for PurchaseReturn from BatchProducts  
Insert Into #AdjRetTaxDetail  
Select Distinct ARD.AdjustmentID, ARD.Product_Code, Batch_Products.Batch_Code,  
Isnull(Batch_Products.GRNTaxID, 
    Case when IsNull(Batch_Products.Taxtype, 1) = 1  then 
        (Select max(Isnull(Tax.Tax_Code,0)) from Tax left outer join AdjustmentReturnDetail ARD  on ARD.Tax = Tax.Percentage) 
        when IsNull(Batch_Products.Taxtype, 1) = 2 then 
        (Select max(Isnull(Tax.Tax_Code,0)) from Tax left outer join AdjustmentReturnDetail ARD  on ARD.Tax = Tax.cst_Percentage) 
    End )
from Batch_Products, AdjustmentReturnDetail ARD,   
AdjustmentReturnAbstract ARA, Vendors, #TmpVendor, #TaxType
where (Isnull(ARA.Status,0) & 192) = 0  
and ARA.AdjustmentID = ARD.AdjustmentID  
and ARD.BatchCode = Batch_Products.batch_Code   
and IsNull(Batch_Products.Taxtype, 1) = #TaxType.TaxTypeId
and ARD.Product_Code = Batch_Products.Product_Code    
and Vendors.Vendor_Name = #TmpVendor.VendorName   
and ARA.VendorID = Vendors.VendorID  
and ARA.AdjustmentDate between @FromDate and @ToDate  



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
	Insert into #TempTaxSlab select Distinct Tax_Code,Tax_Description, Percentage 
    From Tax 
	Where Percentage in (select * from dbo.sp_SplitIn2Rows(@TaxPercentage, @Delimeter)) 
    or CST_Percentage in (select * from dbo.sp_SplitIn2Rows(@TaxPercentage, @Delimeter)) 
 

  Create Table #VatTempDetails
  (
    [RowID] Int Identity(1,1),
    [TaxCode] Int,
	[TaxSuffered] Decimal(18,6),
    [Locality] Int,
    [Product_Code] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
    [GoodsValue] Decimal(18,6),      
    [Discount] Decimal(18,6),
    [GrossAmount] Decimal(18,6),
    [NetAmount] Decimal(18,6),
	[TaxAmount] Decimal(18,6),
    [ExemptedValue] Decimal(18,6)
  )  

  Create Table #TaxLocality
  (
	 [TaxCode] Int, 
   [Locality] Int
  )
 
  Create Table #TaxComponentDetail  
	(  
	[TaxCode] Int, [TaxDesc] nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, [CompCode] Int,   
	[CompDesc] nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, [CompPercentage] decimal(18,6),  
	[LSTFlag] Int  
	)  
 
  
 
	Insert Into #TaxComponentDetail  
	select tx.Tax_Code,Tax_Description,tc.TaxComponent_Code,  
	TaxComponent_desc,SP_Percentage,tc.LST_Flag  
	from Tax tx, TaxComponents tc,TaxComponentDetail tcd     
	Where Tx.Tax_Code = TC.Tax_Code  
	and Tc.TaxComponent_Code = Tcd.TaxComponent_Code  
	order by tx.Tax_Code,tcd.TaxComponent_Code  

  Insert into #VatTempDetails([TaxCode],[TaxSuffered],[Locality],[Product_Code],[GoodsValue],[Discount],[GrossAmount],[NetAmount],[TaxAmount])  
	 Select BD.TaxCode, BD.TaxSuffered, #TaxType.TaxTypeId as Locality, BD.Product_Code, 
				"Goods Value" = Sum(Case BA.DiscountOption 
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
				Sum(BD.TaxAmount)      
  From BillDetail BD, BillAbstract BA, Vendors, #TaxType 
  Where BA.BillID = BD.BillID
  and IsNull(BA.TaxType, 1) = #TaxType.TaxTypeId
  and BA.VendorID = Vendors.VendorID  
  and Vendors.Vendor_Name in (Select VendorName from #TmpVendor)
  and BD.TaxCode in (Select Tax_Code from #TempTaxSlab)
  and BD.Product_Code in (Select Product_Code from #TempItems)
  and BA.BillDate Between @FromDate and @ToDate
  and (Isnull(BA.Status,0) & 192) = 0  
  and not( [TaxCode] = 0 and [TaxSuffered] = 0 )
  group by BD.TaxCode,BD.TaxSuffered,BD.Product_Code,#TaxType.TaxTypeId

  Insert into #VatTempDetails([TaxCode],[TaxSuffered],[Locality],[Product_Code],[GoodsValue],[Discount],[GrossAmount],[NetAmount],[TaxAmount])  
  Select  SD.TaxCode, SD.TaxSuffered, 1, SD.Product_Code, 
				 "Goods Value" = sum(SD.Amount),  
		     "Discount" = 0,
				 "Gross Amount" = sum(SD.Amount),
				 "Net Amount" = sum(SD.TotalAmount),
         "Tax Amount" = sum(SD.TaxAmount) 
	from StockTransferInAbstract SA, StockTransferInDetail SD, WareHouse, #TaxType
	Where SA.DocSerial = SD.DocSerial
  and IsNull(SA.TaxType, 1) = #TaxType.TaxTypeId
  and Warehouse.WareHouseID = SA.WareHouseID
  and Warehouse.Warehouse_Name in (Select VendorName from #TmpVendor)
  and SD.Product_Code in (Select Product_Code from #TempItems)
  and SD.TaxCode in (Select Tax_Code from #TempTaxSlab)
  and SA.DocumentDate Between @FromDate and @ToDate
  and (Isnull(SA.Status,0) & 192) = 0 	
  and not( [TaxCode] = 0 and [TaxSuffered] = 0 )
  Group By SD.TaxCode,SD.TaxSuffered, SD.Product_Code
 
  Insert into #VatTempDetails([TaxCode],[TaxSuffered],[Locality],[Product_Code],[GoodsValue],[Discount],[GrossAmount],[NetAmount],[TaxAmount])  
  Select "TaxCode" = (select #AdjRetTaxDetail.TaxCode
          from #AdjRetTaxDetail where ARD.AdjustmentID = #AdjRetTaxDetail.AdjustmentID
          and ARD.Product_Code = #AdjRetTaxDetail.Product_Code and #AdjRetTaxDetail.BatchCode = ARD.BatchCode)
         ,ARD.Tax, #TaxType.TaxTypeId as [Locality], ARD.Product_Code,  	
				 "Goods Value" = sum(0 - Cast((ARD.Quantity * ARD.Rate)as Decimal(18,6))), 
				 "Discount" = 0,
	 			 "Gross Amount" =  sum(0 - (ARD.Quantity * ARD.Rate)),
         "Net Amount" = sum(0 - (ARD.Total_Value)),
				 sum(0 - (ARD.TaxAmount))
	from  AdjustmentReturnAbstract ARA, AdjustmentReturnDetail ARD, Vendors, Batch_products BP, #TaxType
	Where ARA.AdjustmentID = ARD.AdjustmentID
	and ARD.Batchcode = BP.Batch_code
	and IsNull(BP.TaxType, 1) = #TaxType.TaxTypeId
	and ARA.VendorID = Vendors.VendorID
  and ARD.Tax in (Select Percentage from #TempTaxSlab)
  and ARD.Product_Code in (Select Product_Code from #TempItems)
  and Vendors.Vendor_Name in (Select VendorName from #TmpVendor)
  and ARA.AdjustmentDate Between @FromDate and @ToDate
  and (Isnull(ARA.Status,0) & 192) = 0
  and not( [TaxCode] = 0 and [TaxSuffered] = 0 )
  Group by ARD.Tax, ARD.Product_Code,#TaxType.TaxTypeId,ARD.AdjustmentID,ARD.BatchCode

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
    Fetch next from Taxfetch into @TaxCode, @Locality
    While(@@FETCH_STATUS =0)
    begin  
        Set @TaxHead = dbo.mERP_fn_GetTaxColFormat_Locality(@TaxCode, 0, 0)
        -- Column creation in Intermediate table
        If @Locality = 1 
        begin 
            Set @SQL=N'Alter Table #VatTempDetails Add [T' + @TaxHead + N' PV] decimal(18,6) ;'  
            Set @SQL= @SQL + N'Alter Table #VatTempDetails Add [T' + @TaxHead + N' V] decimal(18,6) '  
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
                    Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat_Locality(@TaxCode, @ComponentCode, @Locality )
                    If @Locality = 1
                    Set @SQL = N'Alter Table #VatTempDetails Add [CT' + @TaxCompHead + N'] decimal(18,6) '  
                    Else
                    Set @SQL = N'Alter Table #VatTempDetails Add [CST_CT' + @TaxCompHead + N'] decimal(18,6) '  
                    Exec(@SQL) 
     
                    -- Column creation in Result table 
                    If @Locality = 1
                        Set @SQL = N'Alter Table #TempResults Add [' + @TaxCompHead + N'] decimal(18,6) '  
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
    Select RowID, GrossAmount, Product_Code, #VatTempDetails.TaxCode, #VatTempDetails.TaxSuffered, 
    Tax.Tax_Description, TaxAmount, Case when Locality = 2 then 0 Else 1 End
    From #VatTempDetails left outer join Tax
    on #VatTempDetails.TaxCode = Tax.Tax_Code


    Open TaxUpdate  
    Fetch next from TaxUpdate into @Counter, @GAmount, @ProductCode, @TaxCode, @TaxSuffered, @TaxDesc, @VatAmount, @Locality
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
                Set @SQL = N'Update #VatTempDetails Set [T' + @TaxHead + N' PV]= ' + Cast(@GAmount as varchar) +  
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
                    select CompCode, CompPercentage
                    from #TaxComponentDetail where TaxCode = @TaxCode
                    and LSTFlag = @Locality 
                    Order by CompCode
      
                    Open ComponentFetch
                    Fetch next from Componentfetch into @ComponentCode, @CompTaxPer
                    While(@@FETCH_STATUS = 0)
                    begin
                        Set @TaxCompHead = dbo.mERP_fn_GetTaxColFormat_Locality(@TaxCode, @ComponentCode, @Locality )
                        Set @CompTaxAmt = Cast((@VatAmount * ((@CompTaxPer/@TaxSuffered))) as Decimal(18,6)) 
                        If @Locality = 1 
                            Set @SQL=N'Update #VatTempDetails Set [CT' + @TaxCompHead + N']= ' + Cast(Isnull(@CompTaxAmt,0) as nvarchar)
                            + N' Where RowID ='+ cast(@Counter as nvarchar)
                        Else
                            Set @SQL=N'Update #VatTempDetails Set [CST_CT' + @TaxCompHead + N']= ' + Cast(Isnull(@CompTaxAmt,0) as nvarchar)
                            + N' Where RowID ='+ cast(@Counter as nvarchar)
                        exec(@SQL)
                        Fetch next from Componentfetch into @ComponentCode, @CompTaxPer
                    end
                    Close ComponentFetch
                    Deallocate ComponentFetch
                End
            End
            --//Tax Component Split up for Tax Amount in Purchase Bill Ends // 
        End
        Fetch next from TaxUpdate into @Counter,@GAmount,@ProductCode, @TaxCode, @TaxSuffered, @TaxDesc, @VatAmount, @Locality
    End  
    Close TaxUpdate  
    Deallocate TaxUpdate 

 
    Set @SQL = 'Alter Table #VatTempDetails Add CategoryID Int '
    Exec(@SQL)

    Set @SQL = 'Update #VatTempDetails Set CategoryID = #TempItems.CategoryID '
    Set @SQL = @SQL + 'from #TempItems where #TempItems.Product_Code = #VatTempDetails.Product_Code '
    Exec(@SQL)

    Set @SQL = 'Alter Table #temp4 Add IDS Int'
    Exec(@SQL)

    Set @SQL = 'Update #temp4 '
    Set @SQL = @SQL + 'Set #temp4.IDS = #tempCategory1.IDS '
    Set @SQL = @SQL + 'from #Tempcategory1 '
    Set @SQL = @SQL + 'Where #temp4.CatID = #tempCategory1.CategoryID '
    Exec(@SQL)     

    Set @SQL = N'Alter Table #TempResults add [Net Amount] Decimal(18,6)'
    Exec(@SQL)

    Set @SQL = N'Insert Into #TempResults '
    Set @SQL = @SQL + N'select #temp4.Parent, "Category" = #temp4.Parent, "Goods Value" = Sum(GoodsValue), "Discount" = Sum(Discount), "Gross Amount" = Sum(GrossAmount),"Exempted Value"=Sum(Isnull(ExemptedValue,0)),' 
	 
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
            Set @SQL = @SQL + N'"'+  Cast(@TaxCode as varchar) + '"=' + N'Sum (isnull([T' + @TaxHead + N' PV],0)),'
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
    
    Set @SQL = @SQL + '"Net Amount"= Sum(NetAmount) From #VatTempDetails,#temp4 '
    Set @SQL = @SQL + 'Where #VatTempDetails.CategoryID = #temp4.LeafID '
    Set @SQL = @SQL + 'Group by #temp4.Parent, #temp4.IDS ' 
    Set @SQL = @SQL + 'Order by #temp4.IDS '
    Exec(@SQL)

     
    Set @SQL = 'Select * from #TempResults'
    Exec(@SQL)
 
    Drop Table #TaxComponentDetail
    Drop Table #AdjRetTaxDetail
    Drop Table #VatTempDetails
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
	    [TaxPercentage] Decimal(18,6),
	    [Product_Code] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
	    [GoodsValue] Decimal(18,6),      
	    [Discount] Decimal(18,6),
	    [GrossAmount] Decimal(18,6),
	    [NetAmount] Decimal(18,6),
		[TaxAmount] Decimal(18,6)
	)  
	
	  Insert into #VatTempPurchase([TaxPercentage],[Product_Code],[GoodsValue],[Discount],[GrossAmount],[NetAmount],[TaxAmount])  
	  Select BD.TaxSuffered,BD.Product_Code,
					 "Goods Value" = Sum(Case BA.DiscountOption 
									When 0 Then Cast(BD.Quantity * OrgPTS as Decimal(18,6))
									Else Cast(BD.Quantity * PurchasePrice as Decimal(18,6)) End), 
						"Discount" = Sum(Case BA.DiscountOption 
									When 1 Then (BD.Quantity * PurchasePrice) * (BD.Discount / 100)
									When 2 Then  BD.Discount 
									Else (IsNull(DiscPerunit, 0) * BD.Quantity) + ((BD.Quantity * OrgPTS) * (BD.Discount / 100))
									End 
									+
	                           -- Overall Discount
									Case BA.Discount 
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
									End), 
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
	  group by BD.TaxSuffered,BD.Product_Code

	  Insert into #VatTempPurchase([TaxPercentage],[Product_Code],[GoodsValue],[Discount],[GrossAmount],[NetAmount],[TaxAmount])  	
	  Select SD.TaxSuffered, SD.Product_Code, 
					 "Goods Value" = sum(SD.Amount),  
			     "Discount" = 0,
					 "Gross Amount" = sum(SD.Amount),
					 "Net Amount" = sum(SD.TotalAmount),
	         "Tax Amount" = sum(SD.TaxAmount) 
		from StockTransferInAbstract SA, StockTransferInDetail SD, WareHouse, #TaxType
		Where SA.DocSerial = SD.DocSerial
	  and IsNull(SA.TaxType, 1) = #TaxType.TaxTypeId
	  and Warehouse.WareHouseID = SA.WareHouseID
	  and Warehouse.Warehouse_Name in (Select VendorName from #TmpVendor)
	  and SD.Product_Code in (Select Product_Code from #TempItems)
	  and SD.TaxSuffered in (Select Percentage from #TempTaxSlab)
	  and SA.DocumentDate Between @FromDate and @ToDate
	  and (Isnull(SA.Status,0) & 192) = 0 	
	  Group By SD.TaxSuffered, SD.Product_Code		
	  
	  Insert into #VatTempPurchase([TaxPercentage],[Product_Code],[GoodsValue],[Discount],[GrossAmount],[NetAmount],[TaxAmount])  
	  Select ARD.Tax, ARD.Product_Code,  	
					 "Goods Value" = sum(0 - Cast((ARD.Quantity * ARD.Rate)as Decimal(18,6))), 
					 "Discount" = 0,
		 			 "Gross Amount" =  sum(0 - (ARD.Quantity * ARD.Rate)),
	         "Net Amount" = sum(0 - (ARD.Total_Value)),
					 sum(0 -(ARD.TaxAmount))
		from  AdjustmentReturnAbstract ARA, AdjustmentReturnDetail ARD, Vendors, Batch_products BP, #TaxType
		Where ARA.AdjustmentID = ARD.AdjustmentID
		and ARD.Batchcode = BP.Batch_code
		and IsNull(BP.TaxType, 1) = #TaxType.TaxTypeId
		and ARA.VendorID = Vendors.VendorID
	  and ARD.Tax in (Select Percentage from #TempTaxSlab)
	  and ARD.Product_Code in (Select Product_Code from #TempItems)
	  and Vendors.Vendor_Name in (Select VendorName from #TmpVendor)
	  and ARA.AdjustmentDate Between @FromDate and @ToDate
	  and (Isnull(ARA.Status,0) & 192) = 0
	  Group by ARD.Tax,ARD.Product_Code

	  Set @SQL = 'Alter Table #VatTempPurchase Add CategoryID Int '
		Exec(@SQL)
	
		Set @SQL = 'Update #VatTempPurchase Set CategoryID = #TempItems.CategoryID '
		Set @SQL = @SQL + 'from #TempItems where #TempItems.Product_Code = #VatTempPurchase.Product_Code '
		Exec(@SQL)
	
	  Set @SQL = 'Alter Table #temp4 Add IDS Int'
	  Exec(@SQL)
	
	  Set @SQL = 'Update #temp4 '
	  Set @SQL = @SQL + 'Set #temp4.IDS = #tempCategory1.IDS '
	  Set @SQL = @SQL + 'from #Tempcategory1 '
	  Set @SQL = @SQL + 'Where #temp4.CatID = #tempCategory1.CategoryID '
	  Exec(@SQL) 
	  
	 
	  Set @SQL = 'Select #temp4.Parent, "Category" =  #temp4.Parent,' 
	  Set @SQL = @SQL + '"Goods Value" = Sum([GoodsValue]), "Discount" = Sum([Discount]), "Gross Amount" = Sum([GrossAmount]),'
		Set @SQL = @SQL + '"Total VAT/Tax Amount" = Sum([TaxAmount]),"Net Amount" = Sum([NetAmount])'
	  Set @SQL = @SQL + ' From #VatTempPurchase,#temp4'
		Set @SQL = @SQL + ' Where #Temp4.LeafID = #VatTempPurchase.CategoryID'
		Set @SQL = @SQL + ' Group by #temp4.Parent,#temp4.IDS '
	  Set @SQL = @SQL + ' Order by #temp4.IDS '
	
		Exec(@SQL)
	 End
 
 Result:
 If @ValidTax <> 1
 Begin
  Set @SQL = 'Select * from #tempResults'
  Exec(@SQL)
 End

 Drop table #tmpVendor
 Drop table #TempTaxSlab
 Drop table #tempCategory1
 Drop table #tempCategory
 Drop table #tempItems
 Drop table #temp2
 Drop table #temp3
 Drop table #temp4
 Drop table #tempResults
GSTOut:
