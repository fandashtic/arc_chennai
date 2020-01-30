CREATE Procedure sp_acc_cancel_ARV (@DocumentID int,@CancellationRemarks nVarchar(4000) = NULL)
as 
Update ARVAbstract 
Set Status = (isnull(Status,0) | 192),
CancellationRemarks = @CancellationRemarks
where Documentid = @DocumentID
