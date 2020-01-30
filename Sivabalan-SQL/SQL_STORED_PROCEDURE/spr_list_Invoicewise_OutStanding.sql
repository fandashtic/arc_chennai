CREATE procedure spr_list_Invoicewise_OutStanding(@FromDate datetime,
						  @ToDate datetime)
as
select InvoiceAbstract.InvoiceID, 
"InvoiceID" = Case ISNULL(GSTFlag,0)
 When 0 then InvPrefix.Prefix
+ cast(InvoiceAbstract.DocumentID as nvarchar)
 Else ISNULL(InvoiceAbstract.GSTFullDocID,'')
 END,
"Doc Reference"=DocReference,
"Invoice Date" = InvoiceAbstract.InvoiceDate,
"Payment Date" = InvoiceAbstract.PaymentDate,
"Customer" = Customer.Company_Name,
"Amount" = InvoiceAbstract.NetValue,
"OutStanding Amount" = case InvoiceAbstract.InvoiceType
			when 1 then InvoiceAbstract.Balance
			when 2 then InvoiceAbstract.Balance
			when 3 then InvoiceAbstract.Balance
			when 4 then 0 - InvoiceAbstract.Balance
			when 5 then 0 - InvoiceAbstract.Balance
			when 6 then 0 - InvoiceAbstract.Balance
			end,
"Due Days" = DateDiff(dd, InvoiceAbstract.InvoiceDate, GetDate()),
"OverDue Days" = Case 
When DateDiff(dd, InvoiceAbstract.PaymentDate, GetDate()) < 0 then
0
Else
DateDiff(dd, InvoiceAbstract.PaymentDate, GetDate())
End,
"Rounded Net Value"  = NetValue + RoundOffAmount
from InvoiceAbstract, Customer, VoucherPrefix as InvPrefix
where InvoiceAbstract.InvoiceDate between @FromDate and @ToDate and
InvoiceAbstract.InvoiceType in (1, 2, 3, 4, 5, 6) and
InvoiceAbstract.Status & 128 = 0 and
InvoiceAbstract.Balance > 0 and
InvoiceAbstract.CustomerID = Customer.CustomerID and
InvPrefix.TranID = 'INVOICE'
order by Customer.Company_Name, InvoiceAbstract.InvoiceDate



