CREATE procedure FSU_SP_Update_RecvResponse_ReleaseDetail(@Cond as nvarchar(max))      
as      
declare @sql nvarchar(max)    
set @sql = N'update tblReleaseDetail set Status=Status ^ 64 where (status&64)=0 and ' + @Cond    
EXECUTE sp_executesql @sql 
