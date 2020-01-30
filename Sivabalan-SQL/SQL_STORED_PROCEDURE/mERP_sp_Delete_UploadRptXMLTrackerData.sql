Create Procedure mERP_sp_Delete_UploadRptXMLTrackerData
As
Begin
  Delete from tbl_merp_UploadReportXMLTracker Where ReportDocId in (
  Select ReportDocID from tbl_merp_UploadReportTracker Where IsNull(AckStatus,0) & 132 = 132 And IsNull(Status,0) & 128 = 128)
End
