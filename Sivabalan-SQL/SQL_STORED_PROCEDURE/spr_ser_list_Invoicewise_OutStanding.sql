CREATE procedure spr_ser_list_Invoicewise_OutStanding(@FromDate datetime,
						  @ToDate datetime)
as
select InvAbs.InvoiceID,"Invoice ID" = InvPrefix.Prefix + cast(InvAbs.DocumentID as nvarchar),
"Doc Reference"=DocReference,"Invoice Date" = InvAbs.InvoiceDate,
"Payment Date" = InvAbs.PaymentDate,"Customer" = Customer.Company_Name,
"Amount" = InvAbs.NetValue,"OutStanding Amount" = case InvAbs.InvoiceType
			when 1 then InvAbs.Balance
			when 2 then InvAbs.Balance
			when 3 then InvAbs.Balance
			when 4 then 0 - InvAbs.Balance
			when 5 then 0 - InvAbs.Balance
			when 6 then 0 - InvAbs.Balance
			end,
"Due Days" = DateDiff(dd, InvAbs.InvoiceDate, GetDate()),
"OverDue Days" = Case When DateDiff(dd, InvAbs.PaymentDate, GetDate()) < 0 then
0 Else
DateDiff(dd, InvAbs.PaymentDate, GetDate())
End,"Rounded Net Value"  = NetValue + RoundOffAmount
from InvoiceAbstract as  InvAbs, Customer, VoucherPrefix as InvPrefix
where InvAbs.InvoiceDate between @FromDate and @ToDate and
InvAbs.InvoiceType in (1, 2, 3, 4, 5, 6) and
InvAbs.Status & 128 = 0 and
InvAbs.Balance > 0 and
InvAbs.CustomerID = Customer.CustomerID and
InvPrefix.TranID = 'INVOICE'

union

select SerAbs.ServiceInvoiceId,"Invoice ID" = SerPrefix.Prefix + cast(SerAbs.DocumentID as nvarchar),
"Doc Reference" = SerAbs.DocReference,"Invoice Date" = SerAbs.serviceInvoiceDate,
"Payment Date" =SerAbs.PaymentDate,"Customer" = Customer.Company_name,
"Amount" =  SerAbs.NetValue,"OutStanding Amount" = SerAbs.Balance,
"Due Days" =  DateDiff(dd,SerAbs.ServiceInvoiceDate,GetDate()),
"OverDue Days" = Case When DateDiff(dd, SerAbs.PaymentDate, GetDate()) < 0 then
0 Else 
DateDiff(dd, SerAbs.PaymentDate, GetDate())
End,"Rounded Net Value" = NetValue + RoundOffAmount
from ServiceInvoiceAbstract as  SerAbs,Customer,VoucherPrefix as SerPrefix
where SerAbs.ServiceInvoiceDate between @FromDate and @ToDate  
And IsNull(SerAbs.ServiceInvoiceType,0) = 1 
And IsNull(SerAbs.Status,0) & 192 = 0   
And SerAbs.Balance > 0 
And SerAbs.CustomerID = Customer.CustomerID and SerPrefix.TranID = 'SERVICEINVOICE'
order by "Invoice Date",Customer.Company_Name
