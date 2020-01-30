CREATE Procedure spr_list_CustomerwiseCategory_pidilite(@ProductHierarchy nVarChar(100),       
@Category nVarChar(4000), @Beat nVarChar(2550),                
@Salesman nVarChar(2550), @Customer nVarChar(4000), @UOM nVarChar(100),       
@FromDate DateTime, @ToDate DateTime)                
As                
Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)        
Create table #tmpBeat(Beat nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)       
Create Table #tmpSalesMan ( SalesMan_Name nvarchar (255) COLLATE SQL_Latin1_General_CP1_CI_AS)       
Create Table #tmpCustomer ( Company_Name nvarchar (255) COLLATE SQL_Latin1_General_CP1_CI_AS)       
      
if @Beat = N'%'         
Begin      
 Insert into #tmpBeat select description from Beat        
    Insert InTo #tmpBeat Values (N'')      
End      
Else        
Begin      
 Insert into #tmpBeat select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter)         
End      
      
if @Salesman = N'%'         
Begin      
 Insert into #tmpSalesMan select SalesMan_Name from SalesMan        
    Insert InTo #tmpSalesMan Values (N'')      
End      
Else        
Begin      
 Insert into #tmpSalesMan select * from dbo.sp_SplitIn2Rows(@SalesMan,@Delimeter)         
End      
      
if @Customer = N'%'         
Begin      
 Insert into #tmpCustomer select Company_Name from Customer      
    Insert InTo #tmpCustomer Values (N'')      
End      
Else        
Begin      
 Insert into #tmpCustomer select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)         
End      
      
      
Create Table #tempCategory(CategoryID int, Status int)                
Exec GetSubCategories @Category              
      
            
Declare @ProductHierarchyID int                
If RTRIM(LTRIM(@ProductHierarchy)) Is Null Or RTRIM(LTRIM(@ProductHierarchy)) =  N'%' or RTRIM(LTRIM(@ProductHierarchy)) = N''              
 Set @ProductHierarchyID = 1              
Else              
 Select @ProductHierarchyID = HierarchyID From ItemHierarchy Where IsNull(HierarchyName, N'') Like @ProductHierarchy                
              
                
Create Table #temtab1 ([ID] Int Identity(1, 1), CustomerName VarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, CatsID Int,              
Quantity Decimal(18,6), GrossValue Decimal(18,6), TaxValue Decimal(18,6), Discount Decimal(18,6), NetAmount               
Decimal(18,6))              
              
Create Table #temtab2 ( ID Int Identity(1, 1), CustomerName VarChar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)              
--Quantity Decimal(18,6), GrossValue Decimal(18,6), TaxValue Decimal(18,6), Discount Decimal(18,6), NetAmount               
--Decimal(18,6))                        
                
      
Insert #temtab1 Select * From (                
Select Company_Name, CatID, Sum(Qty) Quantity, Sum([Gross Value]) "Gross Value",                 
Sum([Tax Value]) "Tax Value",                 
Sum(Discount) Discount, Sum([Net Value]) "Net Value" From (                
Select cu.Company_Name, dbo.fin_cat(@ProductHierarchyID, ide.Product_Code) CatID, Sum((Case InvoiceType When 4 Then -1 Else 1 End) *                 
(Case @UOM When N'Sales UOM' Then Quantity      
     When N'Reporting UOM' Then  Quantity / (Case isnull(it.reportingunit, 1) when 0 then 1 Else isnull(it.reportingunit, 1) End)    
           When N'Conversion Factor' Then Quantity * Isnull(it.Conversionfactor,0)     
           When N'UOM1' then Quantity/ (Case When IsNull(UOM1_Conversion, 0) = 0 Then 1 Else UOM1_Conversion End)  
           When N'UOM2' then Quantity/ (Case When IsNull(UOM2_Conversion, 0) = 0 Then 1 Else UOM2_Conversion End)            
End)) Qty,    
Sum(((Case InvoiceType When 4 Then -1 Else 1 End) * Quantity) * SalePrice) "Gross Value",                 
Sum((Case InvoiceType When 4 Then -1 Else 1 End) * CSTPayable + STPayable +                 
((Quantity * SalePrice) * ide.TaxSuffered)/100) "Tax Value",                
Sum((Case InvoiceType When 4 Then -1 Else 1 End) * ide.DiscountValue) Discount,                 
Sum((Case InvoiceType When 4 Then -1 Else 1 End) * Amount) "Net Value" From itemcategories itcat Join Items it       
On it.Categoryid = itcat.Categoryid join InvoiceDetail ide on it.Product_code = ide.Product_code Join                 
InvoiceAbstract ia On ia.InvoiceID = ide.InvoiceID Join Customer cu On                 
ia.CustomerID = cu.CustomerID Left Join Beat be On ia.BeatID = be.BeatID Left Join Salesman sa On                
ia.SalesmanID = sa.SalesmanID Where                 
(IsNull(Status, 0) & 192) = 0 And InvoiceType != 2 And IsNull(be.[Description], N'') IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat)      
And IsNull(Salesman_Name, N'') IN (Select SalesMan_Name COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpSalesman) And        
itcat.categoryid IN (Select CategoryID From #tempCategory) And       
isnull(cu.Company_Name, N'') IN (Select Company_Name From #tmpCustomer) And InvoiceDate Between @FromDate And                 
@ToDate Group By ide.Product_Code, cu.Company_Name                
) temtab Where CatID > 0 Group By CatID, Company_Name) abse                
      
