Create View [dbo].[V_Supervisor_Salesman]
([SupervisorID], [SalesmanID]) 
As
select TS.SupervisorID,TS.SalesmanID from  (select TSS.SupervisorID as SupervisorID, TSS.SalesmanID as SalesmanID from tbl_mERP_SupervisorSalesman TSS 
union
select TSS.SalesmanID 'SupervisorID', S.SalesmanID from salesman2 TSS, salesman S 
where TSS.SalesmanID not in (select SupervisorID from tbl_mERP_SupervisorSalesman)) TS
	inner join 
	(SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
		on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS
	on HHS.Salesmanid=TS.Salesmanid

