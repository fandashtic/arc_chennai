CREATE Procedure sp_Insert_ReportUploadDetail
(@ReportId Integer,@ParameterName nVarchar(50),@ParameterValue nVarchar(50))
as
Insert into ReportUploadDetail(ReportID,ParameterName,ParameterValue)
values (@ReportID,@ParameterName,@ParameterValue)