--select * from #temtab1      
                
                
Declare @Count1 Int, @VarID1 Int, @VarID2 Int, @Count2 Int, @LevelCat varchar(50), @VarString1 nVarChar(4000)                
Set @VarID1 = 1                
Select @Count1 = Count(*) From #temtab1                
If @Count1 > 0                
 Begin                
  Create Table #catname([ID] Int Identity(1, 1), CID Int, CName VarChar(100))                
  Insert  #catname Select * From (Select distinct CategoryID, Category_Name From ItemCategories it Join #temtab1                
  te on it.CategoryID = te.CatsID) ccn                
 End                
Else               
 Begin              
 GoTo Lab1              
End              
            
Select @Count2 = Count(*) From #catname                
While @VarID1 <= @Count2                
Begin                
 Select @VarID2 = CID From #catname Where [ID] = @VarID1                
 Select @LevelCat = CName From #catname Where CID = @VarID2                
 Set @VarString1 = N'Alter table #temtab2 Add [' + @LevelCat + N'] Decimal(18, 6) Default(0)'                
 Exec sp_executesql @VarString1            
 Set @VarID1 = @VarID1 + 1                
End                
Alter table #temtab2 Add GrossValue Decimal(18,6), TaxValue Decimal(18,6),              
Discount Decimal(18,6), NetValue Decimal(18,6)              
--Declare @aCount1 Int, @bVarID1 Int, @cVarID2 Int, @dCount2 Int,             
--@LevelCat varchar(50), @nvVarString1 nVarChar(4000)                    
Declare @TempCatID Int, @VarString2 nVarChar(4000), @CatName VarChar(100),              
@CustomerName VarChar(100)                
Declare @Qty Decimal(18,6), @GV Decimal(18,6), @TV Decimal(18,6), @Dis Decimal(18,6), @NA Decimal(18,6)              
Set @VarID1 = 1                
While @VarID1 <= @Count1                
Begin                
 Select @TempCatID = catsid, @CustomerName = CustomerName From #temtab1 Where [ID] = @VarID1                
 Select @CatName = CName From #catname Where CID = @TempCatID            
 If Exists (Select * From #temtab2 Where CustomerName = @CustomerName)                
  Begin                
   Select @TempCatID = [ID] From #temtab2 Where CustomerName = @CustomerName            
   Select @Qty = Quantity, @GV = GrossValue, @TV = TaxValue, @Dis = Discount, @NA = NetAmount                
   From #temtab1 Where [ID] = @VarID1             
   Set @VarString2 = N'Update #temtab2 Set [' + @CatName + N'] = ' +  N'IsNull([' + @CatName + N'], 0) + '            
   + Cast(@Qty As VarChar) +                 
   N', GrossValue = GrossValue + ' +  Cast(@GV As VarChar) + N', TaxValue = TaxValue + ' +                 
   Cast(@TV As VarChar) + N', Discount = Discount + ' + Cast(@Dis As VarChar) + N',                 
   NetValue = NetValue + ' + Cast(@NA As VarChar) + N' Where [ID] = ' + Cast(@TempCatID As VarChar)            
   exec sp_executesql @VarString2            
   Set @VarID1 = @VarID1 + 1          
  End                
 Else                
 Begin                
  Set @VarString2 = N'Insert #temtab2(CustomerName, [' + @CatName + N'], GrossValue,                 
  TaxValue, Discount,                
  NetValue) Select CustomerName, Quantity, GrossValue, TaxVAlue, Discount, NetAmount From     
  #temtab1 Where [ID] = ' + Cast(@VarID1 As VarChar)                 
  exec sp_executesql @VarString2            
  Set @VarID1 = @VarID1 + 1                
 End                
End                
                
Drop table #catname                
              
Lab1:              
              
Select * From #temtab2                
--Drop table #catname                
Drop table #temtab1                
Drop table #temtab2                
Drop Table #tmpBeat      
Drop Table #tmpSalesMan       
      
      
    
  
  



