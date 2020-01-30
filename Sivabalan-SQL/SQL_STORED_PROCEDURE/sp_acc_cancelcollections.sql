CREATE procedure sp_acc_cancelcollections(@CollectionID Int)
as
Update Collections
Set Status = (isnull(status,0) | 192)
where DocumentID = @collectionid
and (isnull(Status,0) & 64)= 0
and IsNull(DepositID,0) = 0

