Create Procedure mERP_sp_UpdateUploadDate
AS
	Update Setup Set ReportUploadDate = (Select Min(LastUploadDate) From Reports_To_Upload)
