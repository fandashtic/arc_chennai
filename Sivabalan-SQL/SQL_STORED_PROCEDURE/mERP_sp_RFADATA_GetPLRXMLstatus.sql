
Create Procedure mERP_sp_RFADATA_GetPLRXMLstatus(@PLMONTH as nVarchar(10)) 
As
Begin
  Select 'Project Liability Report' ReportName, RptTrk.ReportFromDate, RptTrk.ReportToDate, RptTrk.UploadDate, RptTrk.AcknowledgeDate, 
  Case When (RptTrk.Status = 0 And XmlTrk.Status = 0) Then 'XML Generated' 
     When RptTrk.Status = 128 Then 'Uploaded to Central' 
     When (RptTrk.Status = 129 And XmlTrk.Status = 129) Then 'Ack Received' 
     Else 'XML Missing' End As 'Upload Status'
  from tbl_merp_UploadReportTracker RptTrk
  Left Outer Join tbl_merp_UploadReportXMLTracker XmlTrk On RptTrk.ReportDocID = XmlTrk.ReportDocID
  Where Substring(Convert(nVarchar(10),ReportFromDate,103),4,7)  = @PLMONTH
End

