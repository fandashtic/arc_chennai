CREATE procedure sp_list_Customer_OutStanding_Invoices (@Customer nvarchar(15), @Outstanding nvarchar(255))   
as  
declare @invtype nvarchar(100)      
select   
"Invoice ID" = InvPrefix.Prefix      
+ cast(InvoiceAbstract.DocumentID as nvarchar),      
"Doc Reference"=DocReference,      
"Date" = InvoiceAbstract.InvoiceDate,   
"Amount" = case InvoiceType      
  when 4 then 0 - InvoiceAbstract.NetValue   
  else InvoiceAbstract.NetValue   
  end,      
"Balance" = case InvoiceType       
  when 4 then 0 - InvoiceAbstract.Balance   
  else InvoiceAbstract.Balance   
  end,       
"Over Due Days" = datediff(dd, InvoiceAbstract.PaymentDate, GetDate()),      
"Doc Type" = dbo.LookupDictionaryItem(case InvoiceAbstract.InvoiceType      
  when 1 then N'Invoice'   
  when 3 then N'Invoice Amendment'   
  when 4 then N'Sales Return'   
  else N''   
  end, Default)  
from InvoiceAbstract, VoucherPrefix as InvPrefix      
where InvoiceAbstract.CustomerID = @Customer and      
InvoiceAbstract.Status & 128 = 0 and      
InvoiceAbstract.InvoiceType in (1, 3, 4) and      
InvoiceAbstract.Balance > 0 and      
InvPrefix.TranID = N'INVOICE' AND      
datediff(dd, InvoiceAbstract.PaymentDate, GetDate()) > isnull(@Outstanding, 0)

