
Create Procedure mERP_sp_Update_AEActivity(@AEUser nVarchar(250), @AEModuleID nVarchar(50), @MachineID nVarchar(255))
As
Begin
  Update tbl_mERP_AEActivity Set Status = Status | 128 
  Where UserName = @AEUser And AEModuleID = @AEModuleID And MachineID = @MachineID And Status & 128 = 0
End
