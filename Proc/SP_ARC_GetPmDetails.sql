--exec SP_ARC_K4 '2020-02-04 00:00:00','2020-02-04 23:59:59', 'CIG'
--Exec ARC_Insert_ReportData 288, 'View Pm Details', 1, 'SP_ARC_GetPmDetails', 'Click to view Get Pm Details', 399, 0, 1, 2, 0, 0, 3, 0, 0, 0, 252, 'No'
--GO
--Exec ARC_GetUnusedReportId
--Select * from ReportData Where Parent = 151
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ARC_GetPmDetails')
BEGIN
    DROP PROC SP_ARC_GetPmDetails
END
GO
CREATE PROCEDURE [dbo].SP_ARC_GetPmDetails
AS
BEGIN
 SET DATEFORMAT DMY  
 select 1, * ,(select top 1 Salesman_Name from Salesman S Where S.SalesmanID = V.SalesmanID) SalesmanName from dbo.FN_GetPMAbstractForView() V
END
GO