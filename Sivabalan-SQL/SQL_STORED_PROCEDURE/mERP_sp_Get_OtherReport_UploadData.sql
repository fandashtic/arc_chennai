
Create Procedure mERP_sp_Get_OtherReport_UploadData(@CurrDate DateTime, @Flag int = 0)          
As          
Begin     
    
 Set Dateformat dmy         
 Declare @Frequency Int          
 Declare @GracePeriod Int          
 Declare @LastUploadDate DateTime           
 Declare @GPFlag Int          
 Declare @tblReportUpload as Table (          
 tRptDataID  int,           
 tRptID   Int,           
 tReportType  Int,           
 tReportFrom  DateTime,           
 tReportTo  DateTime,           
 tLastUpload  DateTime,           
 tActionData  nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,           
 tDetailCommand Int,           
 tForwardParam Int,           
 tParamID  Int,           
 DetailProcName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,       
 ReportName  nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,          
 LatestDoc  nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,          
  GPFlag   Int,          
  RepGenSeq  Int)          
       
 Create Table #ResultTable          
 (              
 ListRepID int IDENTITY (1,1) NOT NULL,               
 TopRepid  int,              
 FDate datetime,              
 Tdate datetime,              
 LUDate DateTime,          
 TopSpName nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,              
 DetailCommand int,              
 ForwardParam int,              
 Parameters  int,              
 DetailProcName nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,              
 ReportName nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,               
 ReportType int,              
 DayofMonthWeek int,              
 ReportID int,          
 GPFlag Int,          
 LatestDoc nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)          
    
 Declare @OtherRptID Int          
 Declare @RptFreq Int         
 Declare @RepDataID Int        
 Declare Cur_OtherReport Cursor For          
 Select ReportID, Frequency, ReportDataID from tbl_mERP_OtherReportsUpload Order by GenOrderBy          
 Open Cur_OtherReport          
 Fetch Next From Cur_OtherReport into @OtherRptID, @RptFreq ,@RepDataID         
 While @@Fetch_Status = 0           
 Begin          
  If @RptFreq = 1           
  Begin          
   Select @GracePeriod = IsNull(GracePeriod,0), @LastUploadDate = dbo.StriptimeFromDate(LastUploadDate) From tbl_mERP_OtherReportsUpload where ReportID = @OtherRptID          
           
   /*Generating Data for Current Upload*/          
   Declare @LastReportUpload DateTime          
   Declare @UploadUptoDate DateTime          
   Set @LastReportUpload = DateAdd(Day,1, @LastUploadDate)          
   Set @UploadUptoDate = dbo.StriptimeFromDate(@CurrDate) - 1			          
       
   While DateDiff(Day, @LastReportUpload, @UploadUptoDate) >= 0          
   Begin          
    /*Grace Period Checking*/    
	If @GracePeriod > 1           
	Begin          
	Set @GPFlag = -1 --Invalid grace period          
	End          
	Else If ((DateDiff(d,@LastReportUpload,@UploadUptoDate)) >= @GracePeriod) And (@GracePeriod <> 0)          
	Begin          
	Set @GPFlag = 1 --Grace period reached          
	End          
	Else          
	Begin          
	Set @GPFlag = 0 --Grace period exists          
	End          
            
    Insert into @tblReportUpload(tRptDataID,tRptID,tReportType,tReportFrom,tReportTo,tLastUpload,tActionData,tDetailCommand,tForwardParam,tParamID,DetailProcName, ReportName, LatestDoc,GPFlag)           
    Select ORU.ReportDataID, @OtherRptID, 1, @LastReportUpload, @LastReportUpload, dbo.StriptimeFromDate(ORU.LastUploadDate),            
    RD.ActionData, RD.DetailCommand, RD.ForwardParam, ORU.ParameterID,           
    Case RD.Detailcommand When 0 Then N'' Else (Select Rep.Actiondata From Reportdata Rep Where Rep.ID=RD.Detailcommand) end, ReportName,           
    Case ORU.LatestDoc When 1 Then 'Yes' Else 'No' End, @GPFlag          
    From tbl_mERP_OtherReportsUpload ORU, ReportData RD          
    Where ORU.ReportID = @OtherRptID           
    And RD.ID = ORU.ReportDataID          
            
    Set @LastReportUpload = DateAdd(Day,1, @LastReportUpload)          
   End          
  End  /* End of Daily Requency Report */         
  Fetch Next From Cur_OtherReport into @OtherRptID, @RptFreq, @RepDataID         
 End /* End of While */    
 Close Cur_OtherReport          
 Deallocate Cur_OtherReport          
    
     
 /* To Insert All Monthly Report in the Upload report */    
 Insert into @tblReportUpload(tRptDataID,tRptID,tReportType,tReportFrom,tReportTo,tLastUpload,tActionData,tDetailCommand,tForwardParam,tParamID,DetailProcName, ReportName, LatestDoc,GPFlag)           
 Exec Sp_Get_MonthlyOtherReptobeGenerated @CurrDate    
          
