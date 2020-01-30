CREATE procedure spr_get_SalesmanSalesSummary_Detail (@SalesmanID nvarchar(50), @FromDate DateTime, @ToDate DateTime)
as
begin

select 
	distinct DBO.StripDateFromTime(IA.InvoiceDate) , "Invoice Date" = DBO.StripDateFromTime(IA.InvoiceDate), 
	"Quantity" = Sum(IDt.Quantity),
	"Value" = sum(case IA.InvoiceType when 4 then -IDt.Amount else IDt.Amount end)
from InvoiceAbstract IA, InvoiceDetail IDt
where
	IA.InvoiceID = IDt.InvoiceID 
	and isnull(IA.SalesmanID,0) = @SalesmanID 
	and IA.InvoiceDate between @FromDate and @ToDate 
	and (IA.Status & 192) = 0
	--and IA.InvoiceType <> 2
	and IA.InvoiceType not in (2,5,6)
group by DBO.StripDateFromTime(IA.InvoiceDate)
end




