create procedure sp_acc_updatecancelcollection(@CollectionID Int,
@AmountAdjusted Decimal(18,6))
as
Update Collections
Set Balance = Balance + @AmountAdjusted
Where DocumentID = @CollectionID


