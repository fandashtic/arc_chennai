
CREATE procedure spr_sales_by_brand_FMCG
                (@BRANDNAME NVARCHAR (255),
                 @FROMDATE DATETIME,
                 @TODATE DATETIME)
As
Select Items.BrandID,"Brand Name" = Brand.BrandName, 
"Net Value (%c)" = sum(Amount) 
from invoicedetail,InvoiceAbstract,Brand,Items 
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID 
and invoicedate between @FROMDATE and @TODATE
And InvoiceAbstract.Status&128=0 and InvoiceAbstract.InvoiceType in (1,2,3)
And Brand.BrandName Like @BRANDNAME
and items.BrandID=Brand.BrandID 
and items.product_Code=invoiceDetail.product_Code
Group by Items.BrandID,Brand.BrandName

