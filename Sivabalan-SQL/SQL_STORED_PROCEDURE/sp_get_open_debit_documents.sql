CREATE PROCEDURE sp_get_open_debit_documents(@CUSTOMER nvarchar(15))
AS

select 4,
case InvoiceType
when 1 then
  VoucherPrefix.Prefix 
when 3 then
  InvPrefix.Prefix
end
+ CAST(DocumentID as nvarchar), "DocumentDate"=InvoiceDate, InvoiceID,Balance, 
NetValue
from InvoiceAbstract, VoucherPrefix,VoucherPrefix as InvPrefix
where InvoiceType in (1, 3) and
IsNull(Status, 0) & 128 = 0 and
CustomerID = @CUSTOMER and
ISNULL(Balance, 0) > 0 and
VoucherPrefix.TranID = 'INVOICE' and
InvPrefix.TranID = 'INVOICE AMENDMENT'

UNION 

select 5,VoucherPrefix.Prefix + cast(DocumentID as nvarchar), 
"DocumentDate"=DocumentDate,DebitID,Balance, NoteValue
from DebitNote, VoucherPrefix
where Balance > 0 and 
CustomerID = @CUSTOMER and 
TranID = 'DEBIT NOTE'

order by DocumentDate





