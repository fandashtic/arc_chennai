CREATE procedure sp_VajraInsertFileLog
@BatchFile nvarchar(2000) = null,
@FileCopied bit = 0,
@FileCopiedDate datetime = null,
@FileExecuted bit = 0,
@FileExecutionStartDate datetime = null,
@FileExecutionEndDate datetime = null,
@ErrorDetails nvarchar(1000) = null,
@Mode varchar(30) = 'insert',
@pkid bigint = 0
as
begin

if (@Mode = 'insert')
begin
insert into BatchFileLogs (BatchFileName) values (@BatchFile)

select IDENT_CURRENT('BatchFileLogs') pkid
end
else if (@Mode = 'update')
update BatchFileLogs set FileCopied = @FileCopied,
FileCopiedDate = case @FileCopied when null then null when '0' then null else getdate() end,
FileExecuted = @FileExecuted, FileExecutionStartDate = @FileExecutionStartDate,
FileExecutionEndDate = @FileExecutionEndDate, ErrorDetails = @ErrorDetails, ModifiedDate = getdate()
where pkid = @pkid
else if (@Mode = 'beginExecution')
update BatchFileLogs set FileExecutionStartDate = getdate(),
ModifiedDate = getdate() where pkid = @pkid
else if (@Mode = 'endExecution')
update BatchFileLogs set FileExecutionEndDate = getdate(),FileExecuted = 1,
ModifiedDate = getdate() where pkid = @pkid

end
