
CREATE procedure spr_ser_get_ItemSalesSummary_Detail(@ProductCode nvarchar(50), @FromDate DateTime, @ToDate DateTime)
as

Create table #ItemTemp(InvDate1 datetime null,InvDate datetime null,Qty Decimal(18,6),Netvalue decimal(18,6))

Insert into #ItemTemp
select distinct DBO.StripDateFromTime(InvAbs.InvoiceDate), 
"Invoice Date" = DBO.StripDateFromTime(InvAbs.InvoiceDate),
"Quantity" = sum(case InvAbs.InvoiceType when 4 then -InvDet.Quantity else InvDet.Quantity end), 
"Value" = Sum(case InvAbs.InvoiceType when 4 then -InvDet.Amount else InvDet.Amount end)
from InvoiceAbstract InvAbs, InvoiceDetail InvDet
where InvAbs.InvoiceID = InvDet.InvoiceID and 
InvDet.Product_Code like @ProductCode and
InvAbs.InvoiceDate between @FromDate and @ToDate and 
(IsNull(InvAbs.Status,0) & 128) = 0 and 
(IsNull(InvAbs.Status,0) & 192) = 0
group by DBO.StripDateFromTime(InvAbs.InvoiceDate)

Insert into #ItemTemp
select distinct DBO.StripDateFromTime(SerAbs.Serviceinvoicedate),"Invoice Date" = DBO.StripDateFromTime(SerAbs.Serviceinvoicedate),
"Quantity" = sum(SerDet.Quantity),
"Value" = sum(SerDet.Netvalue)
from serviceinvoiceabstract SerAbs,serviceinvoicedetail SerDet,Items I
where	SerAbs.serviceinvoiceid   = SerDet.serviceinvoiceid 
	and I.Product_code = SerDet.SpareCode  
	and SerDet.sparecode like  @Productcode
	and SerAbs.Serviceinvoicedate between @Fromdate and @Todate
	and IsNull(SerAbs.ServiceInvoiceType,0) = 1 
	and IsNull(SerAbs.Status,0) & 192 = 0 
	and IsNull(SerDet.SpareCode, '') <> '' 	
group by DBO.StripDateFromTime(SerAbs.Serviceinvoicedate)

Select InvDate1,InvDate as "Invoice Date",sum(Qty) as Quantity,sum(Netvalue) as Value from #ItemTemp group by InvDate1,InvDate order by InvDate1,InvDate

Drop Table #ItemTemp



