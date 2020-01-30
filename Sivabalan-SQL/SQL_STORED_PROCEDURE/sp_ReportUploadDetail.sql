CREATE Procedure sp_ReportUploadDetail (@ReportId integer) as
select ParameterName as [Parameter Name],ParameterName as [Parameter Name], ParameterValue as [Parameter Value] from ReportUploadDetail
where ReportId=@ReportId 


