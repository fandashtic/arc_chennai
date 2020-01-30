CREATE PROCEDURE sp_list_rec_Claims ( @CustomerID nvarchar(15),  
     @FROMDATE DATETIME,  
     @TODATE DATETIME)  
AS  
  
SELECT ClaimsNoteReceived.ClaimId, ClaimsNoteReceived.ClaimDate,  
ClaimsNoteReceived.CustomerID, Customer.Company_Name,ClaimsNoteReceived.ClaimId,   
ClaimsNoteReceived.Status,0, ClaimsNoteReceived.ClaimValue   
FROM ClaimsNoteReceived, Customer  
WHERE ClaimsNoteReceived.CustomerID LIKE @CustomerID AND  
ClaimsNoteReceived.ClaimDate BETWEEN @FROMDATE AND @TODATE AND  
ClaimsNoteReceived.CustomerID = Customer.CustomerID  
ORDER BY Customer.Company_Name, ClaimsNoteReceived.ClaimDate


