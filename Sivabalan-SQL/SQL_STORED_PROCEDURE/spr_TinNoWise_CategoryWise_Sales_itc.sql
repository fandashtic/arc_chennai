CREATE Procedure spr_TinNoWise_CategoryWise_Sales_itc  
      (
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
  
Create table #tmpCat1(Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
Create table #tempCategory1 (IDS int Identity(1,1),  CategoryID Int, Category nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Status Int)  
  
Insert into #tmpCat1 select Category_Name from ItemCategories   
Where [Level] = 1 Order By Category_Name  
  
Insert into #tempCategory1 select CategoryID, Category_Name, 0       
From ItemCategories    
Where ItemCategories.Category_Name In (Select Category from #tmpCat1)    
Order By Category_Name  


select * into #tmpCustomer from Customer 
if @regstatus = 'Register'
delete from  #tmpCustomer where IsNull(TIN_Number, '') = ''
else if @regstatus = 'UnRegister'
delete from  #tmpCustomer where IsNull(TIN_Number, '') <> ''
  
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
  
----------  
  
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
  
Select  
 [Reg],   
 "Registered / Un - Registered" = Case When [Reg] = 1 Then 'Un - Registered' Else 'Registered' End,  
 [Sales], [Sales Return Salable], [Sales Return Damages],[Scheme], [Discount],  
 [Taxable Sales],[Tax Collected], [InvScheme], [TrdDiscount], [AddlDiscount]  
InTo  
 #temp1  
From   
 (Select  
   Top 100 Percent [Reg],[CustID],#tempcategory1.IDS,#temp4.Parent,ala.[CategoryID],  
   [Product Code],[Product Name],[VAT Percentage],[Sales],[Sales Return Salable],  
   [Sales Return Damages], [Net Sales], "Scheme" = [Scheme] + [InvScheme],   
   "Discount" = [Discount] + [TrdDiscount] + [AddlDiscount] - [InvScheme],   
   "Taxable Sales" = isnull(TaxableSales,0) - isnull(SalesReturn,0),  
   "Tax Collected" = isnull(Taxcollected,0) - isnull(StPayable,0),   
   "InvScheme" = [InvScheme], "TrdDiscount" = [TrdDiscount] - [InvScheme],   
   "AddlDiscount" = [AddlDiscount]  
  From  
  (Select  
    "Reg" = Case When IsNull(cus.TIN_Number, '') = '' Then 1 Else 2 End,  
    "CustID" = inva.CustomerID, "CategoryID" = itm.CategoryID,   
    "Product Code" = invd.Product_Code,"Product Name" = itm.productName,  
    "VAT Percentage" = invd.TaxCode + invd.TaxCode2,   
    "Sales" =   
     Sum  
     (  
      Case  
       When inva.InvoiceType <> 4 Then invd.Quantity * invd.SalePrice  
       Else Cast(0 As Decimal(18, 6))  
      End  
     ),   
    "Sales Return Salable" =   
     Sum(Case When inva.InvoiceType = 4 And IsNull(inva.Status,0) & 32 = 0  Then invd.Quantity * invd.SalePrice  
       Else Cast(0 As Decimal(18, 6)) End),   
  
"Sales Return Damages" = Sum(Case When inva.InvoiceType = 4 And IsNull(inva.Status,0) & 32 = 32  
         Then invd.Quantity * invd.SalePrice  
       Else Cast(0 As Decimal(18, 6)) End),   
  
"Net Sales" = Sum(Case When inva.InvoiceType <> 4 Then invd.Quantity * invd.SalePrice  
      Else Cast(0 As Decimal(18, 6)) End) -   
(  Sum(Case When inva.InvoiceType = 4 And IsNull(inva.Status,0) & 32 = 0   
         Then invd.Quantity * invd.SalePrice  
       Else Cast(0 As Decimal(18, 6)) End) +   
  
   Sum(Case When inva.InvoiceType = 4 And IsNull(inva.Status,0) & 32 = 32  
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
  
  
From InvoiceDetail invd, InvoiceAbstract inva, Items itm, #tmpCustomer cus  
Where inva.InvoiceID = invd.InvoiceID And invd.Product_Code = itm.Product_Code And   
cus.CustomerID = inva.CustomerID And   
inva.InvoiceDate Between   
@FromDate And @ToDate And IsNull(inva.Status,0) & 192 = 0 And   
inva.InvoiceType In (1, 3, 4) And invd.Product_Code In (Select Product_Code From #tempItem)  
Group By itm.CategoryID, invd.Product_Code, itm.productName,  
invd.TaxCode, invd.TaxCode2, IsNull(cus.TIN_Number, ''), inva.CustomerID) ala, #temp4, #tempcategory1  
Where ala.[CategoryID] = #temp4.LeafID And   
ala.[CategoryID] = #tempcategory1.CategoryID  
Order By #tempcategory1.IDS, [Product Code]) ala1  
  
-- select * from  #temp1  
  
Select  
 "Reg" = [Reg], "Registered / Un - Registered" = [Registered / Un - Registered],   
 "Sales(%c)"= Sum([Sales]), "Sales Return Saleable(%c)" = Sum([Sales Return Salable]),   
 "Sales Return Damages(%c)" = Sum([Sales Return Damages]), "Scheme(%c)" = Sum([Scheme]),   
 "Discount(%c)" = Sum([Discount]), "Taxable Sales(%c)" = Sum([Taxable Sales]),  
 "Tax Collected(%c)" = Sum([Tax Collected])  
From  
 #temp1   
Group By  
 [Reg], [Registered / Un - Registered]  
  
Drop Table #tempcategory1  
Drop Table #tmpCat1  
Drop Table #temp1  
Drop Table #temp2    
Drop Table #temp3    
Drop Table #temp4    
Drop Table #tempCategory      
Drop Table #tempItem 
GSTOut: 
