
CREATE procedure spr_list_freeschemes(@fromdate datetime, @todate datetime)
as
select SchemeSale.Type, "Description" = Schemes.SchemeName, "Total Invoices" = Count(distinct(InvoiceID))
from SchemeSale, Schemes
where 	InvoiceID in (select InvoiceID from InvoiceAbstract where InvoiceDate Between @fromdate and @todate and (IsNull(Status,0) & 192) = 0)  
	and Schemes.SchemeID = SchemeSale.Type
group by SchemeSale.Type, Schemes.SchemeName

