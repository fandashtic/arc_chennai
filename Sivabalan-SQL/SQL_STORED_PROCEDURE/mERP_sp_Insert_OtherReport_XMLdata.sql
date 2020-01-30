Create Procedure mERP_sp_Insert_OtherReport_XMLdata(@ReportDocID Int, @XMLData Image)
As
Begin
Insert into tbl_mERP_UploadReportXMLTracker(ReportDocID, BinaryXML, Status) Values(@ReportDocID, @XMLData, 0) 
End
