Create Procedure mERP_getReportDesc @ReportName nvarchar(max)
AS
BEGIN
 If exists (Select top 1 XMLReportCode from reports_to_upload where  reportname =@reportname) 
 BEGIN
	Select top 1 XMLReportCode from reports_to_upload where  reportname =@reportname
 END
 ELSE
 BEGIN
	Select top 1 XMLReportCode from tbl_mERP_OtherReportsUpload where  reportname =@reportname 
 END
END
