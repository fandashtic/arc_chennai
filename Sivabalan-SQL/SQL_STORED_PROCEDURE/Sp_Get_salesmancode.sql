Create Procedure Sp_Get_salesmancode(@salesmancode Nvarchar(255) = null) as    
Select Code,salesmanid From WcpAbstract     
 where  salesmanid = @salesmancode  
 and (isnull(status,0)&128)=0     
 And (isnull(status,0)& 32)=0  

