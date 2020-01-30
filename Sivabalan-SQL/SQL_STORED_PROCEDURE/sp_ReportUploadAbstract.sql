CREATE procedure sp_ReportUploadAbstract (@FromDate DateTime,@ToDate DateTime) as
select ReportId ,ReportName as [Report Name] ,CompanyID as [Forum Code],ReportDate as [Upload Date] from reportuploadabstract
where reportdate between @FromDate and @ToDate


