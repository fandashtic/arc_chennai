
Create Procedure dbo.[FSU_sp_UpdateMsgStatus](
@ReleaseID Int,
@nStatus Int)
As 
Update dbo.tblmessagedetail Set Status = Status | @nStatus , ModifiedDate=getdate(),ModifiedApplication = app_name() , ModifiedUser=host_name() + ' - ' + suser_sname() Where ReleaseID = @ReleaseID
