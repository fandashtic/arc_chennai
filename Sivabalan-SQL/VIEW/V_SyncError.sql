Create View V_SyncError   
([TRANSACTIONID], [TRANSACTIONTYPE], [UNIQUEID], [SALESMANID], [MSGDATE], [MSGTYPE], [MSGACTION], [MSGDESCRIPTION])  
as  
Select SynErr.[TRANSACTIONID],  
SynErr.[TRANSACTIONTYPE],  
SynErr.[UNIQUEID],  
SynErr.[SALESMANID],  
SynErr.[CREATIONDATE],   
SynErr.[MSGTYPE],
SynErr.[MSGACTION],
SynErr.[MSGDESCRIPTION]  
from SyncError SynErr 
inner join 
(SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
  on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS
on HHS.Salesmanid=SynErr.Salesmanid 
where dbo.StripTimeFromDate(SynErr.CreationDate) between dbo.StripTimeFromDate(dateadd(d,-6,dbo.StripTimeFromDate((select transactiondate from setup)))) and dbo.StripTimeFromDate((select transactiondate from setup)) 
