CREATE procedure sp_acc_updateadvancecollection(@DocumentID Int,
@AdjustedAmount Decimal(18,6))
as
update Collections set Balance = Balance - @AdjustedAmount
where DocumentID = @DocumentID

