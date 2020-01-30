
CREATE procedure spr_sales_by_branddetails
                (@BRANDID INT,
                 @FROMDATE DATETIME,
                 @TODATE DATETIME)
As
Select InvoiceDetail.Product_Code,"Item Name" = Items.ProductName,
"Total Value (Rs)" = sum(Amount) 
from invoicedetail,Items,InvoiceAbstract 
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)
And Items.Brandid=@BRANDID 
and items.product_Code=invoiceDetail.product_Code
Group by InvoiceDetail.Product_Code,Items.ProductName

