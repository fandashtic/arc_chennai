Create Procedure mERP_sp_Delete_ReportXMLArchiveData
As 
Begin

  Create table #RptDocID (RptID int)
  Declare @sqlQry nVarchar(Max)
  Declare @ReportID int, @ReportName nVarchar(510), @ArchiveCnt  Int
  Declare @UpldRptInfo table(ReportID Int, ReportName nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, ArchiveCnt Int)

  Insert into @UpldRptInfo(ReportID , ReportName , ArchiveCnt)
  Select UpdRpt.ReportDataID, RTC.ReportName, RTC.ArchiveCount From tbl_merp_RptTrackerConfig RTC, 
  (Select ReportDataID, ReportName, Frequency, GracePeriod From
  (Select ReportDataID, ReportName, Frequency, IsNull(GracePeriod,0) GracePeriod From Reports_to_upload 	
   Union 
   Select ReportDataID, ReportName, Frequency, IsNull(GracePeriod,0) From tbl_mERP_OtherReportsUpload)A)UpdRpt
   Where RTC.ReportName = UpdRpt.ReportName And RTC.Active = 1

  Declare Cur_DelRpt Cursor For
  Select ReportID , ReportName , ArchiveCnt From @UpldRptInfo 
  Open Cur_DelRpt
  Fetch From Cur_DelRpt Into @ReportID, @ReportName, @ArchiveCnt
  While @@Fetch_status = 0
  Begin
    
    Truncate table #RptDocID
    Set @sqlQry = ' Insert into #RptDocID Select ReportDocID From tbl_merp_UploadReportTracker '+
                  ' Where ReportID =' + Cast(@ReportID as nVarchar(10))+' And Status & 129 = 129 And ReportDocID not in '+
                  ' (Select Top '+ Cast(@ArchiveCnt as nVarchar(10)) +' ReportDocID From tbl_merp_UploadReportTracker '+ 
                  ' Where ReportID =' + Cast(@ReportID as nVarchar(10)) +' Order by ReportDocID desc)'
    exec sp_executesql @sqlQry

    If (Select Count(*) From #RptDocID) > 0 
    Begin
      Delete From tbl_mERP_UploadReportXMLTracker Where Status & 129 = 129 And ReportDocID in (Select RptID from #RptDocID)
    End

    Fetch From Cur_DelRpt Into @ReportID, @ReportName, @ArchiveCnt
  End
  Close Cur_DelRpt
  Deallocate Cur_DelRpt
  Drop table #RptDocID
End
