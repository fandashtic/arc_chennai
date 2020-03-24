--select * from tbl_mERP_PMMaster Where Period = 'Feb-2020'
select * into tbl_mERP_PMetric_TargetDefn_Backup_25_Feb_2020 From tbl_mERP_PMetric_TargetDefn

select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 16 AND DSTypeID = 34 AND DSTypeCGMapID = 170
select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 30 AND DSTypeID = 15 AND DSTypeCGMapID = 170
select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 11 AND DSTypeID = 15 AND DSTypeCGMapID = 170
select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 32 AND DSTypeID = 15 AND DSTypeCGMapID = 170
select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 22 AND DSTypeID = 33 AND DSTypeCGMapID = 170
select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 33 AND DSTypeID = 34 AND DSTypeCGMapID = 170
select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 26 AND DSTypeID = 33 AND DSTypeCGMapID = 170
select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 25 AND DSTypeID = 34 AND DSTypeCGMapID = 170
select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 89 AND DSTypeID = 33 AND DSTypeCGMapID = 170
select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 17 AND DSTypeID = 35 AND DSTypeCGMapID = 170
select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 20 AND DSTypeID = 34 AND DSTypeCGMapID = 170
select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 29 AND DSTypeID = 35 AND DSTypeCGMapID = 170
select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND PMID = 42 And SalesmanID = 23 AND DSTypeID = 11 --AND DSTypeCGMapID = 170

select * from tbl_mERP_PMetric_TargetDefn Where Active = 1 AND SalesmanID = 94 AND PMID = 45
select top 1 * from tbl_mERP_PMMaster Where PMCode = ''

sp_depends tbl_mERP_PMetric_TargetDefn

select * ,(select top 1 Salesman_Name from Salesman S Where S.SalesmanID = V.SalesmanID) SalesmanName from dbo.FN_GetPMAbstractForView() V

Update tbl_mERP_PMetric_TargetDefn Set ProposedTargetValue

--> [data-ng-repeat]
--> [ng-repeat]
--> [x-ng-repeat]
--> [ng-repeat],> [data-ng-repeat]
--> [data-ng-repeat],> [x-ng-repeat]
--> [ng-repeat],> [data-ng-repeat],> [x-ng-repeat]