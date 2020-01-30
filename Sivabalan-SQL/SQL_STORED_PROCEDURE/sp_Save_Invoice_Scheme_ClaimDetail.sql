CREATE Procedure sp_Save_Invoice_Scheme_ClaimDetail(@ClaimID Integer, @InvID Integer, @ClaimAmt Decimal(18,6),@Serial int =0)    
As    
Insert into ClaimsDetail (ClaimID, InvoiceID, ClaimAmount,Serial)    
Values (@ClaimID, @InvID, @ClaimAmt,@Serial)    
  
Update InvoiceAbstract Set ClaimedAlready = 1, ClaimedAmount = isnull(ClaimedAmount, 0) + @ClaimAmt Where InvoiceID = @InvID  


