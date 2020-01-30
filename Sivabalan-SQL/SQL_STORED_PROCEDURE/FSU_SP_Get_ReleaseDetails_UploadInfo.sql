CREATE procedure FSU_SP_Get_ReleaseDetails_UploadInfo  
as  
select ReleaseID,UpdateID,WDCode,Status from tblReleaseDetail where (status&64)=0  
