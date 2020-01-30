CREATE procedure sp_view_PaymentDetail(@PaymentID as int)  
as  
select "OriginalID" = OriginalID, "DocumentDate" = DocumentDate, "DocumentValue" = DocumentValue, 
"AdjustedAmount" = AdjustedAmount, "DocumentTypeID" = DocumentType, 
"DocumentReference" = DocumentReference, "ExtraCol" = ExtraCol, "Adjustment" = Adjustment, 
"DocumentID" = DocumentID,
"DocumentType" = case DocumentType 
		when 1 then 'Purchase Return'
		when 2 then 'Debit Note'
		when 3 then 'Payments'
		when 4 then 'Bill'
		when 5 then 'Credit Note' end
from PaymentDetail  
where PaymentID = @PaymentID  
  
  


