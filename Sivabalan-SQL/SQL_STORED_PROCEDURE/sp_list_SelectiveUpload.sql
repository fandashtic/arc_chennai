CREATE Procedure sp_list_SelectiveUpload(@bListFlag int =0,@Curdate DateTime = NULL)
As
	Create Table #FTable
	(
	 ListRepID int IDENTITY (1,1) NOT NULL,TopRepid  int,FDate datetime,
	 Tdate datetime, TopSpName nvarchar(100), DetailCommand int,
	 ForwardParam int,Parameters  int, DetailProcName nvarchar(100),
	 ReportName nvarchar(100),ReportType int,DayofMonthWeek int,ReportID int)   

	Declare @SelectiveUploadDate as nvarchar(10)	

	Select @SelectiveUploadDate=Cast(Datepart(dd, ReportUploadDate) As nvarchar) + N'/' +
	Cast(Datepart(mm, ReportUploaddate) As nvarchar) + N'/' +
	Cast(Datepart(yyyy, ReportUploadDate) As nvarchar) From Setup


IF(@SelectiveUploadDate=N'31/12/2004')
	Begin
		If(IsNull(@Curdate,0)=0)
		Begin
			--Get the Reports that is Assigned
			Insert into #FTable(TopRepid,FDate,Tdate,TopSpName,DetailCommand,ForwardParam,
			Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID)
				exec Sp_Get_MonthlyRepTobeGenerated	
		End
		Else
		Begin
			Set dateformat dmy			
			--Get the Reports that is Assigned
			Insert into #FTable(TopRepid,FDate,Tdate,TopSpName,DetailCommand,ForwardParam,
			Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID)
				exec Sp_Get_MonthlyRepTobeGenerated	@Curdate
		End
	End

if(@bListFlag=0)
Begin
	Select "ReportID"=#FTable.ReportID,
	"Parameters"=Parameters,
	"Sl no"= ListRepID,
	"Report Name"=ReportName,
	"Forum Code"=(Select dbo.GetRepUploadForumcode(#Ftable.ReportID)),
	"From Date"=FDate,
	"To Date"=TDate,
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
	When 1 then N'Daily' When 2 then N'Monthly' When 3 then N'Weekly' Else N'Customised Weekly' End)
	From #FTable
	Where TopRepID in (426,242)
End
Else
Begin
	Select TopRepid,FDate,Tdate,TopSpName,DetailCommand,ForwardParam,
	Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID
	From #FTable
	Where TopRepID in (426,242)
End
Drop Table #FTable


