CREATE Procedure sp_List_RepToGenAbs(@Curdate DateTime = NULL,@Flag int = 0)  
As      
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--  
--$$ This stored procedure is used to loading of upload reports in ARU list viewer  
--$$ ITC Define a sequence to upload reports   
--$$ The @Flag argument is use to get all report in sequence to upload  
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--  
SET DATEFORMAT DMY  
Create Table #ResultTable  
(      
 ListRepID int IDENTITY (1,1) NOT NULL,       
 TopRepid  int,      
 FDate datetime,      
 Tdate datetime,      
 LUDate DateTime,  
 TopSpName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,      
 DetailCommand int,      
 ForwardParam int,      
 Parameters  int,      
 DetailProcName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,      
 ReportName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,       
 ReportType int,      
 DayofMonthWeek int,      
 ReportID int,  
 GPFlag Int,  
 LatestDoc nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  
Create Table #FTable      
(      
 ListRepID int IDENTITY (1,1) NOT NULL,       
 TopRepid  int,      
 FDate datetime,      
 Tdate datetime,      
 LUDate DateTime,  
 TopSpName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,      
 DetailCommand int,      
 ForwardParam int,      
 Parameters  int,      
 DetailProcName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,      
 ReportName nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,       
 ReportType int,      
 DayofMonthWeek int,      
 ReportID int,  
 RepGenSeq int,  
 GPFlag int,  
 LatestDoc nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)  


/* Sales Data report should alone send as daily report. Others will be send from Days End Reports*/
Insert into #FTable(TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,      
Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc)      
  
exec Sp_Get_DayRepTobeGenerated_specific @Curdate  

      
Insert into #FTable(TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,      
Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc)      
  
exec Sp_Get_MonthlyRepTobeGenerated @Curdate  
      
  
Insert into #FTable(TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,      
Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc)      
  
exec Sp_Get_WeekRepTobeGenerated @Curdate   
      
      
Insert into #FTable(TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,      
Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc)      
  
exec Sp_Get_CustomisedWeeklyRepTobeGenerated @Curdate  
  
Insert into #FTable(TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,      
Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc)      
  
exec Sp_Get_CumulativeWeeklyRepTobeGenerated @Curdate  
    
--Insert into #FTable(TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,      
--Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag)      
--exec Sp_Get_CustomisedWeeklyRepTobeGenerated_ITC     
    
/* Resending Logic Starts*/
--Specific 
	Insert into #FTable(TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,      
	Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc)  
	Select RU.ReportDataID,RT.ReportFromDate,RT.ReportToDate,
	dbo.Stripdatefromtime(DateAdd(d,1,LastUploadDate)),
	Case When IsNull(RU.AliasActionData,'') = '' Then RD.ActionData Else RU.AliasActionData End as "ActionData",
	DetailCommand,ForwardParam,RU.ParameterId,Case RD.Detailcommand When 0 Then N''
	Else (Select Rep.Actiondata From Reportdata Rep Where Rep.ID=RD.Detailcommand) end,
	Node,1,0,RU.ReportId,1,'No'
	From tbl_merp_UploadReportTracker RT,Reports_To_Upload RU,Reports_to_Resend RS,ReportData RD
	Where RU.ReportId=RT.ReportID And
	RS.ReportDocID=RT.ReportDocID and
	isnull(RT.ReportType,0)=1 And
	RU.ReportDataID=RD.ID And
	isnull(RU.Frequency,0)=1 And
	isnull(RS.status,0)=0 And
	isnull(RT.ARUMode,0)=0 And
	isnull(RD.Action,0)=1 And
	RU.ReportName='Sales Data'

--Monthly
	Insert into #FTable(TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,      
	Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc) 
	Select RU.ReportDataID,RT.ReportFromDate,RT.ReportToDate,
	isnull(LastUploadDate,getdate()),
	Case When IsNull(RU.AliasActionData,'') = '' Then RD.ActionData Else RU.AliasActionData End as "ActionData",
	DetailCommand,ForwardParam,RU.ParameterId,Case RD.Detailcommand When 0 Then N''
	Else (Select Rep.Actiondata From Reportdata Rep Where Rep.ID=RD.Detailcommand) end,
	Node,2,RU.DayOfMonthWeek,RU.ReportId,1,'No'
	From tbl_merp_UploadReportTracker RT,Reports_To_Upload RU,Reports_to_Resend RS,ReportData RD
	Where RT.ReportId=RU.ReportID And
	RS.ReportDocID=RT.ReportDocID and
	RU.ReportDataID=RD.ID And
	isnull(RT.ReportType,0)=1 And
	isnull(RU.Frequency,0)=2 And
	isnull(RS.status,0)=0 And
	isnull(RT.ARUMode,0)=0 And
	isnull(RD.Action,0)=1

