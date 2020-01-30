CREATE Procedure sp_Insert_ReportUploadAbstract 
(@ReportDate datetime,@CompanyID nVarchar(6),@ReportName nVarchar(50),@Frequency Integer,@Status nVarchar(10))
as 
Insert into ReportUploadAbstract (ReportDate,CompanyID,ReportName,Frequency,Status) 
values (@ReportDate ,@CompanyID ,@ReportName ,@Frequency ,@Status)
select @@Identity as ReportID


