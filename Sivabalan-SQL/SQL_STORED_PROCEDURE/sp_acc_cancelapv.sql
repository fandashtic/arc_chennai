CREATE procedure sp_acc_cancelapv(@apvid integer,@CancellationRemarks nVarchar(4000) = NULL)
as
update APVAbstract
Set Status = (isnull(Status,0) | 192),
CancellationRemarks = @CancellationRemarks
where [DocumentID]= @apvid
