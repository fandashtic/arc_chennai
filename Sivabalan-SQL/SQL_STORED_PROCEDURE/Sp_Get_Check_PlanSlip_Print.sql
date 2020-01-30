CREATE procedure Sp_Get_Check_PlanSlip_Print (@salesmanid nvarchar(15), @WcpDate datetime) as      
select code from wcpdetail where code in ( select code from wcpabstract where salesmanid =@salesmanid  And (isnull(status,0)&128)=0 And (isnull(status,0)& 32)=0   ) and wcpdate =@wcpdate    
  


