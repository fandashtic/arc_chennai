CREATE procedure [dbo].[spr_ser_ABC](@Category varchar(2550),    
   @CusType nVarchar(50),    
   @FROMDATE datetime,    
   @TODATE datetime,    
   @AmountA Decimal(18,6),    
   @AmountB Decimal(18,6))    
AS    
    
Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Create table #tmpCat(CategoryName varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)      
if @Category='%'       
   Insert into #tmpCat select Category_Name from ItemCategories      
Else      
   Insert into #tmpCat select * from dbo.sp_SplitIn2Rows(@Category,@Delimeter)      
    
    
DECLARE @TOTALSALES Decimal(18,6)    
Create Table #tempCategory(CategoryID int,    
     Category_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,    
     Status int)    
Declare @Continue int    
Declare @CategoryID int    
Set @Continue = 1    
Insert into #tempCategory select CategoryID, Category_Name, 0 From ItemCategories    
Where Category_Name In (select CategoryName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCat)      
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
--Select * From #temp    
--Select CategoryID, category_Name From ItemCategories Where CategoryID not in    
--(Select CategoryID From #temp)    
create table #temp(    
 CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 Company_Name nVarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 TotalSales Decimal(18,6))    
    
IF @CusType = 'Trade'    
BEGIN    
 insert into #temp (CustomerID, Company_Name, TotalSales)     
 select InvoiceAbstract.CustomerID, Customer.Company_Name, SUM(Amount) from InvoiceAbstract, Customer, InvoiceDetail, Items, ItemCategories    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND     
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 InvoiceAbstract.CustomerID = Customer.CustomerID And    
 Items.CategoryID = ItemCategories.CategoryID AND     
 ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #tempCategory) AND    
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType in (1,3) AND (Status & 128) = 0    
 Group By ItemCategories.CategoryID, InvoiceAbstract.CustomerID, Customer.Company_Name    
     
 insert into #temp (CustomerID, Company_Name, TotalSales) SELECT InvoiceAbstract.CustomerID, Customer.Company_Name,    
 0 - SUM(Amount) from InvoiceAbstract, InvoiceDetail, Customer, Items, ItemCategories    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 InvoiceAbstract.CustomerID = Customer.CustomerID And    
 Items.CategoryID = ItemCategories.CategoryID AND    
 ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #tempCategory) AND    
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType = 4 AND (Status & 128) = 0    
 Group By ItemCategories.CategoryID, InvoiceAbstract.CustomerID, Customer.Company_Name    
END    
ELSE    
BEGIN    
 Insert into #temp (CustomerID, Company_Name, TotalSales)     
 select CASE InvoiceAbstract.CustomerID WHEN '0' THEN 'Other Customer' ELSE InvoiceAbstract.CustomerID END, IsNull(Customer.Company_Name,'Other Customer'),     
 SUM(Amount) from InvoiceAbstract, Customer, InvoiceDetail, Items, ItemCategories    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND 
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 InvoiceAbstract.CustomerID *= Customer.CustomerID And    
 Items.CategoryID = ItemCategories.CategoryID AND     
 ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #tempCategory) AND    
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType = 2 AND (Status & 128) = 0    
 Group By ItemCategories.CategoryID, InvoiceAbstract.CustomerID, Customer.Company_Name    

 Insert into #temp (CustomerID, Company_Name, TotalSales)     
 select CASE ServiceInvoiceAbstract.CustomerID WHEN '0' THEN 'Other Customer' 
 ELSE ServiceInvoiceAbstract.CustomerID END, IsNull(Customer.Company_Name,'Other Customer'),     
 SUM(serviceinvoicedetail.Netvalue) from serviceInvoiceAbstract, Customer, ServiceInvoiceDetail, Items, ItemCategories    
 WHERE ServiceInvoiceAbstract.ServiceInvoiceID = ServiceInvoiceDetail.ServiceInvoiceID AND     
 ServiceInvoiceDetail.SpareCode = Items.Product_Code AND    
 ServiceInvoiceAbstract.CustomerID *= Customer.CustomerID And    
 Items.CategoryID = ItemCategories.CategoryID AND     
 ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #tempCategory) AND    
 ServiceInvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 ServiceInvoiceType = 1 AND Isnull(ServiceInvoiceAbstract.Status,0) & 192  = 0    
And ISnull(serviceinvoicedetail.sparecode,'') <> ''
Group By ItemCategories.CategoryID, ServiceInvoiceAbstract.CustomerID, Customer.Company_Name    
  
 
 insert into #temp (CustomerID, Company_Name, TotalSales) SELECT InvoiceAbstract.CustomerID, Customer.Company_Name,    
 0 - SUM(Amount) from InvoiceAbstract, InvoiceDetail, Customer, Items, ItemCategories    
 WHERE InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND    
 InvoiceDetail.Product_Code = Items.Product_Code AND    
 InvoiceAbstract.CustomerID = Customer.CustomerID And    
 Items.CategoryID = ItemCategories.CategoryID AND    
 ItemCategories.Category_Name In (Select Category_Name collate SQL_Latin1_General_Cp1_CI_AS From #tempCategory) AND    
 InvoiceDate BETWEEN @FROMDATE AND @TODATE AND     
 InvoiceType in(5,6) AND (Status & 128) = 0    
 Group By ItemCategories.CategoryID, InvoiceAbstract.CustomerID, Customer.Company_Name    
END    
    
    
Select #temp.CustomerID, #temp.CustomerID, "Customer" = #temp.Company_Name,     
 "Total Sales (%c.)" = Sum(TotalSales),    
 "Classification" = case    
 when Sum(TotalSales) >= @AmountA then    
 'A'    
 when Sum(TotalSales) >= @AmountB And Sum(TotalSales) <= @AmountA then    
 'B'    
 else    
 'C'    
 end    
From #temp group by #temp.CustomerID, #temp.Company_Name    
Order By "Classification"    
drop table #temp    
drop table #tempCategory    
Drop table #tmpCat
