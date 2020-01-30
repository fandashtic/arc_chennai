Create Procedure mERP_sp_Update_OtherReport_UploadFlag(@ReportID Int)
As
Begin
  Declare @CurDate DateTime
  Set @CurDate = Getdate()
  
  If (Select isNull(ReportName,'') From tbl_mERP_OtherReportsUpload Where ReportID = @ReportID) = 'Edit Product Margin Report'
  Update tbl_mERP_ProdMargin_AuditLog Set RptUploadFlag = 1 Where IsNull(RptUploadFlag,0) = 0
  
End
