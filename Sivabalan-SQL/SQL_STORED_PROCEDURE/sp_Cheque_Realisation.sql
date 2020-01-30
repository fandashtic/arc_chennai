
create procedure sp_Cheque_Realisation (@ClearingAmount Decimal(18,6),
										@Realised int,
										@RealisationDate datetime,
										@BankCharges Decimal(18,6),
										@DocumentID int)
as
Update Collections Set ClearingAmount = @ClearingAmount, Realised = @Realised,
RealisationDate = @RealisationDate, BankCharges = @BankCharges 
Where DocumentID = @DocumentID


