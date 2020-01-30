Create procedure mERP_sp_Insert_AEActivity_Log(@AEUser nVarchar(250), @AEModuleID nVarchar(50), @TaskDesc nVarchar(255),@AEActivityID Int,@Menu nVarchar(255)=NULL)  
As  
Begin  
Declare @LogID  Int 
  If isnull(@Menu,'') = ''
	Begin
		Set @Menu = Null
	End
  If @TaskDesc =N'Outlet Classification Changed'
  Begin
	set @TaskDesc = 'OUTLET CLASSIFICATION CHANGED'
  End
  Insert into tbl_mERP_AEAuditLog(AEUserName, AEModuleID, TaskName,AEActivityID,Menu) Values (@AEUser, @AEModuleID, @TaskDesc,@AEActivityID,@Menu)  
  Select @LogID = @@IDentity
  
  Update AEAct Set AEAct.ActivityTimeStamp = AELog.CreationTime 
  From tbl_mERP_AEActivity AEAct, tbl_mERP_AEAuditLog AELog
  Where AEAct.USerName = AELog.AEUserName And 
  AEAct.AEModuleID = AELog.AEModuleID And 
  AEAct.Status & 128 = 0 And 
  AELog.ID = @LogID 

  Select @LogID
End
