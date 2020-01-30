CREATE PROCEDURE spr_abc_Gillete(@Category nvarchar(2550),    
   @FROMDATE datetime,    
   @TODATE datetime,    
   @AmountA float,    
   @AmountB float)    
AS    
DECLARE @TOTALSALES float    
  
Declare @Delimeter as Char(1)    
Set @Delimeter=Char(15)    
  
Create table #tmpCat(Category nvarchar(255))    
if @Category = '%'     
   Insert into #tmpCat select Category_Name from ItemCategories  
Else    
   Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@Category, @Delimeter)    
  
  
Create Table #tempCategory(CategoryID int,    
     Category_Name nvarchar(255),    
     Status int)    
Declare @Continue int    
Declare @CategoryID int    
Set @Continue = 1    
Insert into #tempCategory select CategoryID, Category_Name, 0 From ItemCategories    
Where Category_Name In (Select Category From #tmpCat)  
While @Continue > 0    
Begin    
 Declare Parent Cursor Static For    
 Select CategoryID From #tempCategory Where Status = 0    
 Open Parent    
 Fetch From Parent Into @CategoryID    
 While @@Fetch_Status = 0    
 Begin    
  Insert into #tempCategory    
  Select CategoryID, Category_Name, 0 From ItemCategories     
  Where ParentID = @CategoryID    
  Update #tempCategory Set Status = 1 Where CategoryID = @CategoryID    
  Fetch Next From Parent Into @CategoryID    
 End    
 Close Parent    
 DeAllocate Parent    
 Select @Continue = Count(*) From #tempCategory Where Status = 0    
End    
    
SELECT "CustomerID" = Customer.CustomerID, "Beat" = Beat.Description INTO #tempBeat FROM ((Customer    
LEFT OUTER JOIN Beat_SalesMan ON Customer.CustomerID = Beat_SalesMan.CustomerID)     
LEFT OUTER JOIN Beat ON Beat_SalesMan.BeatID = Beat.BeatID)    
    
create table #temp(    
 CustomerID nvarchar(15),     
 TotalSales float)    
    
insert into #temp (CustomerID, TotalSales)     
select InvoiceAbstract.CustomerID, SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items, ItemCategories    
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND     
InvoiceDetail.Product_Code = Items.Product_Code AND    
Items.CategoryID = ItemCategories.CategoryID AND     
ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #tempCategory) AND    
InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
InvoiceType in (1, 3) AND (Status & 128) = 0    
Group By ItemCategories.CategoryID, InvoiceAbstract.CustomerID    
    
insert into #temp (CustomerID, TotalSales)     
select InvoiceAbstract.CustomerID, 0 - SUM(Amount) from InvoiceAbstract, InvoiceDetail, Items, ItemCategories    
WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
InvoiceDetail.Product_Code = Items.Product_Code AND    
Items.CategoryID = ItemCategories.CategoryID AND    
ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #tempCategory) AND    
InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
InvoiceType = 4 AND (Status & 128) = 0    
Group By ItemCategories.CategoryID, InvoiceAbstract.CustomerID    
    
Select #temp.CustomerID, #temp.CustomerID, "Name of Retailer" = Customer.Company_Name,     
 "Beat" = Beat,    
 "Average Monthly Turnover (%c.)" = Sum(TotalSales),    
 "ABC Analysis" = case    
 when Sum(TotalSales) >= @AmountA then    
 'A'    
 when Sum(TotalSales) >= @AmountB And Sum(TotalSales) <= @AmountA then    
 'B'    
 else    
 'C'    
 end,    
 "% Contribution to total business" = Cast(((Sum(TotalSales) / (SELECT Sum(TotalSales) FROM #temp)) * 100) As Decimal(15,2))    
    
From #temp, Customer, #tempBeat    
Where #tempBeat.CustomerID = Customer.CustomerID And    
#temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID    
group by #temp.CustomerID, Customer.Company_Name, Beat    
Order By "Classification"    
    
drop table #temp    
drop table #tempCategory    
drop table #tempBeat    
Drop Table #tmpCat    


