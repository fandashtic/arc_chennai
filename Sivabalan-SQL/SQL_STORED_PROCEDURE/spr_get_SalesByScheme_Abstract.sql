CREATE procedure spr_get_SalesByScheme_Abstract (@FromDate Datetime, @ToDate DateTime)
as
begin
select ltrim(rtrim(It.Product_Code)) + char(15) + ltrim(rtrim(Sch.SchemeID)), 
	"Scheme Name" = sch.schemename, "Item Name" = It.ProductName,
	"No of Customers" = count(distinct IA.CustomerID), 
	"No of Invoices" = count(distinct IA.InvoiceID)
from 
	Schemes Sch, Items It, SchemeSale SchS, InvoiceAbstract IA, InvoiceDetail IDt
where 
	Sch.schemeid = SchS.Type 
	and SchS.InvoiceID = IA.InvoiceID 
	and SchS.Product_Code = It.Product_Code 
	and SchS.Product_Code = IDt.Product_Code 
	and IDt.InvoiceID = IA.InvoiceID 
	and IA.InvoiceDate between @FromDate and @ToDate 
	and IA.InvoiceType not in (4)
	and (IA.Status & 192)=0
group by 
	sch.schemeid, sch.schemename, It.ProductName, It.Product_Code
order by 
	sch.schemeid, It.ProductName
end





