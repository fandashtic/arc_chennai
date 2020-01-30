IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'ARC_GetUnusedReportId')
BEGIN
	DROP PROC ARC_GetUnusedReportId
END
GO
CREATE procedure [dbo].ARC_GetUnusedReportId
As
Begin
	Declare @Table AS Table (Id Int Identity(1,1), ReportId Int)
	Insert into @Table(ReportId) Select Distinct Id From ReportData WIth (Nolock)

	--select * from @Table

	select Top 5 T.Id [ReportId] From @Table T WHERE T.Id Not in(SELECT Distinct Id FROM ReportData R WIth (Nolock))

	Delete From @Table

	Declare @PTable AS Table (Id Int Identity(1,1), ParameterID Int)
	Insert into @PTable(ParameterID) Select Distinct ParameterID From ParameterInfo WIth (Nolock)

	--select * from @PTable

	select Top 5 T.Id [ParameterID] From @PTable T WHERE T.Id Not in(SELECT Distinct ParameterID FROM ParameterInfo R WIth (Nolock))

	Delete From @PTable
END
GO