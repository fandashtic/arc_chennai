create FUNCTION sprc_sales_by_ItemCategory_Beat_Value (@CATERY int,
							@Beatid int,
							@Customerid nvarchar(15),		
					                @FROMDATE DATETIME,
					            	@TODATE DATETIME)
returns float
As
begin
DECLARE @TotalValue float
Select @TotalValue = isnull(sum(case invoicetype when 4 then 0-InvoiceDetail.Amount else InvoiceDetail.Amount end),0) 
from invoicedetail,InvoiceAbstract,ItemCategories,Items , customer
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoiceabstract.beatid = @beatid
and customer.customerid = invoiceabstract.customerid
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType  in (1,3, 4)
And ItemCategories.CategoryID = @CATERY
and items.CategoryID=Itemcategories.CategoryID 
and items.product_Code=invoiceDetail.product_Code and
InvoiceAbstract.CustomerID like @CustomerID
Group by Items.CategoryID,ItemCategories.Category_Name
RETURN @TotalValue
end
