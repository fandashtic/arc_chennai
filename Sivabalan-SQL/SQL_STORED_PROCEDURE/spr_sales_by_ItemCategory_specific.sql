
CREATE procedure spr_sales_by_ItemCategory_specific(@CATERY int,
				                    @FROMDATE DATETIME,
					            @TODATE DATETIME)
As
Select Items.CategoryID,"Category Name" = ItemCategories.Category_Name, 
"Net Value (Rs)" = sum(Amount) 
from invoicedetail,InvoiceAbstract,ItemCategories,Items 
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)
And ItemCategories.CategoryID = @CATERY
and items.CategoryID=Itemcategories.CategoryID 
and items.product_Code=invoiceDetail.product_Code
Group by Items.CategoryID,ItemCategories.Category_Name

