
-------------------------------------------------------------------------------------------------------------------
CREATE procedure sprc_sales_by_ItemCategory_Beat(@CATERY int,
						@Beatid int,
						@Customerid nvarchar(15),		
				                    @FROMDATE DATETIME,
					            @TODATE DATETIME)

As
create table #sales(CategoryID nvarchar(15), Category_Name nvarchar(255) , TotalValue decimal(18,2)) 
insert into #sales

Select Items.CategoryID,"Category Name" = ItemCategories.Category_Name, 
"TotalValue" = 	isnull(sum(InvoiceDetail.Amount),0) 

from invoicedetail,InvoiceAbstract,ItemCategories,Items , customer
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoiceabstract.beatid = @beatid
and customer.customerid = invoiceabstract.customerid
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType  in (1,3)
And ItemCategories.CategoryID = @CATERY
and items.CategoryID=Itemcategories.CategoryID 
and items.product_Code=invoiceDetail.product_Code and
InvoiceAbstract.CustomerID like @CustomerID
Group by Items.CategoryID,ItemCategories.Category_Name

	insert into #sales 
	Select Items.CategoryID,"Category Name" = ItemCategories.Category_Name, 
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
Group by Items.CategoryID,ItemCategories.Category_Name

	select  #Sales.CategoryID , 
	#Sales.Category_Name,
	"TotalValue" = isnull(sum(#Sales.TotalValue),0)
	from #sales 
	group by #sales.CategoryID, #sales.Category_Name 
	drop table #sales


