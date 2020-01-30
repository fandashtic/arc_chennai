CREATE procedure [dbo].[Spr_Salesman_Productivity_Percentage_Penetration]
							    (@ProHier nvarchar(255),
							     @Category nvarchar(2550),
							     @Salesman nvarchar(2550),
							     @FromDate DateTime,
							     @ToDate DateTime)
As

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Declare @OTHERS NVarchar(50)
Set @OTHERS=dbo.LookupDictionaryItem(N'Others', Default)

Create table #tmpSal(Salesman nvarchar(255))  

If @Salesman = '%'   
   Insert into #tmpSal select Salesman_Name from Salesman  
Else  
   Insert into #tmpSal select * from dbo.sp_SplitIn2Rows(@Salesman, @Delimeter)  

Create Table #tempCategory (CategoryID Int, Status Int)
Exec GetLeafCategories @ProHier, @Category
Select Distinct CategoryID InTo #temp From #tempCategory


Create Table #temp1(SalesmanID Int, SalesmanName nvarchar(255), SalesValue Decimal(18, 6),
  SalesVolume Decimal(18, 6), UOMDescription nvarchar(255))


If @Salesman = '%'
Begin
  Select IsNull(ia.SalesmanID, 0), "Salesman Name" = IsNull(s.Salesman_Name, @OTHERS), 
  "Sales Value (%c)" = Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End 
  * IsNull(ids.Amount, 0)) As Decimal(18, 6)),
  "Total Outlets" = Count(Distinct ia.CustomerID),
  "No of Products Sold" = Count(Distinct ids.Product_Code),
  "Percentage of Penetration" = Cast(Count(Distinct ids.Product_Code) As Decimal(18, 6)) / Cast(Count(Distinct ia.CustomerID) As Decimal(18, 6))
  From Salesman s, InvoiceAbstract ia, InvoiceDetail ids, Items it, #temp 
  Where ia.InvoiceID = ids.InvoiceID And ids.Product_Code = it.Product_Code And 
  it.CategoryID = #temp.CategoryID And ia.SalesmanID *= s.SalesmanID  And 
  s.Salesman_Name In (Select * From #tmpSal) And ia.InvoiceDate Between @FromDate And 
  @ToDate And IsNull(ia.Status, 0) & 192 = 0 And IsNull(ia.InvoiceType, 0) Not In (2) 
  Group By ia.SalesmanID, s.Salesman_Name
End
Else
Begin
  Select IsNull(ia.SalesmanID, 0), "Salesman Name" = IsNull(s.Salesman_Name, @OTHERS), 
  "Sales Value (%c)" = Cast(Sum(Case IsNull(ia.InvoiceType, 0) When 4 Then -1 Else 1 End 
  * IsNull(ids.Amount, 0)) As Decimal(18, 6)),
  "Total Outlets" = Count(Distinct ia.CustomerID),
  "No of Products Sold" = Count(Distinct ids.Product_Code),
  "Percentage of Penetration" = Cast(Count(Distinct ids.Product_Code) As Decimal(18, 6)) / Cast(Count(Distinct ia.CustomerID) As Decimal(18, 6))
  From Salesman s, InvoiceAbstract ia, InvoiceDetail ids, Items it, #temp 
  Where ia.InvoiceID = ids.InvoiceID And ids.Product_Code = it.Product_Code And 
  it.CategoryID = #temp.CategoryID And ia.SalesmanID = s.SalesmanID  And 
  s.Salesman_Name In (Select * From #tmpSal) And ia.InvoiceDate Between @FromDate And 
  @ToDate And IsNull(ia.Status, 0) & 192 = 0 And IsNull(ia.InvoiceType, 0) Not In (2) 
  Group By ia.SalesmanID, s.Salesman_Name
End

Drop Table #tmpSal
Drop Table #tempCategory
Drop Table #temp
Drop Table #temp1
