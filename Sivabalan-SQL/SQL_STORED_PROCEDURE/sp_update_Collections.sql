
CREATE procedure sp_update_Collections(	@DocumentID int, 
					@DepositDate datetime,
					@DepositTo int)
as
update Collections set Status = 1, DepositDate = @DepositDate, Deposit_to = @DepositTo
where DocumentID = @DocumentID

