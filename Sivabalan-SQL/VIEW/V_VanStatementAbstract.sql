CREATE  VIEW [dbo].[V_VanStatementAbstract] 
([DocumentID],[DocumentDate],[SalesmanID],[VanID],[Status])
AS
SELECT 	VSA.DocumentID,VSA.DocumentDate,VSA.SalesmanID,VSA.VanID,VSA.Status
from 	VanStatementAbstract VSA
inner join 
(SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
  on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS
on HHS.Salesmanid=VSA.Salesmanid 
