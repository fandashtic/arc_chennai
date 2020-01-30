Create Procedure mERP_sp_Check_OtherReport_Upload
As
Begin
  Declare @REPORT_NAME nVarchar(510)
  Declare @REPORT_ID Int
  Declare @REPORT_LAST_UPL DateTime 
  Declare @REC_COUNT Int 
  Declare Cur_Upld_Reports Cursor For
  Select ReportID, ReportName, LastUploadDate From tbl_mERP_OtherReportsUpload
  Open Cur_Upld_Reports
  Fetch From Cur_Upld_Reports Into @REPORT_ID, @REPORT_NAME, @REPORT_LAST_UPL
  While @@Fetch_Status = 0 
  Begin
    Set @REC_COUNT = 0  
    IF @REPORT_NAME = N'Edit Product Margin Report'
    Begin
      Select @REC_COUNT = Count(*) From tbl_mERP_ProdMargin_AuditLog Where RptUploadFlag = 0 Having 
      DateDiff(day, @REPORT_LAST_UPL, dbo.StriptimeFromDate(Max(CreationTime))) > 0 
    End
	Else
	Begin
	  Select @REC_COUNT = 1
	End
    Fetch From Cur_Upld_Reports Into @REPORT_ID, @REPORT_NAME, @REPORT_LAST_UPL
  End
  Close Cur_Upld_Reports
  Deallocate Cur_Upld_Reports
	
  Select @REC_COUNT
End
