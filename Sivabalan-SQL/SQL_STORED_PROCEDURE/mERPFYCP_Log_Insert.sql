Create PROCEDURE mERPFYCP_Log_Insert (@CompanyID nvarchar(15)  
, @Procedure_name nvarchar(100) = Null    
, @Stage_Name nvarchar(100) = Null    
, @Log_Message nvarchar(4000) = Null    
, @No_of_record_del int = Null ) as     
Insert Into ForumMessageClient.dbo.mERPFYCP_Log( CompanyID, Procedure_name, Stage_Name,Log_Message, No_of_record_del)values(@CompanyID, @Procedure_name, @Stage_Name, @Log_Message, @No_of_record_del)
