
create Procedure FSU_sp_getClientID(    
@MachineID varchar(50),    
@Node varchar(4000)    
)    
as  
Begin
 -- We don't need @MachineID parameter but since this SP is used in many places, we are not changing the parameters.   
 Select Max(ClientID) as ClientID from tblClientMaster where node=@node      
End  
  
