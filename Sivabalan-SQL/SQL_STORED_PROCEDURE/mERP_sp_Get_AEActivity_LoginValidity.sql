Create Procedure mERP_sp_Get_AEActivity_LoginValidity(@AELoginName nVarchar(50), @ModuleID Int, @MachineID nVarchar(25))      
As      
Begin      
Declare @RecentUpdateTime DateTime      
Declare @UpdatedFromMacID nVarchar(50)      
Declare @LoginAEUser nVarchar(50)      
Declare @CurrentTime DateTime  
Declare @Status Int       
Declare @Cnt Int 
Declare @ModID int       
Set @CurrentTime = Getdate()


if Exists(select * from tbl_mERP_AEActivity where (Status & 128)=0 and MachineID<>@MachineID and AEModuleID=@ModuleID and UserName<>@AELoginName)
  Select 0
Else
Begin
	Select @Cnt = Count(*), @LoginAEUser = UserName, 
	@RecentUpdateTime = Max(ActivityTimeStamp), 
	@UpdatedFromMacID =MachineID, 
	@Status = Status,
	@ModID=AEModuleID       
	From tbl_mERP_AEActivity       
	Where --UserName = @AELoginName     
	AEModuleID = @ModuleID And
	MachineID=@MachineID And
	(Status & 128)= 0         
	Group By UserName, MachineID, Status,AEModuleID
	If @CNT > 0       
	Begin	      
	  If @UpdatedFromMacID = @MachineID   
	  Begin  
		Select 1  
	  End      
	  Else       
	  Begin      
		If Abs(DateDiff(mi,@CurrentTime,@RecentUpdateTime)) > 10       
		  Select 1      
		Else                
		  Select 0    
	  End      
	End      
	Else      
	  Select 1      
	End
End  
