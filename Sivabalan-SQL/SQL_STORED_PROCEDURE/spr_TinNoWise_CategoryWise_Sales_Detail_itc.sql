CREATE Procedure spr_TinNoWise_CategoryWise_Sales_Detail_itc  
      (
       @Reg Int,  
       @PRODUCT_HIERARCHY nVarchar(4000),   
       @CATEGORY nVARCHAR(4000),   
       @FromDate DateTime,   
       @ToDate DateTime,
       @RegStatus nVARCHAR(10),
       @TaxCompBrkUp nVARCHAR(10)
      )      
AS  

Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)        
  
Declare @Continue int      
Declare @CategoryID int      
Set @Continue = 1      
  
----------  
Declare @MaxCTDynamicCols int
Declare @MaxLTDynamicCols int
Declare @Col int
Declare @LTColCnt int
Declare @CTColCnt int
Declare @Tax_Code int
Declare @Tax_Code1 int
Declare @SQL nvarchar(4000)
Declare @CompType nvarchar(10)
Declare @CompType1 nvarchar(10)
Declare @DynFields nvarchar(4000)
Declare @TaxCompVal decimal(18,6)  
Declare @TaxCompPer decimal(18,6)  
Declare @SalesValueWithTax decimal(18,6)  
Declare @CatName nvarchar(510)
Declare @TaxPer decimal(18,6)
Declare @LTPrefix nvarchar(10)
Declare @CTPrefix nvarchar(10)
declare @temp datetime 
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


Set @LTPrefix = 'LST '
Set @CTPrefix  = 'CST '

  
Create table #tmpCat1(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Create table #tempCategory1 (IDS Int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)  
Create Table #tempCategory (CategoryID Int, Status Int)    
Create Table #tempItem (Product_Code nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create table #tmpCat(Category nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)          
Create Table #temp2 (IDS Int IDENTITY(1, 1), CatID Int)    
Create Table #temp3 (CatID Int, Status Int)    
Create Table #temp4 (LeafID Int, CatID Int, Parent nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
  
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
  
Declare @ContinueA int        
Declare @CategoryID1 int        
Set @ContinueA = 1        
  
----------  
If @PRODUCT_HIERARCHY = N'System SKU' And @CATEGORY = N'%'  
Begin  
 Insert InTo #tempItem Select Product_Code From Items  
 Insert InTo #temp4 Select CategoryID, CategoryID, ProductName From Items  
End  
Else If @PRODUCT_HIERARCHY = N'System SKU' And @CATEGORY <> N'%'  
Begin  
 Insert InTo #tempItem Select * From dbo.sp_SplitIn2Rows(@CATEGORY,@Delimeter)      
 Insert InTo #temp4 Select CategoryID, CategoryID, ProductName From Items  
 Where Product_Code In (Select * From dbo.sp_SplitIn2Rows(@CATEGORY,@Delimeter))  
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
    Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@CATEGORY,@Delimeter)          
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

