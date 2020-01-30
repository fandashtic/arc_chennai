Create procedure sp_acc_Cheque_Realisation 
(
	@ClearingAmount Float,
	@Realised Int,
	@RealisationDate Datetime,
	@BankCharges Float,
	@DocumentID Int
)
As
Begin
	Update Collections Set ClearingAmount = @ClearingAmount, Realised = @Realised,
	RealisationDate = @RealisationDate, BankCharges = @BankCharges 
	Where DocumentID = @DocumentID

	If Exists(Select * From ChequeCollDetails Where IsNull(RepresentID,0) = @DocumentID)
		Update ChequeCollDetails Set ChqStatus = @Realised,RealiseDate=@RealisationDate Where RepresentID = @DocumentID
	Else
		Update ChequeCollDetails Set ChqStatus = @Realised,RealiseDate=@RealisationDate Where CollectionID = @DocumentID
End
