Create Procedure mERP_sp_Update_OtherReport_LastUploadDate(@LastUplDate DateTime, @RepID Int)
AS
Begin
	Update tbl_mERP_OtherReportsUpload Set LastUploadDate = @LastUplDate Where ReportID = @RepID
End
