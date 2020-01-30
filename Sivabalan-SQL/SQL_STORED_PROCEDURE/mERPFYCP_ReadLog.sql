Create Procedure mERPFYCP_ReadLog
As
select Log_Date,
Procedure_name,
Stage_Name,
Log_Message,
No_of_record_del
from  ForumMessageClient.dbo.mERPFYCP_log
