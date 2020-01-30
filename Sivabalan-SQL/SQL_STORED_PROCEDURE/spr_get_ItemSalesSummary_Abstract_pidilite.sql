CREATE procedure spr_get_ItemSalesSummary_Abstract_pidilite (@FromDate DateTime, @ToDate DateTime)
as
begin
select 
	It.Product_Code, "Item" = It.ProductName, 
	"Quantity" = sum(case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end),
	"Reporting UOM" = sum((case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end) / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),
	"Conversion Factor" = sum((case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end) * IsNull(ConversionFactor, 0)), 
	"Value" = Sum(case IA.InvoiceType when 4 then -IDt.Amount else IDt.Amount end)
from InvoiceAbstract IA, InvoiceDetail IDt, Items It
where
	IA.InvoiceID = IDt.InvoiceID 
	and IDt.Product_Code = It.Product_Code 
	and IA.InvoiceDate between @FromDate and @ToDate 
	and (IA.Status & 192) = 0
group by It.Product_Code, It.ProductName 
end


