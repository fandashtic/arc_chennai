CREATE VIEW  [v_Salesman]  
([Salesman_ID],[Salesman_Name],[Address],[Phone],[Active], [SMSAlert])  
AS  
SELECT     S.SalesmanID, S.Salesman_Name, S.Address,S.Mobilenumber,S.Active, 
	Case When IsNull(S.SMSAlert, 0) = 0 Then 'No' Else 'Yes' End 
FROM       Salesman S 
inner join 
(SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
  on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS
on HHS.Salesmanid=S.Salesmanid
