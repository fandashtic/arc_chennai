CREATE procedure spr_get_ItemSalesSummary_Detail_pidilite (@ProductCode nvarchar(50), @FromDate DateTime, @ToDate DateTime)
as
begin
select distinct DBO.StripDateFromTime(IA.InvoiceDate), "Invoice Date" = DBO.StripDateFromTime(IA.InvoiceDate),

"Quantity" = sum(case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end), 
"Reporting UOM" = sum((case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end) / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),
"Conversion Factor" = sum((case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end) * IsNull(ConversionFactor, 0)),
"Value" = Sum(case IA.InvoiceType when 4 then -IDt.Amount else IDt.Amount end)
from InvoiceAbstract IA, InvoiceDetail IDt, Items
where
IA.InvoiceID = IDt.InvoiceID and 
IDt.Product_Code = Items.Product_Code and
IDt.Product_Code like @ProductCode and
IA.InvoiceDate between @FromDate and @ToDate and 
(IA.Status & 128) = 0 and 
(IA.Status & 192) = 0
group by DBO.StripDateFromTime(IA.InvoiceDate)
end


