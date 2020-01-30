Create Procedure mERP_sp_Get_AESessionValidity(@AELoginName nVarchar(50), @ModuleID Int, @MachineID nVarchar(25))    
As
Begin
  Declare @RecentUpdateTime DateTime   
  Declare @CurrentTime DateTime
  Declare @ActiveUser nVarchar(250)
  Declare @ActiveMC nVarchar(250)
  Set @CurrentTime = GetDate()
  
  
  /*Select @ActiveUser = UserName, @ActiveMC = MachineID 
  From tbl_mERP_AEActivity Where AEModuleID = @ModuleID And Status & 128 = 0 */

  Select Top 1 @ActiveUser = UserName, @ActiveMC = MachineID 
  From tbl_mERP_AEActivity Where AEModuleID = @ModuleID And Status & 128 = 0
  GROUP BY UserName, MachineID 
  ORDER BY mAX(ID) dESC	


  
  If (@AELoginName <> @ActiveUser) Or (@ActiveMC <> @MachineID)
    Select 2 
  Begin
    Select @RecentUpdateTime = Max(CreationTime) 
    From tbl_mERP_AEAuditLog    
    Where AEUserName = @AELoginName And
    AEModuleID = @ModuleID 
    --MachineID = @MachineID And
    --(Status & 128)= 0 
    If Abs(DateDiff(mi,@CurrentTime,@RecentUpdateTime)) > 10     
      Select 1
    Else    
      Select 0      
  End
End
