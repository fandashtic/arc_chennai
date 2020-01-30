Create Procedure spr_Categorywise_Sales_VAT_Report_Detail_itc(    
       @CID nVarChar(256),    
       @PRODUCT_HIERARCHY nVarchar(4000),     
       @CATEGORY nVARCHAR(4000),     
       @FromDate DateTime,     
       @ToDate DateTime,  
       @NoCategoryReg nVARCHAR(20),  
       @NoShowTaxComp nVARCHAR(10),
       @TaxType nVARCHAR(100) = '%'
)AS   
  
Declare @Delimeter as Char(1)          
Set @Delimeter=Char(15)          
    
Declare @CaID Int    
Declare @rurvar nvarchar(255)    
Declare @RgID Int    
Declare @Cix Int    
Declare @Continue int        
Declare @CategoryID int        
Declare @VTC Int    
Declare @Counter Int    
Declare @RPColumns nVarChar(4000)    
Declare @RPColumns1 nVarChar(4000)    
Declare @RPColumns2 nVarChar(4000)    
Declare @DyColName Varchar(500)  
Declare @ShowTaxComp nVarchar(10)  
Declare @Cnt as int  
Declare @Param1 nvarchar(25)  
Declare @AbsParamTab Table (AbsParam Varchar(50)) 
--Declare @temp datetime
Set DATEFormat DMY
--set @temp = (select dateadd(s,-1,Dbo.StripdateFromtime(Isnull(GSTDateEnabled,0)))GSTDateEnabled from Setup)


--if(@FROMDATE > @temp )
--begin
--select 0,'This report cannot be generated for GST period' as Reason
--goto GSTOut
-- end


--if(@TODATE > @temp )
--begin
--set @TODATE  = @temp 
----goto GSTOut
--end
 
    
Set @Continue = 1        
Set @Counter = 1    
  
Insert into @AbsParamTab Select * from dbo.sp_SplitIn2Rows(@CID, @Delimeter)   
Declare  DetailInput Cursor For  
Select * from @AbsParamTab  
Open DetailInput  
SEt @Cnt = 1   
Fetch From DetailInput Into @Param1  
While @@Fetch_Status = 0   
Begin  
  IF @Cnt = 1  
    set @CaID = @Param1  
  IF @Cnt = 2  
    set @rurvar = @Param1  
  IF @Cnt = 3  
    set @ShowTaxComp = @Param1  
  Fetch Next From DetailInput Into @Param1  
SET @Cnt = @Cnt + 1   
End  
Close DetailInput  
Deallocate DetailInput  
    
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

-- get all the Sales for the given taxtype filter
select InvoiceId --, [taxtype], [taxtypename] 
Into #InvoiceTaxType from (
    select InvoiceId, ( Case when cstpayable > 0 then 'CST' Else 'LST' End) [taxtype] 
    from (
        select Ia.InvoiceId, max(Id.stpayable) stpayable, max(Id.cstpayable) cstpayable
        from Invoiceabstract Ia Join InvoiceDetail Id on Ia.InvoiceId = Id.InvoiceId 
        where Ia.InvoiceDate Between @FromDate And @ToDate And Ia.Status & 192 = 0       
        And Ia.InvoiceType In (1, 3, 4)       
        group by Ia.InvoiceId ) tmp 
    ) Idtmp
Join #TaxType tmp on Idtmp.[TaxType] = tmp.[TaxTypeName]

Select IA.* Into #tmpInvAbs From InvoiceAbstract IA
Join #InvoiceTaxType IAA On IAA.InvoiceID  = IA.InvoiceID  
Where IA.InvoiceType in (1,3,4) And IA.Status & 192 = 0
And IA.InvoiceDate Between @FromDate And @ToDate 

Select InvoiceID=ID.InvoiceID, Serial = ID.Serial , 
	Product_Code=Max(ID.Product_Code), Quantity=Sum(ID.Quantity), SalePrice=MAX(ID.SalePrice), FlagWord = MAX(ID.FlagWord), Amount = MAX(ID.Amount),
	TaxID = MAX(ID.TaxID) , TaxCode=MAX(ID.TaxCode), TaxCode2=MAX(ID.TaxCode2),STPayable= Max(ID.STPayable), CSTPayable = MAX(ID.CSTPayable ),
	DiscountValue=MAX(ID.DiscountValue), SCHEMEDISCAMOUNT = MAX(ID.SCHEMEDISCAMOUNT), SPLCATDISCAMOUNT = MAX(ID.SPLCATDISCAMOUNT)
Into #tmpInvDet 
From InvoiceDetail ID
Join #tmpInvAbs IA On IA.InvoiceID = ID.InvoiceID 
Group By ID.InvoiceID, ID.Serial 
 
--Set @Cix = Charindex(char(15), @CID)    
--Set @CaID = Substring(@CID, 1, @Cix - 1)    
--Set @rurvar = Right(@CID, Len(@CID) - @Cix)   
    
Select @RgID = case @rurvar When 'Unregister' then 1    
       when 'Register' then 2 end    
