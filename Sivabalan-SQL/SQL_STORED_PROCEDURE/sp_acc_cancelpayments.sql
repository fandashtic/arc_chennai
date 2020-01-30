CREATE procedure sp_acc_cancelpayments(@paymentid integer,@denominations nvarchar(2000),@Remarks nvarchar(4000) = NULL)  
as  
Update Payments  
set Status =192,  
Denominations = @denominations,  
Remarks = @Remarks  
where [DocumentID]= @paymentid 

--Revert Used cheque details in cheques table
If Exists(Select Paymentmode From Payments Where DocumentID = @paymentid and 
		((PaymentMode = 1 and Cheque_ID <> 0) or (PaymentMode = 2 and DDMode = 1 
		and Cheque_ID <> 0)))
Begin
	Update Cheques Set UsedCheques = UsedCheques - 1 Where ChequeID = (Select Cheque_ID From Payments Where DocumentID =@paymentid)
End


