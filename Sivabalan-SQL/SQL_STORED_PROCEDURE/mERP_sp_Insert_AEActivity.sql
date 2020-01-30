Create procedure mERP_sp_Insert_AEActivity(
@AEUser nVarchar(250), @AEModuleID nVarchar(50), @MachineID nVarchar(255), @ForumUserID nVarchar(255), @IPAddress nVarchar(255),
@LoginType Int = 1
)
As
Begin
  /* Update prev Activity status, If open */
  If Exists(Select ID From tbl_mERP_AEActivity Where UserName = @AEUser And AEModuleID = @AEModuleID And (Status & 128)= 0 And MachineID = @MachineID)
  Begin
    Update tbl_mERP_AEActivity Set Status = Status|128 Where UserName = @AEUser And AEModuleID = @AEModuleID And MachineID = @MachineID And Status & 128 = 0
  End 
  /* New Record */	
  Insert into tbl_mERP_AEActivity(UserName, AEModuleID, MachineID, ForumUserID, IPAddress,Login_Type) Values 
  (@AEUser, @AEModuleID, @MachineID, @ForumUserID, @IPAddress ,@LoginType)
  Select @@IDentity
End
