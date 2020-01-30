
-------------------------------------------------------------------------------------------------------------------------------------------------------------- 
CREATE PROCedure sprc_sales_by_ItemCategory_Beat_Items(@CATERY int,
						@Beatid int,
						@Customerid nvarchar(15),		
				                    @FROMDATE DATETIME,
					            @TODATE DATETIME)

As
	create table #temp (Product_Code nvarchar(15), ProductName nvarchar(255) , TotalValue decimal(18,2)) 
	insert into #temp
Select Items.Product_Code,"ProductName" = Items.ProductName, 
"TotalValue" = 	isnull(sum(invoicedetail.Amount) ,0)

from invoicedetail,InvoiceAbstract,ItemCategories,Items , customer
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoiceabstract.beatid = @beatid
and customer.customerid = invoiceabstract.customerid
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,3)
And ItemCategories.CategoryID = @CATERY
and items.CategoryID=Itemcategories.CategoryID 
and items.product_Code=invoiceDetail.product_Code and
InvoiceAbstract.CustomerID like @CustomerID
Group by Items.Product_Code,Items.ProductName

	insert into #temp

Select Items.Product_Code,"Product Name" = Items.ProductName, 
"TotalValue" = 	(0 - isnull(sum(InvoiceDetail.Amount),0))
from invoicedetail,InvoiceAbstract,ItemCategories,Items , customer
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoiceabstract.beatid = @beatid
and customer.customerid = invoiceabstract.customerid
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType = 4
And ItemCategories.CategoryID = @CATERY
and items.CategoryID=Itemcategories.CategoryID 
and items.product_Code=invoiceDetail.product_Code and
InvoiceAbstract.CustomerID like @CustomerID
Group by Items.Product_Code,Items.ProductName

	select  "Product_Code" = #temp.Product_Code , 
	"ProductName" = #temp.ProductName,
	"TotalValue" = isnull(sum(#temp.TotalValue),0)
	from #temp
	group by #temp.Product_Code, #temp.ProductName
	drop table #temp





