
Create Procedure dbo.FSU_sp_UpdateReleasetableStatus 
(
@ReleaseId Int, 
@Status Int,
@Reset int)
As 
	Update dbo.tblReleaseDetail set Status = Status | @Status Where ReleaseId = @ReleaseId
	if @Reset = 1
	begin
		Update dbo.tblReleaseDetail set Status = Status ^ 64 Where ReleaseId = @ReleaseId and Status & 64 = 64
	end
