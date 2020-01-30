CREATE PROCEDURE sp_ser_get_open_documents(@CUSTOMER nvarchar(15))
AS
Select 2, Prefix + CAST(DocumentID AS varchar), DocumentDate, CreditID, Balance, 
NoteValue, DocumentReference From CreditNote, VoucherPrefix
Where Balance > 0 And CustomerID = @CUSTOMER AND TranID = 'CREDIT NOTE'

UNION

select 3, FullDocID, DocumentDate, DocumentID, Balance, Value, DocumentReference
from Collections
where Balance > 0 and
CustomerID = @CUSTOMER And 
IsNull(Status, 0) & 128 = 0


