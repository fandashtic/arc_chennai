CREATE procedure spr_list_PaymentDetail(@PaymentID integer)
as
select PaymentDetail.OriginalID,
"Document ID" = PaymentDetail.OriginalID,
"Date" = PaymentDetail.DocumentDate,
"Type" = case DocumentType
when 1 then
'Purchase Return'
when 2 then
'Debit Note'
when 3 then
'Payments'
when 4 then
'Purchase'
when 5 then
'Credit Note'
When 6 then
'Claims Note'
end,
"Document Reference"=PaymentDetail.DocumentReference,
"Document Value" = PaymentDetail.DocumentValue,
"Adj Amount" = case DocumentType
when 1 then
'-'
when 2 then
'-'
when 3 then
'-'
when 4 then
'+'
when 5 then
'+'
When 6 then
'-'
end
+ cast(PaymentDetail.AdjustedAmount as nvarchar)
from PaymentDetail
where PaymentID = @PaymentID

