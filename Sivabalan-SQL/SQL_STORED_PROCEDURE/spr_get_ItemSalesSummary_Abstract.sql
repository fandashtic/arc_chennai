CREATE procedure spr_get_ItemSalesSummary_Abstract (@FromDate DateTime, @ToDate DateTime)
as
begin
select 
	It.Product_Code, "Item" = It.ProductName, 
	"Quantity" = sum(case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end), 
	"Value" = Sum(case IA.InvoiceType when 4 then -IDt.Amount else IDt.Amount end)
from InvoiceAbstract IA, InvoiceDetail IDt, Items It
where
	IA.InvoiceID = IDt.InvoiceID 
	and IDt.Product_Code = It.Product_Code 
	and IA.InvoiceDate between @FromDate and @ToDate 
	and (IA.Status & 192) = 0
group by It.Product_Code, It.ProductName 
end


