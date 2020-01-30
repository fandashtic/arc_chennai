create procedure sp_acc_cancelnewreference(@NewRefID Int)
as
Update ManualJournal
Set Status = 192
Where NewRefID = @NewRefID