/* Resending Logic Starts*/  
--Daily  
 Insert into @tblReportUpload(tRptDataID,tRptID,tReportType,tReportFrom,tReportTo,tLastUpload,tActionData,tDetailCommand,tForwardParam,tParamID,DetailProcName, ReportName, LatestDoc,GPFlag)           
 Select ORU.ReportDataID,ORU.ReportId,1,RT.ReportFromDate,RT.ReportToDate,dbo.StriptimeFromDate(ORU.LastUploadDate),  
 Case When IsNull(ORU.AliasActionData,'') = '' Then RD.ActionData Else ORU.AliasActionData End as "ActionData",  
 DetailCommand,ForwardParam,ORU.ParameterId,Case RD.Detailcommand When 0 Then N''end,Node,'No',1  
    From tbl_mERP_OtherReportsUpload ORU, ReportData RD,tbl_merp_UploadReportTracker RT,Reports_to_Resend RS          
    Where      
    RD.ID = ORU.ReportDataID And  
 RT.ReportId=ORU.ReportID And  
    isnull(RT.ReportType,0)=2 And  
 RS.ReportDocID=RT.ReportDocID and  
 ORU.ReportDataID=RD.ID And  
 isnull(ORU.Frequency,0)=1 And  
 isnull(RS.status,0)=0 And  
 isnull(RD.Action,0)=1 And  
 isnull(RT.ARUMode,0)=0  
  
--Monthly   
 Insert into @tblReportUpload(tRptDataID,tRptID,tReportType,tReportFrom,tReportTo,tLastUpload,tActionData,tDetailCommand,tForwardParam,tParamID,DetailProcName, ReportName, LatestDoc,GPFlag)           
 Select ORU.ReportDataID,ORU.ReportId,2,RT.ReportFromDate,RT.ReportToDate,dbo.StriptimeFromDate(ORU.LastUploadDate),  
 Case When IsNull(ORU.AliasActionData,'') = '' Then RD.ActionData Else ORU.AliasActionData End as "ActionData",  
 DetailCommand,ForwardParam,ORU.ParameterId,Case RD.Detailcommand When 0 Then N''end,Node,'No',1  
    From tbl_mERP_OtherReportsUpload ORU, ReportData RD,tbl_merp_UploadReportTracker RT,Reports_to_Resend RS          
    Where      
    RD.ID = ORU.ReportDataID And  
 RT.ReportId=ORU.ReportID And  
 RS.ReportDocID=RT.ReportDocID and  
 ORU.ReportDataID=RD.ID And  
 isnull(RT.ReportType,0)=2 And  
 isnull(ORU.Frequency,0)=2 And  
 isnull(RS.status,0)=0 And  
 isnull(RD.Action,0)=1 And  
 isnull(RT.ARUMode,0)=0  
