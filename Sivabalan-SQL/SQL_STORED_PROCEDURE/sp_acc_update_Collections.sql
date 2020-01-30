




CREATE procedure sp_acc_update_Collections(@DocumentID int, 
					@DepositDate datetime,
					@BankID int,
					@DepositID Int)
as
update Collections set Status = 1, DepositDate = @DepositDate, Deposit_to = @BankID,DepositID=@DepositID
where DocumentID = @DocumentID