if @TaxCompBrkUp <> 'Yes'
Begin


     Select [IDS], [Reg], [Category], [VAT Percentage], [Sales], [Sales Return Salable],   
     [Sales Return Damages], [Scheme], [Discount], [Taxable Sales], [Tax Collected]   
     InTo #temp1 From   
     (  
        Select Top 100 Percent [Reg], [CustID], "IDS" = #temp4.catid,   
               "Category" = #temp4.Parent,   
               ala.[CategoryID], [Product Code], [Product Name],   
               [VAT Percentage], [Sales], [Sales Return Salable],  
               [Sales Return Damages], [Net Sales],   
               "Scheme" = [Scheme] + [InvScheme],   
               "Discount" = [Discount] + [TrdDiscount] + [AddlDiscount] - [InvScheme],   
               "Taxable Sales" = isnull(TaxableSales,0) - isnull(SalesReturn,0),  
               "Tax Collected" = isnull(Taxcollected,0) - isnull(StPayable,0) 
        
        From (
                Select "Reg" = Case When IsNull(cus.TIN_Number, '') = '' Then 1 Else 2 End,  
                       "CustID" = inva.CustomerID, "CategoryID" = itm.CategoryID,   
                       "Product Code" = invd.Product_Code,   
                       "Product Name" = itm.productName,  
                       "VAT Percentage" = invd.TaxCode + invd.TaxCode2,   
                         
                       "Sales" = Sum(Case When inva.InvoiceType <> 4 Then invd.Quantity * invd.SalePrice  
                              Else Cast(0 As Decimal(18, 6)) End),   
                         
                       "Sales Return Salable" = Sum(Case When inva.InvoiceType = 4 And inva.Status & 32 = 0   
                                Then invd.Quantity * invd.SalePrice  
                              Else Cast(0 As Decimal(18, 6)) End),   
                       
                       "Sales Return Damages" = Sum(Case When inva.InvoiceType = 4 And inva.Status & 32 = 32  
                                Then invd.Quantity * invd.SalePrice  
           Else Cast(0 As Decimal(18, 6)) End),   
                       
                       "Net Sales" = Sum(Case When inva.InvoiceType <> 4 Then invd.Quantity * invd.SalePrice  
                              Else Cast(0 As Decimal(18, 6)) End) -   
                       (  Sum(Case When inva.InvoiceType = 4 And inva.Status & 32 = 0   
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
     --                   ,"Taxcollected"=Sum(case when Cus.Locality=1 and inva.InvoiceType in(1,3) then isnull(STPayable,0) + isnull(CSTPayable,0) when Cus.Locality=2 and inva.InvoiceType in(1,3) then isnull(STPayable,0) + isnull(CSTPayable,0) end)  
     
                       ,"SalesReturn"=(Sum(case when inva.InvoiceType = 4 then isnull(Amount,0) end) - Sum(case when Cus.Locality=1 and inva.InvoiceType = 4 then isnull(STPayable,0) when Cus.Locality=2 and inva.InvoiceType = 4 then isnull(CSTPayable,0) end))  
                       ,"StPayable"= Sum(case when Cus.Locality=1 and inva.InvoiceType = 4 then isnull(STPayable,0) end)  
                         
                From InvoiceDetail invd, InvoiceAbstract inva, Items itm, Customer cus  
                Where inva.InvoiceID = invd.InvoiceID And invd.Product_Code = itm.Product_Code And   
                      cus.CustomerID = inva.CustomerID And   
                      inva.InvoiceDate Between   
                      @FromDate And @ToDate And inva.Status & 192 = 0 And   
                      inva.InvoiceType In (1, 3, 4) And invd.Product_Code In (Select Product_Code From #tempItem)  
                Group By itm.CategoryID, invd.Product_Code, itm.productName,  
                      invd.TaxCode, invd.TaxCode2, IsNull(cus.TIN_Number, ''), inva.CustomerID
             ) ala, #temp4, #tempcategory1  
        Where ala.[CategoryID] = #temp4.LeafID And   
              ala.[CategoryID] = #tempcategory1.CategoryID  
        Order By #tempcategory1.IDS, [Product Code]
     ) ala1  


     Select  
      #temp1.[Reg], #temp1.[Category], #temp1.[VAT Percentage], "Sales(%c)" = Sum([Sales]),   
      "Sales Return Saleable(%c)" = Sum([Sales Return Salable]),   
      "Sales Return Damages(%c)" = Sum([Sales Return Damages]),   
      "Scheme(%c)" = Sum([Scheme]), "Discount(%c)" = Sum([Discount]),   
      "Taxable Sales(%c)" = Sum([Taxable Sales]), "Tax Collected(%c)" = Sum([Tax Collected])   
     From #temp1, #tempcategory1 Where #tempcategory1.CategoryID = #temp1.[IDS] And [Reg] = @Reg  
     Group By #temp1.[Reg], #temp1.[Category], #temp1.[VAT Percentage], #temp1.[IDS], #tempcategory1.[IDS]  
     Order By #tempcategory1.[IDS]        
End
Else
Begin

      Select [IDS], [Reg], [Category], [VAT Percentage], [Sales], [ExemptSales], [Sales Return Salable],   
      [Sales Return Damages], [Scheme], [Discount], [Taxable Sales], [Tax Collected], Tax_Description, Tax_Code   
      InTo #tmpData From   
      (  
         Select Top 100 Percent [Reg], [CustID], "IDS" = #temp4.catid,   
                "Category" = #temp4.Parent,   
                ala.[CategoryID], [Product Code], [Product Name],   
                [VAT Percentage], [Sales], [Sales Return Salable],  
                [Sales Return Damages], [Net Sales],   
                case [VAT Percentage] when 0 then [Sales] else 0 end as ExemptSales,
                "Scheme" = [Scheme] + [InvScheme],   
                "Discount" = [Discount] + [TrdDiscount] + [AddlDiscount] - [InvScheme],   
                "Taxable Sales" = isnull(TaxableSales,0) - isnull(SalesReturn,0),  
                "Tax Collected" = isnull(Taxcollected,0) - isnull(StPayable,0),
                Tax_Description, Tax_Code          
         From (
                  Select "Reg" = Case When IsNull(cus.TIN_Number, '') = '' Then 1 Else 2 End,  
                       "CustID" = inva.CustomerID, "CategoryID" = itm.CategoryID,   
                       "Product Code" = invd.Product_Code,   
                       "Product Name" = itm.productName,  
                       "VAT Percentage" = invd.TaxCode + invd.TaxCode2,   
                         
                       "Sales" = Sum(Case When inva.InvoiceType <> 4 Then invd.Quantity * invd.SalePrice  
                              Else Cast(0 As Decimal(18, 6)) End),   
                         
                       "Sales Return Salable" = Sum(Case When inva.InvoiceType = 4 And inva.Status & 32 = 0   
                                Then invd.Quantity * invd.SalePrice  
                              Else Cast(0 As Decimal(18, 6)) End),   
                       
                       "Sales Return Damages" = Sum(Case When inva.InvoiceType = 4 And inva.Status & 32 = 32  
                                Then invd.Quantity * invd.SalePrice  
                              Else Cast(0 As Decimal(18, 6)) End),   
                       
                       "Net Sales" = Sum(Case When inva.InvoiceType <> 4 Then invd.Quantity * invd.SalePrice  
                              Else Cast(0 As Decimal(18, 6)) End) -   
                       (  Sum(Case When inva.InvoiceType = 4 And inva.Status & 32 = 0   
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
             --                   ,"Taxcollected"=Sum(case when Cus.Locality=1 and inva.InvoiceType in(1,3) then isnull(STPayable,0) + isnull(CSTPayable,0) when Cus.Locality=2 and inva.InvoiceType in(1,3) then isnull(STPayable,0) + isnull(CSTPayable,0) end)  
             
                       ,"SalesReturn"=(Sum(case when inva.InvoiceType = 4 then isnull(Amount,0) end) - Sum(case when Cus.Locality=1 and inva.InvoiceType = 4 then isnull(STPayable,0) when Cus.Locality=2 and inva.InvoiceType = 4 then isnull(CSTPayable,0) end))  
                       ,"StPayable"= Sum(case when Cus.Locality=1 and inva.InvoiceType = 4 then isnull(STPayable,0) end)
                       , isnull(Tax.Tax_Description,'') as [Tax_Description], isnull(Tax.Tax_Code,0) as Tax_Code  
                         
                From InvoiceDetail invd 
                    inner join InvoiceAbstract inva on  inva.InvoiceID = invd.InvoiceID
					inner join  Items itm on  invd.Product_Code = itm.Product_Code 
					inner join  Customer cus on  cus.CustomerID = inva.CustomerID
					left outer join  Tax on   invd.TaxID = Tax.Tax_Code
                Where     
                            
                      inva.InvoiceDate Between   
                      @FromDate And @ToDate And inva.Status & 192 = 0 And   
                      inva.InvoiceType In (1, 3, 4) And invd.Product_Code In (Select Product_Code From #tempItem)  
                Group By itm.CategoryID, invd.Product_Code, itm.productName,  
                      invd.TaxCode, invd.TaxCode2, IsNull(cus.TIN_Number, ''), inva.CustomerID,
                      isnull(Tax.Tax_Description,'') , isnull(Tax.Tax_Code,0) 
              ) 
              ala, #temp4, #tempcategory1  
         Where ala.[CategoryID] = #temp4.LeafID 
               and ala.[CategoryID] = #tempcategory1.CategoryID  
--                and ala.[Reg] = @reg
         Order By #tempcategory1.IDS, [Product Code]
      ) ala1  

      ----------  Get the component wise split-up

      Select * into #tmpCompWiseData
      from
      (
          Select #temp4.Parent, ala.Tax_Description, ala.Tax_Code, TaxPer, Tax_Component_Code, CompType, 
                 sum(Tax_Value*Multiplier) as CompWiseTax, Tax_Percentage as CompWiseTaxPer, sum(SalesValueWithTax) as SalesValueWithTax
          from
               (
                  select inva.InvoiceID, invd.Product_Code, itm.CategoryID, invd.TaxCode + invd.TaxCode2 as TaxPer,
                        case when sum(isnull(CSTPayable,0)) <> 0 then @CTPrefix --CST Component
                              else @LTPrefix
                         end as CompType, isnull(Tax.Tax_Description,'') as [Tax_Description], isnull(Tax.Tax_Code,0) as Tax_Code,
                         (case  when inva.InvoiceType in (1,3) then 1 when inva.InvoiceType in (4) then -1 end) as Multiplier,
                         Sum(isnull(case when inva.InvoiceType in(1,3)  then isnull(Amount,0) end,0)) - Sum(isnull(case when inva.InvoiceType = 4 then isnull(Amount,0) end,0)) as SalesValueWithTax  --Taxable Sales - Sales Return
                  
				  
				  From InvoiceDetail invd 
                    inner join InvoiceAbstract inva on  inva.InvoiceID = invd.InvoiceID
					inner join  Items itm on  invd.Product_Code = itm.Product_Code 
--                        Customer cus, Tax  
                    inner join    (select Case When IsNull(Customer.TIN_Number, '') = '' Then 1 Else 2 End as Reg, Customer.* from Customer) cus on   cus.CustomerID = inva.CustomerID
					left outer join  Tax on   invd.TaxID = Tax.Tax_Code
                  Where 
				  
                         inva.InvoiceDate Between @FromDate And @ToDate 
                        And inva.Status & 192 = 0 
                        And inva.InvoiceType In (1, 3, 4) 
                        And invd.Product_Code In (Select Product_Code From #tempItem)  
                        and cus.Reg = @Reg
                  Group By inva.InvoiceID, invd.Product_Code, itm.CategoryID, invd.TaxCode + invd.TaxCode2, 
                           isnull(Tax.Tax_Description,'') , isnull(Tax.Tax_Code,0), inva.InvoiceType
               )  ala, #temp4, #tempcategory1, InvoiceTaxComponents InvTaxComp  
          Where ala.[CategoryID] = #temp4.LeafID 
                and ala.[CategoryID] = #tempcategory1.CategoryID  
                and ala.InvoiceID = InvTaxComp.InvoiceID 
                and ala.[Product_Code] = InvTaxComp.Product_Code
                and ala.[Tax_Code] = InvTaxComp.Tax_Code
          Group By #temp4.Parent, TaxPer, Tax_Component_Code, CompType, Tax_Description, ala.Tax_Code, Tax_Percentage 
      ) tmp 


      select * into #tmpFinalData
      from
      (
          Select  
           #tmpData.[Reg], #tmpData.[Category], #tmpData.[VAT Percentage], "Sales(%c)" = Sum([Sales]), "ExemptSales" = Sum([ExemptSales]) ,
           "Sales Return Saleable(%c)" = Sum([Sales Return Salable]),   
           "Sales Return Damages(%c)" = Sum([Sales Return Damages]),   
           "Scheme(%c)" = Sum([Scheme]), "Discount(%c)" = Sum([Discount]),   
           "Taxable Sales(%c)" = Sum([Taxable Sales]), "Tax Collected(%c)" = Sum([Tax Collected]),
           Tax_Description, Tax_Code, 0 as [Exempt Sales(%c)]     
          From #tmpData, #tempcategory1 Where #tempcategory1.CategoryID = #tmpData.[IDS] And [Reg] = @Reg  
          Group By #tmpData.[Reg], #tmpData.[Category], #tmpData.[VAT Percentage], #tmpData.[IDS], #tempcategory1.[IDS], 
                   Tax_Description, Tax_Code   
      ) tmp 

      ----------Find the No Of columns To be introduced
      select  top 1 @MaxLTDynamicCols = count(Tax_Component_Code) from #tmpCompWiseData where CompType = @LTPrefix  and CompWiseTax > 0 and CompWiseTaxPer > 0
      group by Parent, TaxPer, Tax_Description, Tax_Code order by count(Tax_Component_Code) desc
      select  top 1 @MaxCTDynamicCols = count(Tax_Component_Code) from #tmpCompWiseData where CompType = @CTPrefix  and CompWiseTax > 0 and CompWiseTaxPer > 0
      group by Parent, TaxPer, Tax_Description, Tax_Code order by count(Tax_Component_Code) desc
      ----------Add the columns in main data table
      if @MaxLTDynamicCols > 0 or @MaxCTDynamicCols > 0
      Begin
           set @Col = 1  --Dynamic Columns
           set @DynFields = ''

           --LT Columns 
           while @Col <= @MaxLTDynamicCols
           Begin
                Set @SQL= N'Alter Table #tmpFinalData Add [' + @LTPrefix + 'TaxComponent' + Cast(@Col as nvarchar) + N' Tax %] decimal(18,6) default 0;'    
                Set @SQL=@SQL + N'Alter Table #tmpFinalData Add [' + @LTPrefix + 'TaxComponent' + Cast(@Col as nvarchar) +  N'] decimal(18,6) default 0;'    
                set @DynFields = @DynFields + N'sum(isnull([' + @LTPrefix + 'TaxComponent' + Cast(@Col as nvarchar) + N' Tax %],0)) as [' + @LTPrefix + 'Component ' + Cast(@Col as nvarchar) + N' Tax%],'
                set @DynFields = @DynFields + N'sum(isnull([' + @LTPrefix + 'TaxComponent'  + Cast(@Col as nvarchar)+ N'],0)) as [' + @LTPrefix + 'Component ' + Cast(@Col as nvarchar) + N' Tax Amount],'
                Exec(@SQL)
                set @Col = @Col + 1
           End 

           set @Col = 1 

           --CT Columns 
           while @Col <= @MaxCTDynamicCols
           Begin
                Set @SQL= N'Alter Table #tmpFinalData Add [' + @CTPrefix + 'TaxComponent' + Cast(@Col as nvarchar) +  N'] decimal(18,6) default 0;'    
                Set @SQL=@SQL + N'Alter Table #tmpFinalData Add [' + @CTPrefix + 'TaxComponent' + Cast(@Col as nvarchar) + N' Tax %] decimal(18,6) default 0;'    
                set @DynFields = @DynFields + N'sum(isnull([' + @CTPrefix + 'TaxComponent' + Cast(@Col as nvarchar) + N' Tax %],0)) as [' + @CTPrefix + 'Component ' + Cast(@Col as nvarchar) + N' Tax%],'
                set @DynFields = @DynFields + N'sum(isnull([' + @CTPrefix + 'TaxComponent' + Cast(@Col as nvarchar) + N'],0)) as [' + @CTPrefix + 'Component ' + Cast(@Col as nvarchar) + N' Tax Amount],'
                Exec(@SQL)
                set @Col = @Col + 1
           End 

           ----------For every Category and percentage combination 
           Declare TaxFetch cursor for 
           select Parent, TaxPer, Tax_Code from #tmpCompWiseData group by Parent, TaxPer, Tax_Code 
      
           Open TaxFetch    
           Fetch next from Taxfetch into @CatName, @TaxPer, @Tax_Code
           While(@@FETCH_STATUS =0)    
           begin    
                --get the componentwise tax value in the order of Tax_Component_Code
                Set @col = 1 --Dynamic Column 
                Set @LTColCnt = 1
                Set @CTColCnt = 1

                Declare TaxData cursor for

                select CompWiseTax,CompWiseTaxPer, CompType, Tax_Code, SalesValueWithTax  from #tmpCompWiseData 
                where Parent = @CatName and TaxPer = @TaxPer and Tax_Code = @Tax_Code 
                order by Tax_Component_Code, CompType Desc

                Open TaxData    
                Fetch next from TaxData into @TaxCompVal, @TaxCompPer, @CompType1, @Tax_Code1, @SalesValueWithTax    
                While(@@FETCH_STATUS =0)    
                begin    
                     --update the dynamic cols
   
                     if @CompType1  = @CTPrefix
                     Begin
                          if @TaxCompVal > 0 and @TaxCompPer > 0
                          Begin  
					                          Set @SQL=N'update #tmpFinalData set [' + @CTPrefix +  'TaxComponent' + Cast(@CTColCnt as nvarchar) + N'] = ' + Cast(@TaxCompVal as nvarchar)    
					                          Set @SQL= @SQL + N' where Category = ''' +  Cast(@CatName as nvarchar) + N''' and [VAT Percentage] = ' +  Cast(@TaxPer as nvarchar)  + N' and [Tax_Code] = '  + Cast(@Tax_Code as nvarchar)
					                          Exec(@SQL) 
					   Set @SQL=N'update #tmpFinalData set [' + @CTPrefix +  'TaxComponent' +  Cast(@CTColCnt as nvarchar) + N' Tax %] = ' + Cast(@TaxCompPer as nvarchar)    
					                          Set @SQL= @SQL + N' where Category = ''' +  Cast(@CatName as nvarchar) + N''' and [VAT Percentage] = ' +  Cast(@TaxPer as nvarchar)  + N' and [Tax_Code] = '  + Cast(@Tax_Code as nvarchar)
					                          Exec(@SQL)
                          End

                          set @CTColCnt = @CTColCnt + 1
                     End
                     Else 
                     Begin
                          if @TaxCompVal > 0 and @TaxCompPer > 0
                          Begin  
					                          Set @SQL=N'update #tmpFinalData set [' + @LTPrefix + 'TaxComponent' + Cast(@LTColCnt as nvarchar) + N'] = ' + Cast(@TaxCompVal as nvarchar)    
					                          Set @SQL= @SQL + N' where Category = ''' +  Cast(@CatName as nvarchar) + N''' and [VAT Percentage] = ' +  Cast(@TaxPer as nvarchar)  + N' and [Tax_Code] = ' + Cast(@Tax_Code as nvarchar)
					                          Exec(@SQL) 
					                          Set @SQL=N'update #tmpFinalData set [' + @LTPrefix + 'TaxComponent' + Cast(@LTColCnt as nvarchar) + N' Tax % ] = ' + Cast(@TaxCompPer as nvarchar)    
					                          Set @SQL= @SQL + N' where Category = ''' +  Cast(@CatName as nvarchar) + N''' and [VAT Percentage] = ' +  Cast(@TaxPer as nvarchar)  + N' and [Tax_Code] = ' + Cast(@Tax_Code as nvarchar)
					                          Exec(@SQL) 
                          End

                          set @LTColCnt = @LTColCnt + 1
                     End

                     set @Col = @Col + 1                      
                Fetch next from TaxData into @TaxCompVal, @TaxCompPer, @CompType1, @Tax_Code1, @SalesValueWithTax    
                End    
                Close TaxData    
                Deallocate TaxData     
           Fetch next from Taxfetch into @CatName, @TaxPer, @Tax_Code
           End    
           Close TaxFetch    
           Deallocate TaxFetch   
      End
      

      Set @SQL=        N'Select '
      Set @SQL= @SQL + N'      [Reg], [Category], case [VAT Percentage] when 0 then ''Exempt'' else [Tax_Description] end as [Tax_Description], [VAT Percentage], sum([Sales(%c)]) as [Sales(%c)], sum([Sales Return Saleable(%c)]) as [Sales Return Saleable(%c)], sum([Sales Return Damages(%c)]) as [Sales Return Damages(%c)], sum([Scheme(%c)]) as [Scheme(%c)], sum([Discount(%c)]) as [Discount(%c)], sum([Taxable Sales(%c)]) as [Taxable Sales(%c)], '  
      if isnull(@DynFields,'') <> ''
      Set @SQL= @SQL + @DynFields
      Set @SQL= @SQL + N'      sum([Tax Collected(%c)]) as [Tax Collected(%c)]'  
      Set @SQL= @SQL + N' From #tmpFinalData'
      Set @SQL= @SQL + N' Group by [Reg], [Category], case [VAT Percentage] when 0 then ''Exempt'' else [Tax_Description] end , [VAT Percentage]'

      Exec(@SQL)

	     drop table #tmpCompWiseData
	     drop table #tmpFinalData
	     drop table #tmpData
	

End 
Drop Table #tempcategory1  
Drop Table #tmpCat1  
Drop Table #tmpCat  
-- Drop Table #temp1  
Drop Table #temp2    
Drop Table #temp3    
Drop Table #temp4    
Drop Table #tempCategory      
Drop Table #tempItem
GSTOut:
