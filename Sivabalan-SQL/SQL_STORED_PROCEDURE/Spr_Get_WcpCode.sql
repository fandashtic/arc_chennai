CREATE Procedure Spr_Get_WcpCode( @WcpCode Bigint) as  
Select Code From WcpAbstract   
Where Code= @WcpCode  
 And (isnull(status,0)&128)=0   
 And (isnull(status,0)& 32)=0  
  


