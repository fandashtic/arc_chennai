CREATE PROCEDURE sp_list_rec_Claims_DocLU (@FromDocID int, @ToDocID int)    
AS    
    
SELECT ClaimsNoteReceived.ClaimId, ClaimsNoteReceived.ClaimDate,    
ClaimsNoteReceived.CustomerID, Customer.Company_Name, ClaimsNoteReceived.ClaimId,     
ClaimsNoteReceived.Status, 0, ClaimsNoteReceived.ClaimValue     
FROM ClaimsNoteReceived, Customer  
WHERE DocSerial BETWEEN @FromDocID AND @ToDocID AND    
ClaimsNoteReceived.CustomerID = Customer.CustomerID    
ORDER BY Customer.Company_Name, ClaimsNoteReceived.ClaimDate   