----------    
Create  Table #CustWiseTaxSum (CustID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, TaxSummary Decimal(18,6))  
Create Table #TempColHeader(TblHeader Varchar(500))    
Create table #tmpCat1(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)    
Create Table #TmpTaxCompSummary (CustID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, t_ProdCode nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, t_Tax_Code Int, t_Tax_Component_Code Int, t_Tax_Percentage Decimal(18,6), t_Tax_Value Decimal(18,6))  
    
Insert into #tmpCat1 select Category_Name from ItemCategories     
Where [Level] = 1 Order By Category_Name    
    
Insert into #tempCategory1 select CategoryID, Category_Name, 0         
From ItemCategories      
Where ItemCategories.Category_Name In (Select Category from #tmpCat1)      
Order By Category_Name    
    
While @Continue > 0        
Begin        
  Declare Parent Cursor Keyset For        
  Select CategoryID From #tempCategory1 Where Status = 0        
  Open Parent        
  Fetch From Parent Into @CategoryID        
  While @@Fetch_Status = 0        
  Begin        
    Insert into #tempCategory1    
    Select CategoryID, Category_Name, 0 From ItemCategories         
    Where ParentID = @CategoryID Order By Category_Name    
    If @@RowCount > 0         
      Update #tempCategory1 Set Status = 1 Where CategoryID = @CategoryID        
    Else        
      Update #tempCategory1 Set Status = 2 Where CategoryID = @CategoryID        
    Fetch Next From Parent Into @CategoryID        
  End        
  Close Parent        
  DeAllocate Parent        
  Select @Continue = Count(*) From #tempCategory1 Where Status = 0        
End        
----------    
  
----------    
Declare @ContinueA int          
Declare @CategoryID1 int          
Set @ContinueA = 1          
    
Create Table #tempCategory (CategoryID Int, Status Int)      
Create Table #tempItem (Product_Code nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)    
Create table #tmpCat(Category nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)            
Create Table #temp2 (IDS Int IDENTITY(1, 1), CatID Int)      
Create Table #temp3 (CatID Int, Status Int)      
Create Table #temp4 (LeafID Int, CatID Int, Parent nVarChar(250) COLLATE SQL_Latin1_General_CP1_CI_AS)      
  
If @PRODUCT_HIERARCHY = N'System SKU' And @CATEGORY = N'%'    
Begin    
  Insert InTo #tempItem Select Product_Code From Items    
  Insert InTo #temp4 Select CategoryID, CategoryID, ProductName From Items    
End    
Else If @PRODUCT_HIERARCHY = N'System SKU' And @CATEGORY <> N'%'    
Begin    
  Insert InTo #tempItem Select * From dbo.sp_SplitIn2Rows(@CATEGORY, @Delimeter)        
  Insert InTo #temp4 Select CategoryID, CategoryID, ProductName From Items    
  Where Product_Code In (Select * From dbo.sp_SplitIn2Rows(@CATEGORY, @Delimeter))    
End    
Else If @PRODUCT_HIERARCHY <> N'System SKU'    
Begin    
  If @Category = N'%' And @Product_Hierarchy = N'%'      
  Begin      
    Insert into #tmpCat select Category_Name from ItemCategories Where [level] = 1      
  End      
  Else If @Category = N'%' And @Product_Hierarchy <> N'%'      
  Begin      
    Insert InTo #tmpCat select Category_Name From itemcategories itc, itemhierarchy ith      
    where itc.[level] = ith.hierarchyid and ith.hierarchyname = @Product_Hierarchy      
  End      
  Else            
  Begin      
    Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter)            
  End      
  Exec GetLeafCategories @PRODUCT_HIERARCHY, @CATEGORY       
  Insert InTo #tempItem Select Product_Code From Items     
  Where CategoryID In (Select Distinct CategoryID From #tempCategory )    
  Insert InTo #temp2 Select CategoryID       
  From ItemCategories        
  Where ItemCategories.Category_Name In (Select Category from #tmpCat)        
      
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
End    
----------    
  
----------    
Create Table #TmpVatTax(TID Int Identity(1, 1), TaxType Decimal(18,6), TaxPercent Decimal(18,6), TaxID Int)    
IF @ShowTaxComp = N'NO'    
Begin    
  Insert  Into #TmpVatTax   
  Select Distinct Tax = (IDE.TaxCode * (Select Case LSTPartOFF When 0 then 0 Else LSTPartOFF/100 End From Tax Where Tax_Code = IDE.TaxID ))+ (IDE.TaxCode2 * (Select Case CSTPartOFF When 0 then 0 Else CSTPartOFF/100 End From Tax 
  Where Tax_Code = IDE.TaxID)), (IDE.TaxCode + IDE.TaxCode2), 0 as TaxID    
  From #tmpInvAbs IA, #tmpInvDet IDE,Items ITS, #InvoiceTaxType 
   Where   IA.InvoiceID = IDE.InvoiceID       
   And ia.InvoiceID = #InvoiceTaxType.InvoiceID
   And IA.InvoiceDate Between @FromDate And @ToDate       
   And IA.InvoiceType In (1, 3, 4)       
   And IsNull(IA.Status, 0) & 192 = 0        
   And IDE.Product_Code = ITS.Product_Code          
   And ITS.CategoryID In (Select LeafID From #temp4)    
   Order by IDE.TaxCode + IDE.TaxCode2 
End    
ELSE IF @ShowTaxComp = N'YES'    
Begin      
  Insert  Into #TmpVatTax   
  Select Distinct Tax = (IDE.TaxCode * (Select Case LSTPartOFF When 0 then 0 Else LSTPartOFF/100 End From Tax Where Tax_Code = IDE.TaxID ))+ (IDE.TaxCode2 * (Select Case CSTPartOFF When 0 then 0 Else CSTPartOFF/100 End From Tax 
  Where Tax_Code = IDE.TaxID)), (IDE.TaxCode + IDE.TaxCode2), Case (IDE.TaxCode + IDE.TaxCode2) When 0 then 0 else IDE.TaxID  End
  From #tmpInvAbs IA, #tmpInvDet IDE, Items ITS, #InvoiceTaxType 
  Where IA.InvoiceDate Between @FromDate And @ToDate       
   And IA.InvoiceType In (1, 3, 4)       
   And IsNull(IA.Status, 0) & 192 = 0      
   And IA.InvoiceID = IDE.InvoiceID    
   And ia.InvoiceID = #InvoiceTaxType.InvoiceID
   And ITS.Product_Code = IDE.Product_Code         
   And ITS.CategoryID In (Select LeafID From #temp4)    
   Order by IDE.TaxCode + IDE.TaxCode2 
----------      
  
----------      
  Insert into #TmpTaxCompSummary    
  Select IA.CustomerID, ITC.Product_Code, ITC.Tax_Code, ITC.Tax_Component_Code, ITC.Tax_Percentage, Sum(Case InvoiCeType When 4 then (Tax_Value * -1) Else Tax_Value End)  
  From InvoiceTaxComponents ITC, #tmpInvAbs IA, (Select Distinct InvoiceID, Product_code, TaxID, TaxCode, TaxCode2 From #tmpInvDet  Where (SalePrice <> 0 And FlagWord = 0)) ID, Tax T, #InvoiceTaxType  
  Where IA.InvoiceDate Between @FromDate And @ToDate     
    And IA.Status & 192 = 0     
    And IA.InvoiceType In (1, 3, 4)     
    And IA.InvoiceID = ID.InvoiceID    
    And IA.InvoiceID = ITC.InvoiceID    
    And ia.InvoiceID = #InvoiceTaxType.InvoiceID
    And T.Tax_Code = ID.TaxID  
    And ID.Product_Code In (Select Product_Code From #tempItem)    
    And ITC.Product_Code = ID.Product_Code    
  Group By IA.CustomerID, ITC.Product_Code, ITC.Tax_Code, ITC.Tax_Component_Code, ITC.Tax_Percentage  
End    
  
  Create Table #temp5 (RID Int Identity(1, 1), [Customer ID] nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,     
  [Customer Name] nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,     
  [Billing Address] nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,     
  [TIN No] nVarChar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)    
----------    
    
  Select "RID" = Identity(Int, 1, 1), [Reg],     
  "IDS" = #temp4.CatID,    
  [CustID], [CustName], [BillAdd], [TinNo], "SelCategory" = #temp4.Parent,     
  "LeafCategoryID" = ala.[CategoryID], [Product Code], [Product Name],     
  [VAT Percentage], [Sales], [Sales Return Saleable],    
  [Sales Return Damages], [Net Sales],     
  "Scheme" = [Scheme] + [InvScheme],     
  "Discount" = [Discount] + [TrdDiscount] + [AddlDiscount] - [InvScheme],     
--Changed on 19.12.2008
"Taxable Sales" = isnull(TaxableSales,0) - isnull(SalesReturn,0),    
"Tax Collected" = isnull(Taxcollected,0) - isnull(StPayable,0)   
--Changed on 19.12.2008

--  "Taxable Sales" = [Net Sales] - ([Scheme] + [InvScheme] + [Discount] + [TrdDiscount] + [AddlDiscount] - [InvScheme]),    
--  "Tax Collected" = Case When IsNull([VAT Percentage], 0) = 0 Then Cast(0 As Decimal(18, 6))    
--        Else     
--    (([Net Sales] - ([Scheme] + [InvScheme] + [Discount] + [TrdDiscount] + [AddlDiscount] - [InvScheme])) * IsNull([VAT Percentage], 1)) / 100 End    


  InTo #temp1     
  From     
  (Select "Reg" = Case When IsNull(cus.TIN_Number, '') = '' Then 1 Else 2 End,    
  "CustID" = inva.CustomerID, "CustName" = cus.Company_Name,     
  "BillAdd" = IsNull(cus.BillingAddress, ''),    
  "TinNo" = IsNull(TIN_Number, ''),    
  "CategoryID" = itm.CategoryID,     
  "Product Code" = invd.Product_Code,     
  "Product Name" = itm.productName,    
  "VAT Percentage" = invd.TaxCode + invd.TaxCode2,
  --"VAT Percentage" = Max(invd.TaxCode) + Max(invd.TaxCode2),
--(Max(invd.TaxCode) * (Select Case LSTPartOFF When 0 then 0 Else LSTPartOFF/100 End 
--From Tax Where Tax_Code = invd.TaxID ))+ 
--(Max(invd.TaxCode2) * (Select Case CSTPartOFF When 0 then 0 Else CSTPartOFF/100 End 
--From Tax Where Tax_Code = invd.TaxID)),  
  "Sales" = Sum(Case When inva.InvoiceType <> 4 Then invd.Quantity * invd.SalePrice    
    Else Cast(0 As Decimal(18, 6)) End),     
  "Sales Return Saleable" = Sum(Case When inva.InvoiceType = 4 And inva.Status & 32 = 0     
        Then invd.Quantity * invd.SalePrice    
    Else Cast(0 As Decimal(18, 6)) End),     
  "Sales Return Damages" = Sum(Case When inva.InvoiceType = 4 And inva.Status & 32 = 32    
        Then invd.Quantity * invd.SalePrice    
    Else Cast(0 As Decimal(18, 6)) End),     
  "Net Sales" = Sum(Case When inva.InvoiceType <> 4 Then invd.Quantity * invd.SalePrice    
    Else Cast(0 As Decimal(18, 6)) End) -     
      (Sum(Case When inva.InvoiceType = 4 And inva.Status & 32 = 0     
        Then invd.Quantity * invd.SalePrice    
        Else Cast(0 As Decimal(18, 6)) End) +     
      Sum(Case When inva.InvoiceType = 4 And inva.Status & 32 = 32    
        Then invd.Quantity * invd.SalePrice    
        Else Cast(0 As Decimal(18, 6)) End)    
      ),    
  "Scheme" = Sum(Case When inva.InvoiceType = 4 Then -1 Else 1 End *     
    (IsNull(invd.SCHEMEDISCAMOUNT, 0) + IsNull(invd.SPLCATDISCAMOUNT, 0))),    
  "Discount" = Sum(Case When inva.InvoiceType = 4 Then -1 Else 1 End *     
    (IsNull(invd.DiscountValue, 0) -     
    (IsNull(invd.SCHEMEDISCAMOUNT, 0) + IsNull(invd.SPLCATDISCAMOUNT, 0)))),    
  "InvScheme" = Sum(Case When inva.InvoiceType = 4 Then -1 Else 1 End *     
    ((((invd.Quantity * invd.SalePrice) - IsNull(invd.DiscountValue, 0)) * inva.schemediscountpercentage / 100))),    
  "TrdDiscount" = Sum(Case When inva.InvoiceType = 4 Then -1 Else 1 End *     
    (((invd.Quantity * invd.SalePrice) - IsNull(invd.DiscountValue, 0)) * inva.Discountpercentage / 100)),    
  "AddlDiscount" = Sum(Case When inva.InvoiceType = 4 Then -1 Else 1 End *     
    (((invd.Quantity * invd.SalePrice) - IsNull(invd.DiscountValue, 0)) * inva.AdditionalDiscount / 100))    

	,"TaxableSales"=Sum(case when inva.InvoiceType in(1,3)  then isnull(Amount,0) end) - Sum(case when Cus.Locality=1 and inva.InvoiceType in(1,3) then isnull(STPayable,0) when Cus.Locality=2 and inva.InvoiceType in(1,3) then isnull(CSTPayable,0) end)    
	,"Taxcollected"=Sum(case when Cus.Locality=1 and inva.InvoiceType in(1,3) then isnull(STPayable,0) when Cus.Locality=2 and inva.InvoiceType in(1,3) then isnull(CSTPayable,0) end)    
	,"SalesReturn"=(Sum(case when inva.InvoiceType = 4 then isnull(Amount,0) end) - Sum(case when Cus.Locality=1 and inva.InvoiceType = 4 then isnull(STPayable,0) when Cus.Locality=2 and inva.InvoiceType = 4 then isnull(CSTPayable,0) end))    
	,"StPayable"= Sum(case when Cus.Locality=1 and inva.InvoiceType = 4 then isnull(STPayable,0) end)    

  From #tmpInvDet invd, #tmpInvAbs inva, Items itm, Customer cus, #InvoiceTaxType
  Where inva.InvoiceID = invd.InvoiceID And invd.Product_Code = itm.Product_Code   
    And inva.InvoiceID = #InvoiceTaxType.InvoiceID
    And cus.CustomerID = inva.CustomerID   
    And inva.InvoiceDate Between @FromDate And @ToDate   
    And inva.Status & 192 = 0   
    And inva.InvoiceType In (1, 3, 4)   
    And invd.Product_Code In (Select Product_Code From #tempItem)    
  Group By itm.CategoryID, invd.Product_Code, itm.productName,    
		--invd.TaxId,
	invd.TaxCode + invd.TaxCode2,
	 IsNull(cus.TIN_Number, ''), inva.CustomerID,    
    cus.Company_Name, IsNull(cus.BillingAddress, ''),serial) ala, #temp4 --, #tempcategory1    
    Where ala.[CategoryID] = #temp4.LeafID And #temp4.CatID = @CaID And [Reg] = @RgID And 
( Case when @PRODUCT_HIERARCHY = 'system sku' 
	then #temp4.Parent 
else '' end) = ( Case when @PRODUCT_HIERARCHY = 'system sku' then ala.[product Name] else '' end) 
  -- ala.[CategoryID] = #tempcategory1.CategoryID    
  -- Order By #tempcategory1.IDS, [Product Code]    
    
  Select @VTC = Count(*) From #TmpVatTax    
  Declare @TP Decimal(18, 6)    
  Declare @TP_PartOff Decimal(18,6)  
  Declare @TmpSql As NVarChar(4000)              
  
  Insert InTo #temp5 ([Customer ID], [Customer Name], [Billing Address], [TIN No])     
  Select CustID, CustName, BillAdd, TinNo  From #temp1     
  Group By CustID, CustName, BillAdd, TinNo    
  --Order By IDS    
    
  Declare @Counter1 Int    
  Declare @RWC Int    
  Declare @Char1 nVarChar(256)    
  --Declare @Reg1 Int    
  Declare @Sal1 Decimal(18, 6)    
  Declare @SalRetS1 Decimal(18, 6)    
  Declare @SalRetD1 Decimal(18, 6)    
  Declare @SalSD1 Decimal(18, 6)    
  Declare @SalTS1 Decimal(18, 6)    
  Declare @SalTC1 Decimal(18, 6)    
  -- For Tax Type Split-Up  
  Declare @CompCnt as Int  
  Declare @CompSummaryVal as Decimal(18,6)  
  Declare @RpCol1LSTSplit as nVarchar(1000)  
  Declare @RpCol1CSTSplit as nVarchar(1000)  
  --Declare @TaxPercent as Varchar(10)  
  Declare @TaxPercent as Decimal(18,6)
  Declare @TaxDesc as nvarchar(500)  
  Declare @TaxID as int  
  Declare @TaxCompID as int  
  Declare @MainTaxDesc as nvarchar(1000)  
  Declare @LoopCnt int  
  Set @Counter  = 1   
  Set @RpCol1LSTSplit = ''  
  Set @RpCol1CSTSplit = ''    
    
  Set @Counter  = 1    
  While @Counter <= @VTC    
  Begin    
    Select @TP_PartOff = TaxType, @TP = TaxPercent From #TmpVatTax Where TID = @Counter  
    Select @RWC = Count(*) From #temp5 -- Where [VAT Percentage] = @TP    
    Set @Counter1 = 1    
    -- Select @RWC    
    If Len(IsNull(@RPColumns, '')) + 60 >= 61    
    Begin    
      If (Len(IsNull(@RPColumns1, '')) + 60) >= 4000    
      Begin    
        Set @RPColumns2 = IsNull(@RPColumns2, '') + ', ' + '[' + Cast(@TP As nVarchar) + '% Sales], [' + Cast(@TP As nVarchar) + '% Sales Return Saleable], [' + Cast(@TP As nVarchar) + '% Sales Return Damages], [' + Cast(@TP As nVarchar) + '% Scheme And Discount], [' + Cast(@TP As nVarchar) + '% Taxable Sales], [' + Cast(@TP As nVarchar) + '% Tax Collected]'    
      End    
      Else    
      Begin    
        Set @RPColumns1 = IsNull(@RPColumns1, '') + ', ' + '[' + Cast(@TP As nVarchar) + '% Sales], [' + Cast(@TP As nVarchar) + '% Sales Return Saleable], [' + Cast(@TP As nVarchar) + '% Sales Return Damages], [' + Cast(@TP As nVarchar) + '% Scheme And Discount], [' + Cast(@TP As nVarchar) + '% Taxable Sales], [' + Cast(@TP As nVarchar) + '% Tax Collected]'    
      End    
    End    
    Else    
    Begin    
      Set @RPColumns = IsNull(@RPColumns, '') + ', ' + '[' + Cast(@TP As nVarchar) + '% Sales], [' + Cast(@TP As nVarchar) + '% Sales Return Saleable], [' + Cast(@TP As nVarchar) + '% Sales Return Damages], [' + Cast(@TP As nVarchar) + '% Scheme And Discount], [' + Cast(@TP As nVarchar) + '% Taxable Sales], [' + Cast(@TP As nVarchar) + '% Tax Collected]'    
    End    
      
    -- Skip if Col-Name aleady exists  
    Set @DyColName = '[' + Cast(@TP As nVarchar) + '% Sales]'  
    If Not Exists(Select * From #TempColHeader Where TblHeader = @DyColName)  
    Begin  
      Insert into #TempColHeader Values(@DyColName)  
      Set @TmpSql='Alter Table #temp5 Add [' + Cast(@TP As nVarchar) + '% Sales] Decimal(18, 6) Default(0) Not Null'     
      Exec Sp_ExecuteSQL @TmpSql               
      Set @TmpSql='Alter Table #temp5 Add [' + Cast(@TP As nVarchar) + '% Sales Return Saleable] Decimal(18, 6) Default(0) Not Null'     
      Exec Sp_ExecuteSQL @TmpSql               
      Set @TmpSql='Alter Table #temp5 Add [' + Cast(@TP As nVarchar) + '% Sales Return Damages] Decimal(18, 6) Default(0) Not Null'     
      Exec Sp_ExecuteSQL @TmpSql               
      Set @TmpSql='Alter Table #temp5 Add [' + Cast(@TP As nVarchar) + '% Scheme And Discount] Decimal(18, 6) Default(0) Not Null'     
      Exec Sp_ExecuteSQL @TmpSql               
      Set @TmpSql='Alter Table #temp5 Add [' + Cast(@TP As nVarchar) + '% Taxable Sales] Decimal(18, 6) Default(0) Not Null'     
      Exec Sp_ExecuteSQL @TmpSql               
      Set @TmpSql='Alter Table #temp5 Add [' + Cast(@TP As nVarchar) + '% Tax Collected] Decimal(18, 6) Default(0) Not Null'     
      Exec Sp_ExecuteSQL @TmpSql               
      End  
  
    IF @ShowTaxComp = N'YES'  
    Begin  
        Declare @tblTaxValue Table (ID int Identity(1,1), Col_Desc varchar(1000), tax_ID int, tax_comp_ID int)   
        -- To Add Tax Split-up  
        Set @LoopCnt = 1    
        Set @CompCnt = 0    
      Select @CompCnt = Count(TC.TaxComponent_Code) From Tax T, TaxComponents TC -- , #TmpTaxCompSummary tTCS  
        Where T.Tax_Code = TC.Tax_Code  
        And T.Tax_code = (Select TaxID from #TmpVatTax Where TID = @Counter)  
        And TC.TaxComponent_code in (Select Distinct t_Tax_component_code From #TmpTaxCompSummary)  
        --And TC.TaxComponent_Code = tTCS.TaxComponent_Code And T.Tax_Code = tTCS.Tax_Code   
        IF @CompCnt > 0  
        Begin    
          While  @LoopCnt <= @CompCnt  
          Begin  
        --  FOR LST SPLIT  
          If Exists(Select Tax_Percentage From TaxComponents Where Tax_code = (Select TaxID from #TmpVatTax Where TID = @Counter) And LST_Flag=1)  
          Begin  
            Declare TaxCompo Cursor For  
            Select T.Tax_Code, T.Tax_Description, TC.TaxComponent_Code, TCD.TaxComponent_Desc, tTCS.t_Tax_Percentage    
            From TaxComponents TC, TaxComponentDetail TCD, Tax T, (Select Distinct t_Tax_code, t_Tax_Component_Code, t_Tax_Percentage From #TmpTaxCompSummary) tTCS  
            Where TC.TaxComponent_Code = TCD.TaxComponent_Code   
              And TC.Tax_code = (Select TaxID from #TmpVatTax Where TID = @Counter)   
              And LST_Flag = 1   
              And T.Tax_code = TC.Tax_Code     
              And T.Tax_Code = tTCS.t_Tax_code   
              And TC.TaxComponent_Code = tTCS.t_Tax_Component_Code  
            Open TaxCompo  
            Fetch From TaxCompo into @TaxID, @MainTaxDesc, @TaxCompID, @TaxDesc, @TaxPercent    
              While @@Fetch_Status = 0   
              Begin  
                Set @RpCol1LSTSplit = 'LT ' + convert(varchar,@TaxPercent) + '%_' + @TaxDesc + '_Of_' + @MainTaxDesc  
                If Not Exists(Select * From #TempColHeader Where TblHeader = @RpCol1LSTSplit)    
                Begin    
                  Insert into #TempColHeader Values(@RpCol1LSTSplit)   
                  Set @TmpSql='Alter Table #temp5 Add [' + Cast(@RpCol1LSTSplit As nVarchar(550)) + '] Decimal(18, 6) Default(0) Not Null'     
                  Exec Sp_ExecuteSQL @TmpSql   
                  -- To add the Column name on Select Query   
                  If Len(IsNull(@RPColumns, '')) + 60 >= 61  
                  Begin    
                    If (Len(IsNull(@RPColumns1, '')) + 60) >= 4000    
                    Begin    
                      Set @RPColumns2 = IsNull(@RPColumns2, '') + ', [' + @RpCol1LSTSplit + ']'  
                    End    
                    Else    
                    Begin    
                      Set @RPColumns1 = IsNull(@RPColumns1, '') + ', [' + @RpCol1LSTSplit + ']'  
                    End    
                  End    
                  Else    
                  Begin    
                    Set @RPColumns = IsNull(@RPColumns, '') + ', [' + @RpCol1LSTSplit + ']'  
                  End  
                  -- To get the Sum of Value against the Tax Comp  
                  Insert into @tblTaxValue Values (@RpCol1LSTSplit, @TaxID, @TaxCompID)  
                End  
                Fetch From TaxCompo into @TaxID, @MainTaxDesc, @TaxCompID, @TaxDesc, @TaxPercent  
                Set @LoopCnt = @LoopCnt + 1  
              End  
            Deallocate TaxCompo  
          End   
          -- FOR cst SPLIT  
          If Exists(Select Tax_Percentage From TaxComponents Where Tax_code = (Select TaxID from #TmpVatTax Where TID = @Counter) And LST_Flag=0)  
          Begin  
            Declare TaxCompo Cursor For  
            Select T.Tax_Code, T.Tax_Description, TC.TaxComponent_Code, TCD.TaxComponent_Desc, tTCS.t_Tax_Percentage    
            From TaxComponents TC, TaxComponentDetail TCD, Tax T, (Select Distinct t_Tax_code, t_Tax_Component_Code, t_Tax_Percentage From #TmpTaxCompSummary) tTCS  
            Where TC.TaxComponent_Code = TCD.TaxComponent_Code   
              And TC.Tax_code = (Select TaxID from #TmpVatTax Where TID = @Counter)   
              And LST_Flag = 0   
              And T.Tax_code = TC.Tax_Code     
              And T.Tax_Code = tTCS.t_Tax_code   
              And TC.TaxComponent_Code = tTCS.t_Tax_Component_Code  
            Open TaxCompo  
            Fetch From TaxCompo into @TaxID, @MainTaxDesc, @TaxCompID, @TaxDesc,  @TaxPercent  
                  While @@Fetch_Status  = 0   
                  Begin  
                    Set @RpCol1CSTSplit = 'CT '+ convert(varchar,@TaxPercent) + '%_' + @TaxDesc + '_Of_' + @MainTaxDesc   
                    If Not Exists(Select * From #TempColHeader Where TblHeader = @RpCol1CSTSplit)    
                    Begin    
                      Insert into #TempColHeader Values(@RpCol1CSTSplit)   
             Set @TmpSql='Alter Table #temp5 Add [' + Cast(@RpCol1CSTSplit As nVarchar(550)) + '] Decimal(18, 6) Default(0) Not Null'     
                      Exec Sp_ExecuteSQL @TmpSql   
                      -- To add the Column name on Select Query   
                      If Len(IsNull(@RPColumns, '')) + 60 >= 61  
                      Begin    
                        If (Len(IsNull(@RPColumns1, '')) + 60) >= 4000    
                        Begin    
                          Set @RPColumns2 = IsNull(@RPColumns2, '') + ', [' + @RpCol1CSTSplit + ']'  
                        End    
                        Else    
                        Begin    
                          Set @RPColumns1 = IsNull(@RPColumns1, '') + ', [' + @RpCol1CSTSplit + ']'  
                        End    
                      End    
                      Else    
                      Begin    
            Set @RPColumns = IsNull(@RPColumns, '') + ', [' + @RpCol1CSTSplit + ']'  
                      End  
                      -- To get the Sum of Value against the Tax Comp  
                      Insert into @tblTaxValue Values (@RpCol1CSTSplit, @TaxID, @TaxCompID)  
                    End  
                    Fetch From TaxCompo into @TaxID, @MainTaxDesc, @TaxCompID, @TaxDesc, @TaxPercent  
                    Set @LoopCnt = @LoopCnt + 1   
                  End  
            Deallocate TaxCompo  
          End   
        End  
      End  
    End  
------------  
  
-----------  
    While @Counter1 <= @RWC     
    Begin    
      Select @Char1 = [Customer ID] From #temp5 Where RID = @Counter1    
      Select @Sal1 = Sum([Sales]), @SalRetS1 = Sum([Sales Return Saleable]),    
        @SalRetD1 = Sum([Sales Return Damages]), @SalSD1 = Sum([Scheme] + [Discount]),    
        @SalTS1 = Sum([Taxable Sales]), @SalTC1 = Sum([Tax Collected])    
      From #temp1 Where CustID = @Char1 And [VAT Percentage] = @TP_PartOff  
      
      Set @TmpSql = 'Update #temp5 Set [' + Cast(@TP As nVarchar) + '% Sales] = ' + Cast(@Sal1 As nVarchar) + ',    
      [' + Cast(@TP As nVarchar) + '% Sales Return Saleable] = ' + Cast(@SalRetS1 As nVarChar) + ',    
      [' + Cast(@TP As nVarchar) + '% Sales Return Damages]= ' + Cast(@SalRetD1 As nVarChar) + ',    
      [' + Cast(@TP As nVarchar) + '% Scheme And Discount] = ' + Cast(@SalSD1 As nVarChar) + ',     
      [' + Cast(@TP As nVarchar) + '% Taxable Sales] = ' + Cast(@SalTS1 As nVarChar) + ',    
      [' + Cast(@TP As nVarchar) + '% Tax Collected] = ' + Cast(@SalTC1 As nVarChar) + '     
      Where [RID] = ' + Cast(@Counter1 As nVarChar) + ''    
      
      Exec Sp_ExecuteSQL @TmpSql    
      
      Set @Counter1 = @Counter1 + 1    
    End    
    Set @Counter = @Counter + 1    
  End    
  
IF @ShowTaxComp = N'YES'  
Begin  
    Set @CompCnt = 0   
    Set @LoopCnt = 1   
    Declare @Col_Desc nvarchar(500)  
    Declare @ColSummary Decimal(18,6)  
    Declare @TaxID1 int  
    Declare @TaxCompID1 int  
    Declare @LSTCST_Flag as int  
    Select @CompCnt = Count(*) From @tblTaxValue  
  IF @CompCnt > 0   
  Begin   
    While @LoopCnt <= @CompCnt  
    Begin  
      Delete From #CustWiseTaxSum  
      Select @Col_Desc = Col_Desc , @TaxID1 = Tax_ID, @TaxCompID1 = Tax_Comp_ID, @LSTCST_Flag =TC.LST_Flag From @tblTaxValue tmp, TaxComponents TC Where tmp.ID = @LoopCnt  And tmp.Tax_Comp_ID = TC.taxComponent_Code and tmp.Tax_ID = TC.Tax_COde  
      Insert into #CustWiseTaxSum SELECT t1.CustID, sum(tTCS.t_Tax_Value )  
      FROM #Temp5 t5, #TmpTaxCompSummary tTCS, (select Distinct Reg, CustID, [Product Code] from #Temp1 Where [Vat Percentage] <> 0) t1, Customer C  
      Where t1.[Product Code] = tTCS.t_ProdCode And t5.[Customer ID] = t1.CustID And tTCS.t_Tax_Code = @TaxID1   
      And tTCS.t_Tax_Component_Code = @TaxCompID1  
      And tTCS.CustID = t1.CustID And C.CustomerId = tTCS.CustID  
      And IsNull(C.Locality,0) =  Case @LSTCST_Flag When 1 Then 1 Else 2 End  
      Group by t1.CustID  
      Set @TmpSql = 'Update t5 Set [' + Cast(@Col_Desc As Varchar(550)) + '] = CTS.TaxSummary' +  
                   ' FROM #Temp5 t5, #TmpTaxCompSummary tTCS, #Temp1 t1, #CustWiseTaxSum CTS' +  
                   ' Where t1.[Product Code] = tTCS.t_ProdCode' +  
                   ' And t5.[Customer ID] = t1.CustID And CTS.CustID =t5.[Customer ID] And tTCS.t_Tax_Code = ' + Cast(@TaxID1 as Varchar(10)) +   
                   ' And tTCS.t_Tax_Component_Code = ' + Cast(@TaxCompID1 as Varchar(10)) +  
                   ' And tTCS.CustID =  t1.CustID '  
      Exec sp_ExecuteSQl @TmpSql    
      Set @LoopCnt  = @LoopCnt + 1   
    End   
  End    
End  
  
Alter Table #temp5 Add [Total Gross Sales] Decimal(18, 6) Default(0) Not Null    
Alter Table #temp5 Add [Total Sales Return Saleable] Decimal(18, 6) Default(0) Not Null    
Alter Table #temp5 Add [Total Sales Return Damages] Decimal(18, 6) Default(0) Not Null    
Alter Table #temp5 Add [Total Scheme And Discount] Decimal(18, 6) Default(0) Not Null    
Alter Table #temp5 Add [Total Taxable Sales] Decimal(18, 6) Default(0) Not Null    
Alter Table #temp5 Add [Total Tax Collected] Decimal(18, 6) Default(0) Not Null    
    
Select @RWC = Count(*) From #temp5 -- Where [VAT Percentage] = @TP    
Set @Counter1 = 1    
    
While @RWC >= @Counter1    
Begin    
  Select @Char1 = [Customer ID] From #temp5 Where RID = @Counter1    
  Select @Sal1 = Sum([Sales]), @SalRetS1 = Sum([Sales Return Saleable]),    
    @SalRetD1 = Sum([Sales Return Damages]), @SalSD1 = Sum([Scheme] + [Discount]),    
    @SalTS1 = Sum(Case [Tax Collected] When  0 Then  0 Else [Taxable Sales] End), @SalTC1 = Sum([Tax Collected])    
  From #temp1 Where CustID = @Char1    
      
  Set @TmpSql = 'Update #temp5 Set [Total Gross Sales] = ' + Cast(@Sal1 As nVarchar) + ',    
    [Total Sales Return Saleable] = ' + Cast(@SalRetS1 As nVarChar) + ',    
    [Total Sales Return Damages] = ' + Cast(@SalRetD1 As nVarChar) + ',    
    [Total Scheme And Discount] = ' + Cast(@SalSD1 As nVarChar) + ',     
    [Total Taxable Sales] = ' + Cast(@SalTS1 As nVarChar) + ',    
    [Total Tax Collected] = ' + Cast(@SalTC1 As nVarChar) + '     
    Where [RID] = ' + Cast(@Counter1 As nVarChar) + ''    
    Exec Sp_ExecuteSQL @TmpSql    
    Set @Counter1 = @Counter1 + 1    
End    
    
Set @TmpSql = 'Select RID, [Customer ID], [Customer Name], [Billing Address], [TIN No]    
  ' + IsNull(@RPColumns, '') + IsNull(@RPColumns1, '') + IsNull(@RPColumns2, '') +     
  ', [Total Gross Sales],     
  [Total Scheme And Discount],    
  [Total Taxable Sales], [Total Tax Collected]    
  From #temp5'    
    
-- [Total Sales Return Saleable],  
-- [Total Sales Return Damages],  
    
Exec Sp_ExecuteSQL @TmpSql    
  
Drop Table #tmpCat1    
Drop Table #tempCategory1     
Drop Table #tempCategory    
Drop Table #tempItem     
Drop Table #tmpCat    
Drop Table #temp2    
Drop Table #temp3     
Drop Table #temp4    
Drop Table #TmpVatTax    
Drop Table #temp5    
Drop Table #temp1    
Drop table #TmpTaxCompSummary  
Drop Table #CustWiseTaxSum  
Drop Table #TempColHeader   
 --GSTOut:  
