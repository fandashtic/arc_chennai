CREATE Procedure sp_view_rec_ClaimsNote (@ClaimID nvarchar(50))
As
Select ClaimsNoteReceived.ClaimDate, ClaimsNoteReceived.CustomerID, Customer.Company_Name, 
ClaimsNoteReceived.ClaimID, ClaimsNoteReceived.ClaimType,  
ClaimsNoteReceived.DocReference, ClaimsNoteReceived.Status
FROM ClaimsNoteReceived, Customer  
Where ClaimsNoteReceived.ClaimID = @ClaimID And
ClaimsNoteReceived.CustomerID = Customer.CustomerID 


