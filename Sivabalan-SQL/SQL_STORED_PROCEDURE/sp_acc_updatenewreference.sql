CREATE procedure sp_acc_updatenewreference(@AmendedID Int)as
Update ManualJournal
Set Status = 128
Where NewRefID = @AmendedID

