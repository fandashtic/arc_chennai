Create procedure mERP_sp_Insert_OtherReport_UploadInfo(
@REPORTID Int, 
@ReportDocNumber Int, 
@REPORT_FROM DateTime, 
@REPORT_TO DateTime, 
@UPLOAD_ON DateTime, 
@REPORT_TYPE Int,
@Mode Int = 0)
As
Begin
  /*Mode is introduced to handle whether the report is generated thro' Autoreportupload or manually*/
  /* O for Autoreport upload and 1 for manual*/
  Insert into tbl_merp_UploadReportTracker(ReportID, ReportDocNumber, ReportFromDate, ReportToDate, ReportType, ARUMode, CreationDate)
  Values (@REPORTID, @ReportDocNumber, @REPORT_FROM, @REPORT_TO, @REPORT_TYPE,@Mode, Getdate())
  Select @@Identity
End
