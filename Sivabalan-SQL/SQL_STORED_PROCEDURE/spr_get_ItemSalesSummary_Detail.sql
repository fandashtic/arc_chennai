CREATE procedure spr_get_ItemSalesSummary_Detail (@ProductCode nvarchar(50), @FromDate DateTime, @ToDate DateTime)
as
begin
select distinct DBO.StripDateFromTime(IA.InvoiceDate), "Invoice Date" = DBO.StripDateFromTime(IA.InvoiceDate),

"Quantity" = sum(case IA.InvoiceType when 4 then -IDt.Quantity else IDt.Quantity end), 
"Value" = Sum(case IA.InvoiceType when 4 then -IDt.Amount else IDt.Amount end)
from InvoiceAbstract IA, InvoiceDetail IDt
where
IA.InvoiceID = IDt.InvoiceID and 
IDt.Product_Code like @ProductCode and
IA.InvoiceDate between @FromDate and @ToDate and 
(IA.Status & 128) = 0 and 
(IA.Status & 192) = 0
group by DBO.StripDateFromTime(IA.InvoiceDate)
end


