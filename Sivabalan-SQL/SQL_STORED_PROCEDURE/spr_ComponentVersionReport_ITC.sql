Create PROCEDURE [dbo].[spr_ComponentVersionReport_ITC](@WDCCode nVarchar(255),@Fromdate Datetime,@Todate Datetime)
As
SET DATEFORMAT DMY
Declare @WDCode nVarchar(256)
Select Top 1 @WDCode = RegisteredOwner From Setup

Create table #TempReport (ReportId int,[Code] nvarchar(10)  COLLATE SQL_Latin1_General_CP1_CI_AS,
[WD Code] nvarchar(10)  COLLATE SQL_Latin1_General_CP1_CI_AS,
[Machine Name] nvarchar(200)  COLLATE SQL_Latin1_General_CP1_CI_AS,
[Machine Type] nvarchar(7)  COLLATE SQL_Latin1_General_CP1_CI_AS,
[Component] nvarchar(200)  COLLATE SQL_Latin1_General_CP1_CI_AS,
[Version] nvarchar(2000)  COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Last Patch] nvarchar(2000)  COLLATE SQL_Latin1_General_CP1_CI_AS,
[Created On] nvarchar(25)  COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Last Modified On] nvarchar(25)  COLLATE SQL_Latin1_General_CP1_CI_AS)


Create table #tblResult ([WD_Code1] nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
[WD Code] nvarchar(10)  COLLATE SQL_Latin1_General_CP1_CI_AS,
[Machine Name] nvarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Machine Type] nvarchar(7) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Component] nvarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Version] nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Last Patch] nvarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Created On] nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS, 
[Last Modified On] nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS)

Select
"WD Code" = @WDCode,
"Machine Name" = clm.SystemName,
"Machine Type" = Case clm.IsServer When 0 Then 'Client' Else 'Server' End,
"Component" = cov.ComponentName,
"Version" = cov.Version,
"ClnID" = clm.ClientID,
"InsID" = IsNull(cov.Installation_Id, 0),
"CreationDate" = Cast(cov.CreationDate As nVarchar)
Into #tempone
From
tblClientMaster clm, COMVersion cov
where isnull(clm.IsServer,0)=1 
-- where
-- dbo.stripdatefromtime(cov.CreationDate) Between dbo.stripdatefromtime(@Fromdate) and dbo.stripdatefromtime(@Todate) OR
-- dbo.stripdatefromtime(cov.ModifiedDate) between dbo.stripdatefromtime(@Fromdate) and dbo.stripdatefromtime(@Todate)

Select
"InsID" = insd.Installationid,
"Machine Name" = clm.SystemName,
"Machine Type" = Case clm.IsServer When 0 Then 'Client' Else 'Server' End,
"Component" = cov.ComponentName,
"Version" = insv.VersionNo,
"Last Patch" = insd.[FileName],
"Created On" = Cast(cov.CreationDate As nVarchar),
"Last Modified On" = Cast(insv.CreationDate As nVarchar),
"ClnID" = clm.ClientID
Into #com1
From
COMVersion cov, tblInstalledVersions insv,
tblInstallationDetail insd, tblClientMaster clm
Where 
(dbo.stripdatefromtime(cov.CreationDate) Between dbo.stripdatefromtime(@Fromdate) and dbo.stripdatefromtime(@Todate) OR
dbo.stripdatefromtime(cov.ModifiedDate) between dbo.stripdatefromtime(@Fromdate) and dbo.stripdatefromtime(@Todate)) And
cov.ComponentName = insv.[FileName] And
insv.InstallationID = insd.Installationid And
clm.ClientID = insd.ClientID And
(insv.CreationDate = (Select Max(insv1.CreationDate) From
COMVersion cov1, tblInstalledVersions insv1,
tblInstallationDetail insd1, tblClientMaster clm1
Where cov1.ComponentName = insv1.[FileName] And
insv1.InstallationID = insd1.Installationid And
clm1.ClientID = insd1.ClientID And
clm1.IsServer = 1 And
insv1.[FileName] = insv.[FileName])  Or
insv.CreationDate = (Select Max(insv1.CreationDate) From
COMVersion cov1, tblInstalledVersions insv1,
tblInstallationDetail insd1, tblClientMaster clm1
Where cov1.ComponentName = insv1.[FileName] And
insv1.InstallationID = insd1.Installationid And
clm1.ClientID = insd1.ClientID And
clm1.IsServer = 0 And
insv1.[FileName] = insv.[FileName]
))
Select
"WD Cde" = temp1.[WD Code],
"WD Code" = temp1.[WD Code],
"Machine Name" = temp1.[Machine Name],
"Machine Type" = temp1.[Machine Type],
"Component" = temp1.[Component],
"Version" = Case When IsNull(com1.[Version], '') = '' Then temp1.[Version] Else com1.[Version] End,
"Last Patch" = com1.[Last Patch],
"Created On" = temp1.[CreationDate],
"Last Modified On" = com1.[Last Modified On]
into #tempCons
From
#tempone temp1
Left Outer Join  #com1 com1 On temp1.[ClnID] = com1.[ClnID] And temp1.Component = com1.[Component]


If (Select Count(*) From Reports Where ReportName = 'Component Version Report' And ParameterID in
(Select ReportParameters.ParameterID From Reports,ReportParameters  Where ReportName = 'Component Version Report'
And Reports.ParameterID = ReportParameters.ParameterID)) >=1

Insert Into #TempReport(ReportId ,Code ,[WD Code],[Machine Name],[Machine Type],
[Component],[Version],[Last Patch],[Created On],[Last Modified On])
Select ReportId ,  1,
"WD Code" = ReportAbstractReceived.Field1,
"Machine Name" = ReportAbstractReceived.Field2,
"Machine Type" = cast(ReportAbstractReceived.Field3 as Varchar(5)),
"Component" = ReportAbstractReceived.Field4,
"Version" = ReportAbstractReceived.Field5,
"Last Patch" = ReportAbstractReceived.Field6,
"Created On" = Cast(ReportAbstractReceived.Field7 as varchar(30)),
"Last Modified On" = Cast(ReportAbstractReceived.Field8 as varchar(30))
From ReportAbstractReceived Where
ReportAbstractReceived.ReportID in
(Select Distinct ReportID From Reports
Where ReportName = 'Component Version Report'
And ParameterID in (
Select ParameterID From dbo.GetReportParametersForSPR('Component Version Report')
where FromDate = dbo.StripDateFromTime(@Fromdate) And ToDate = dbo.StripDateFromTime(@Todate))
And ParameterID in (Select ReportParameters.ParameterID From ReportParameters,Reports
Where ReportName='Component Version Report' and ReportPArameters.PArameterID=Reports.PArameterID 
))
And ReportAbstractReceived.Field2 <> 'Machine Name'

Insert into #tblResult
Select Cast(1 as nvarchar) ,[WD Code],[Machine Name],[Machine Type], Component,Version,[Last Patch],
[Created On],[Last Modified On] From #TempReport where ReportId in (Select Max(ReportID) from #TempReport)
Union
Select * From #tempCons 


Select * from #tblResult Order by "WD Code"

Drop Table #tempCons
Drop Table #com1
Drop Table #TempOne
Drop Table #TempReport
Drop Table #tblResult