/* Resending Logic Ends*/   
  
  /*Sequence Update*/          
  Update @tblReportUpload Set RepGenSeq = GenOrderBy          
  From tbl_mERP_OtherReportsUpload          
  Where tbl_mERP_OtherReportsUpload.ReportID = tRptID      
    
          
  /*Move in to Main table*/          
  Insert into #ResultTable(TopRepid, FDate, Tdate, LUDate, TopSpName,DetailCommand,ForwardParam,          
    Parameters,DetailProcName,ReportName,ReportType,DayofMonthWeek,ReportID,GPFlag,LatestDoc)          
  Select tRptDataID, tReportFrom, tReportTo, tLastUpload, tActionData, tDetailCommand, tForwardPAram,           
    tParamID, DetailProcName, ReportName, tReportType, 0 as DayOfMonthOfWeek,  tRptID, GPFlag, LatestDoc           
    from @tblReportUpload Order by RepGenSeq, tReportFrom, tRptDataID          

	/* To get Last Upload Date for DS Update Report */
	Declare @UploadDate DateTime
	Select @UploadDate= dbo.StriptimeFromDate(LastUploadDate) From tbl_mERP_OtherReportsUpload Where ReportName = 'DS Update Information Report'
          
  If @Flag = 1           
  Begin          
    Select TopRepid, FDate, TDate, LUDate, TopSPName, DetailCommand, ForwardParam, Parameters,          
    DetailProcName, ReportName, ReportType, DayofMonthWeek, ReportID, GPFlag, LatestDoc          
    From #ResultTable    
    Where ReportType = 1 And   
 --dbo.StriptimeFromDate(FDate) IN (Select Distinct dbo.StriptimeFromDate(CreationTime) From tbl_merp_Prodmargin_auditLog Where IsNull(RptUploadFlag,0) = 0)  
	(ReportName = 'Edit Product Margin Report' and dbo.StriptimeFromDate(FDate) IN (Select Distinct dbo.StriptimeFromDate(CreationTime) From tbl_merp_Prodmargin_auditLog Where IsNull(RptUploadFlag, 0) = 0))
	OR (ReportName = 'DS Update Information Report' and dbo.StriptimeFromDate(FDate) IN (Select Distinct dbo.StriptimeFromDate(ModifiedDate) From Salesman Where dbo.StriptimeFromDate(ModifiedDate) > @UploadDate))
	OR (ReportName <> 'Edit Product Margin Report' and ReportName <> 'DS Update Information Report' and dbo.StriptimeFromDate(FDate) IN (dbo.StriptimeFromDate(FDate)))

    Union  
    Select TopRepid, FDate, TDate, LUDate, TopSPName, DetailCommand, ForwardParam, Parameters,          
    DetailProcName, ReportName, ReportType, DayofMonthWeek, ReportID, GPFlag, LatestDoc          
    From #ResultTable    
    Where ReportType = 2 And dbo.StriptimeFromDate(FDate) = dbo.StriptimeFromDate(FDate)  
    Order By TopRepid  
  End          
  Else          
  Begin          
    Select "ReportID"=ReportID,              
    "Parameters"=Parameters,              
    "S. No."= ListRepID,          
    "Report Name"=ReportName,              
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
    From #ResultTable     
--    Where dbo.StriptimeFromDate(FDate) IN     
--      (Case (ReportType) When 1 then     
--                (Select Distinct dbo.StriptimeFromDate(CreationTime) From tbl_merp_Prodmargin_auditLog Where IsNull(RptUploadFlag,0) = 0)    
--    Else    
--    dbo.StriptimeFromDate(FDate)    
--       End)     

	Where (ReportName = 'Edit Product Margin Report' and dbo.StriptimeFromDate(FDate) IN (Select Distinct dbo.StriptimeFromDate(CreationTime) From tbl_merp_Prodmargin_auditLog Where IsNull(RptUploadFlag, 0) = 0))
	OR (ReportName = 'DS Update Information Report' and dbo.StriptimeFromDate(FDate) IN (Select Distinct dbo.StriptimeFromDate(ModifiedDate) From Salesman Where dbo.StriptimeFromDate(ModifiedDate) > @UploadDate))
	OR (ReportName <> 'Edit Product Margin Report' and ReportName <> 'DS Update Information Report' and dbo.StriptimeFromDate(FDate) IN (dbo.StriptimeFromDate(FDate)))

    Order By ListRepID          
  End          
  Drop table #ResultTable          
End  

