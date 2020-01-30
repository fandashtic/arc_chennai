Create Procedure mERP_sp_Update_UploadReportTracker(@ReportID int, @XMLFileName nVarchar(510))    
as    
Begin    
  Update  RptTracker Set XMLDocName =@XMLFileName, Status = Status | 1,   
--AckStatus =  1,  
  UploadCounter = UploadCounter + 1,
  UploadDate = Getdate()   
  From tbl_merp_UploadReportTracker RptTracker        
  where ReportDocID =@ReportID        
        
  Update tbl_merp_UploadReportXMLTracker Set Status = 128 Where ReportDocID = @ReportID       
End
