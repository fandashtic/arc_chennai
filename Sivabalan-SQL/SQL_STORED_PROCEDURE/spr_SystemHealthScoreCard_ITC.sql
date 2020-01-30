Create PROCEDURE [dbo].[spr_SystemHealthScoreCard_ITC](@WDCCode nVarchar(255),@Fromdate Datetime,@Todate Datetime)
As

Declare @WDCode nVarchar(256)
Declare @DatabaseEdition nVarchar(50)
Declare @ProductVersion nVarchar(50)

Select Top 1 @WDCode = RegisteredOwner From Setup
SELECT @DatabaseEdition=Cast(SERVERPROPERTY('edition') as nvarchar(50)),@ProductVersion=Cast(SERVERPROPERTY('productversion') as Nvarchar(50))


Create Table #TmpCons ([temp] nvarchar(256),[WD Code] Nvarchar(256),[Machine Type] Nvarchar(10),
[Machine Name] Nvarchar(200),[Processor] Nvarchar(200),[RAM] Nvarchar(200),[OS] Nvarchar(200),[DB Server] Nvarchar(200),
[Hard Disk Free Space] Nvarchar(200),[DB Size] Nvarchar(200),[DB Name] Nvarchar(200),[Last Backup Date] Nvarchar(20))

Create Table #TmpReport (ReportId int , [TempCode] nvarchar(256),[WD Code] Nvarchar(256),[Machine Type] Nvarchar(10),
[Machine Name] Nvarchar(200),[Processor] Nvarchar(200),[RAM] Nvarchar(200),[OS] Nvarchar(200),[DB Server] Nvarchar(200),
[Hard Disk Free Space] Nvarchar(200),[DB Size] Nvarchar(200),[DB Name] Nvarchar(200),[Last Backup Date] Nvarchar(20))

Create Table #TblResult ([WD Code1] Nvarchar(256),[WD Code] Nvarchar(256),[Machine Type] Nvarchar(10),
[Machine Name] Nvarchar(200),[Processor] Nvarchar(200),[RAM] Nvarchar(200),[OS] Nvarchar(200),[DB Server] Nvarchar(200),
[Hard Disk Free Space] Nvarchar(200),[DB Size] Nvarchar(200),[DB Name] Nvarchar(200),[Last Backup Date] Nvarchar(20))

Insert into #tmpCons Select 
@WDCode,
"WD Code" = @WDCode,
"Machine Type" = Case clm.IsServer When 0 Then 'Client' Else 'Server' End,
"Machine Name" = clm.SystemName,
"Processor" = clm.ProcessorName,
"RAM" = clm.PrimaryMemSize,
"OS" = clm.OSVersion,
"DB Server" = Case When Isnull(clm.DBSize,'') <> '' then clm.DBVersion + '-' + @DatabaseEdition + '(' + @ProductVersion + ')' 
				   Else '' End,
"Hard Disk Free Space" = clm.HardDiskFreeSpace,
"DB Size" = clm.DBSize,
"DB Name"= Case When Isnull(clm.DBSize,'') <> '' then (SELECT DB_NAME()) Else '' End,
"Last Backup date"= Case When Isnull(clm.DBSize,'') <> '' then(convert(nVarchar(20),(Select top 1 Last_Backup_Date from Setup),103)) else '' end
From
tblClientMaster clm 
--Where dbo.stripdatefromtime(modifieddate) between dbo.stripdatefromtime(@Fromdate) and dbo.stripdatefromtime(@Todate)
Order by clm.modifieddate desc

If (Select Count(*) From Reports Where ReportName = 'WD System Health ScoreCard' And ParameterID in
(Select ReportParameters.ParameterID From Reports,ReportParameters  Where ReportName = 'WD System Health ScoreCard'
And Reports.ParameterID = ReportParameters.ParameterID)) >=1

Insert into #tmpReport
Select Reportid , @WDCode,
"WD Code" = Cast(ReportAbstractReceived.Field1 as nvarchar(256)),
"Machine Type" = Cast(ReportAbstractReceived.Field2 as nvarchar(7)),
"Machine Name" = Cast(ReportAbstractReceived.Field3 as nvarchar(200)),
"Processor" = Cast(ReportAbstractReceived.Field4 as nvarchar(200)),
"RAM" = Cast(ReportAbstractReceived.Field5 as nvarchar(200)),
"OS" = Cast(ReportAbstractReceived.Field6 as nvarchar(200)),
"DB Server" = Cast(ReportAbstractReceived.Field7 as nvarchar(200)),
"Hard Disk Free Space" = Cast(ReportAbstractReceived.Field8 as nvarchar(200)),
"DB Size" = Cast(isnull(ReportAbstractReceived.Field9,'') as nvarchar(200)),
"DB Name" = Cast(isnull(ReportAbstractReceived.Field10,'') as nvarchar(200)),
"Last Backup Date" = convert(nVarchar(20),Cast(isnull(ReportAbstractReceived.Field11,'') as nvarchar(200)),103)
From ReportAbstractReceived Where
ReportAbstractReceived.ReportID in
(
Select max(ReportID) From Reports
Where ReportName = 'WD System Health ScoreCard'
And ParameterID in 
	(
	Select ParameterID From dbo.GetReportParametersForSPR('WD System Health ScoreCard')
	where FromDate = dbo.StripDateFromTime(@Fromdate) And ToDate = dbo.StripDateFromTime(@Todate)
	)
And ParameterID in 
	(
	Select ReportParameters.ParameterID From ReportParameters,Reports
	Where ReportName='WD System Health ScoreCard' and ReportPArameters.PArameterID=Reports.PArameterID
	)group by reportid
)
And ReportAbstractReceived.Field2 <> 'Machine Type'

Insert into #tblResult
Select [WD Code],[WD Code],[Machine Type],[Machine Name],[Processor],[RAM],OS,[DB Server],[Hard Disk Free Space],[DB Size], [DB Name],convert(nVarchar(20),[Last Backup Date],103)
From #tmpreport where ReportId in (Select Max(ReportID) from #tmpreport)
Union
Select *  From #TmpCons 


Select [WD Code1] as [WD Code1] ,[WD Code],[Machine Type],[Machine Name],[Processor],[RAM],
OS,[DB Server],[Hard Disk Free Space],[DB Size],[DB Name],[Last Backup Date]
From #tblResult 
Order by [WD Code] Asc, "Machine Type" Desc

Drop Table #TmpCons
Drop Table #Tmpreport
Drop Table #tblResult