--Weekly
	Insert into #FTable(TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,      
	Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc) 
	Select RU.ReportDataID,RT.ReportFromDate,RT.ReportToDate,
	isnull(LastUploadDate,getdate()),
	Case When IsNull(RU.AliasActionData,'') = '' Then RD.ActionData Else RU.AliasActionData End as "ActionData",
	DetailCommand,ForwardParam,RU.ParameterId,Case RD.Detailcommand When 0 Then N''
	Else (Select Rep.Actiondata From Reportdata Rep Where Rep.ID=RD.Detailcommand) end,
	Node,3,RU.DayOfMonthWeek,RU.ReportId,1,'No'
	From tbl_merp_UploadReportTracker RT,Reports_To_Upload RU,Reports_to_Resend RS,ReportData RD
	Where RT.ReportId=RU.ReportID And
	RS.ReportDocID=RT.ReportDocID and
	RU.ReportDataID=RD.ID And
	isnull(RT.ReportType,0)=1 And
	isnull(RU.Frequency,0)=3 And
	isnull(RS.status,0)=0 And
	isnull(RT.ARUMode,0)=0 And
	isnull(RD.Action,0)=1

--Customised Weekly
	Insert into #FTable(TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,      
	Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc) 
	Select RU.ReportDataID,RT.ReportFromDate,RT.ReportToDate,
	isnull(LastUploadDate,getdate()),
	Case When IsNull(RU.AliasActionData,'') = '' Then RD.ActionData Else RU.AliasActionData End as "ActionData",
	DetailCommand,ForwardParam,RU.ParameterId,Case RD.Detailcommand When 0 Then N''
	Else (Select Rep.Actiondata From Reportdata Rep Where Rep.ID=RD.Detailcommand) end,
	Node,4,RU.DayOfMonthWeek,RU.ReportId,1,'No'
	From tbl_merp_UploadReportTracker RT,Reports_To_Upload RU,Reports_to_Resend RS,ReportData RD
	Where RT.ReportId=RU.ReportID And
	RS.ReportDocID=RT.ReportDocID and
	RU.ReportDataID=RD.ID And
	isnull(RT.ReportType,0)=1 And
	isnull(RU.Frequency,0)=4 And
	isnull(RS.status,0)=0 And
	isnull(RD.Action,0)=1 And
	isnull(RT.ARUMode,0)=0

--Cumulative Weekly
	Insert into #FTable(TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,      
	Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc) 
	Select RU.ReportDataID,RT.ReportFromDate,RT.ReportToDate,
	isnull(LastUploadDate,getdate()),
	Case When IsNull(RU.AliasActionData,'') = '' Then RD.ActionData Else RU.AliasActionData End as "ActionData",
	DetailCommand,ForwardParam,RU.ParameterId,Case RD.Detailcommand When 0 Then N''
	Else (Select Rep.Actiondata From Reportdata Rep Where Rep.ID=RD.Detailcommand) end,
	Node,5,RU.DayOfMonthWeek,RU.ReportId,1,'No'	
	From tbl_merp_UploadReportTracker RT,Reports_To_Upload RU,Reports_to_Resend RS,ReportData RD
	Where RT.ReportId=RU.ReportID And
	RS.ReportDocID=RT.ReportDocID and
	RU.ReportDataID=RD.ID And
	isnull(RT.ReportType,0)=1 And
	isnull(RU.Frequency,0)=5 And
	isnull(RS.status,0)=0 And
	isnull(RD.Action,0)=1 And
	isnull(RT.ARUMode,0)=0

/* Resending Logic Ends*/

Update #FTable   
Set RepGenSeq = GenOrderBy   
From Reports_To_Upload   
Where Reports_To_Upload.ReportID = #FTable.ReportID  
  
InSert InTo #ResultTable  
(TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,  
Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc)  
Select TopRepid,FDate,Tdate,LUDate,TopSpName,DetailCommand,ForwardParam,      
Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc   
From #FTable Order By RepGenSeq,ListRepID  
  
  
If @Flag = 1   
Begin  
 Select TopRepid, FDate, TDate, LUDate, TopSPName, DetailCommand, ForwardParam, Parameters,  
 DetailProcName, ReportName, ReportType, DayofMonthWeek, ReportID, GPFlag, LatestDoc  
 From #ResultTable Order By ListRepID  
End  
Else  
Begin  
 Select "ReportID"=#ResultTable.ReportID,      
 "Parameters"=Parameters,      
 "S. No."= ListRepID,  
 "Report Name"=ReportName,      
 --"Forum Code"=(Select dbo.GetRepUploadForumcode(#ResultTable.ReportID)),  
 "From Date"=FDate,      
 "To Date"=TDate,      
 "Last Upload Date"=LUDate,  
 "DayOfMonthWeek"=(Case (ReportType)      
 When 1 then N''      
 When 4 then N''      
 When 3 then (Case(DayOfMonthWeek)      
     When 1 then N'Sunday' When 2 then N'Monday' When 3 then N'Tuesday'      
     When 4 then N'Wednesday' When 5 then N'Thursday' When 6 then N'Friday'      
     When 7 then N'Saturday' End)       
 Else Cast((DayOfMonthWeek)as nvarchar)       
 End ),      
 "Type Of Report"=(Case (ReportType)      
 When 1 then N'Daily' When 2 then N'Monthly' When 3 then N'Weekly' When 4 Then N'Customised Weekly'   
  When 5 Then 'Cumulative Weekly' End),  
 GPFlag, "Latest Report" = LatestDoc  
 From #ResultTable Order By ListRepID  
End  
  
Drop Table #FTable      
Drop Table #ResultTable  
