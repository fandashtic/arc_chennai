CREATE PROCEDURE [dbo].[spr_ReleaseStatusReport_Detail_ITC](@instlId nvarchar(25),@FromDate Datetime, @ToDate Datetime)
As
SET DATEFORMAT DMY

Declare @InsID as int
Declare @WDCode as nvarchar(10)

Set @InsID=left(@InstlID,CharIndex(char(15),@InstlID)-1)
Set @WDCode=right(@InstlID,len(@InstlID)-CharIndex(char(15),@InstlID))

Create Table #tblRep(ReportID Int,[Date] DateTime,[Date & Time] nVarchar(100),
[Activity/Problem Description] nvarchar(4000),[Error/Information] nvarchar(50))

Create Table #tblResult([Sno] int, [Date] DateTime,[Date & Time] nVarchar(100),
[Activity/Problem Description] nvarchar(4000),[Error/Information] nvarchar(50))
Select
[Date] = Cast(elg.CreationDate As nVarchar),
IDENTITY(Int, 1, 1) As [Sl. No.],
[Date & Time] = Cast(elg.CreationDate As nVarchar),
[Activity/Problem Description] = elg.ErrorMessage,
case when elg.Status=1 then 'Information' when elg.Status=2 then 'Error' else '' END as [Error/Information]
Into #tmpCons
From tblErrorLog elg
Where elg.InstallationID = @InsID
AND elg.CreationDate >=(select Cast(convert(nvarchar(20),ModifiedDate,103) as DateTime) from tblInstallationDetail where InstallationID = @InsID)
Order By elg.ErrorLogID

If (Select Count(*) From Reports Where ReportName = 'Release Status Report' And ParameterID in
(Select ReportParameters.ParameterID From Reports,ReportParameters  Where ReportName = 'Release Status Report'
And Reports.ParameterID = ReportParameters.ParameterID)) >=1
-- Insert Into #tmpCons([Date],[Date & Time],[Activity/Problem Description])
Insert into #tblRep
Select
[ReportId],
[Date] = ReportDetailReceived.Field2,
[Date & Time] = Cast(ReportDetailReceived.Field2 as varchar),
[Activity/Problem Description] = ReportDetailReceived.Field3
From ReportAbstractReceived,ReportDetailReceived Where
ReportDetailReceived.Field1 != 'Sl. No.' And
ReportAbstractReceived.Field2=Cast(@WDCode As VarChar) And
ReportAbstractReceived.Field1=Cast(@InsID As VarChar) And
ReportAbstractReceived.RecordID = ReportDetailReceived.RecordID And
ReportAbstractReceived.ReportID in
(Select Max(ReportID) From Reports
Where ReportName = 'Release Status Report'
And ParameterID in (Select ReportParameters.ParameterID From ReportParameters,Reports
Where ReportName='Release Status Report' and ReportPArameters.PArameterID=Reports.PArameterID)
And ParameterID in (
Select ParameterID From dbo.GetReportParametersForSPR('Release Status Report')
where FromDate = dbo.StripDateFromTime(@FromDate) And ToDate = dbo.StripDateFromTime(@ToDate)
)
)

Insert into #tblResult
Select  0 , cast([Date] as Varchar),[Date & Time],[Activity/Problem Description],[Error/Information] From #tblRep
Where ReportId in (Select Max(ReportId) From #tblRep)
Union
Select [Sl. No.],Date, [Date & Time],[Activity/Problem Description],[Error/Information] from #tmpCons


Select [Sno],Sno as  [Sl. No.], [Date & Time],[Activity/Problem Description],[Error/Information] from #tblResult where sno >= 1
Order by [SNo]

Drop Table #tmpCons
Drop Table #tblResult
Drop Table #tblRep

