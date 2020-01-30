CREATE procedure sp_VajraFetchFileList
as
begin

select pkid,FileName,DestinationPath,FileCopyFlag,FileExecutionFlag from VajraBatchFiles with (nolock)
where isactive = 1
order by ProcessingOrder

end
