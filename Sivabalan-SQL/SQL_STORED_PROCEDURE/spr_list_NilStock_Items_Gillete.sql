CREATE procedure spr_list_NilStock_Items_Gillete(@LessQty Decimal(18,6) = 0)
as
DECLARE @SQL nvarchar(1000)  
DECLARE @FirstLevel nvarchar(1000)  
DECLARE @LastLevel nvarchar(1000)  
  
 SET @FirstLevel = dbo.GetHierarchyColumn('FIRST')
 SET @LastLevel= dbo.GetHierarchyColumn('LAST')

select Items.Product_Code, "Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID), 
"Product Hierarchy Last Level" = ItemCategories.Category_Name, 
"Product Code" = Items.Product_Code, "Product Name" = Items.ProductName,
"Last Sale Date" = (select max(InvoiceAbstract.InvoiceDate)
from InvoiceAbstract, InvoiceDetail 
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and
InvoiceDetail.Product_Code = Items.Product_Code and
InvoiceAbstract.Status & 128 = 0 and
InvoiceAbstract.InvoiceType in (1, 2, 3)),
"Pending Order Quantity" = (select sum(Pending) from POAbstract, PODetail 
where PODetail.Product_Code = Items.Product_Code and
POAbstract.PONumber = PODetail.PONumber and
POAbstract.Status & 128 = 0 and
PODetail.Pending > 0), 
"Pending Order Value"= (select sum(Pending) * avg(PurchasePrice) from POAbstract, PODetail 
where PODetail.Product_Code = Items.Product_Code and
POAbstract.PONumber = PODetail.PONumber and
POAbstract.Status & 128 = 0 and
PODetail.Pending > 0), 
"No of Days With no Stock" = (select Datediff(Day,max(InvoiceAbstract.InvoiceDate), 
GetDate()) from InvoiceAbstract, InvoiceDetail 
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and
InvoiceDetail.Product_Code = Items.Product_Code and
InvoiceAbstract.Status & 128 = 0 and
InvoiceAbstract.InvoiceType in (1, 2, 3))
INTO #Temp
from Items, ItemCategories
where ItemCategories.CategoryID = Items.CategoryID And Items.Product_Code in (select Product_Code from Batch_Products 
group by Product_Code having sum(Quantity) <= @LessQty) and Items.active = 1 

INSERT INTO #Temp select Items.Product_Code, "Product Hierarchy First Level" = dbo.fn_FirstLevelCategory(Items.CategoryID), 
"Product Hierarchy Last Level" = ItemCategories.Category_Name, 
Items.Product_Code, Items.ProductName,
(select max(InvoiceAbstract.InvoiceDate) 
from InvoiceAbstract, InvoiceDetail 
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and
InvoiceDetail.Product_Code = Items.Product_Code and
InvoiceAbstract.Status & 128 = 0 and
InvoiceAbstract.InvoiceType in (1, 2, 3)),
(select sum(Pending) from POAbstract, PODetail 
where PODetail.Product_Code = Items.Product_Code and
POAbstract.PONumber = PODetail.PONumber and
POAbstract.Status & 128 = 0 and
PODetail.Pending > 0), 
(select sum(Pending) * avg(PurchasePrice) from POAbstract, PODetail 
where PODetail.Product_Code = Items.Product_Code and
POAbstract.PONumber = PODetail.PONumber and
POAbstract.Status & 128 = 0 and
PODetail.Pending > 0), 
"No of Days With no Stock" = (select Datediff(Day,max(InvoiceAbstract.InvoiceDate), GetDate()) 
from InvoiceAbstract, InvoiceDetail 
where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and
InvoiceDetail.Product_Code = Items.Product_Code and
InvoiceAbstract.Status & 128 = 0 and
InvoiceAbstract.InvoiceType in (1, 2, 3))
from Items, ItemCategories
where ItemCategories.CategoryID = Items.CategoryID And Items.Product_Code not in (select distinct(Product_Code) from Batch_Products) and 
Items.active = 1 

SET @SQL = 'SELECT [Product_Code], [Product Hierarchy First Level] As "' + @FirstLevel + '", [Product Hierarchy Last Level] As "' + @LastLevel + '", '  + 
	   '[Product Code], [Product Name], [Last Sale Date], [Pending Order Quantity], [Pending Order Value], [No of Days With no Stock] FROM #Temp'   
EXEC(@SQL)
DROP TABLE #Temp


