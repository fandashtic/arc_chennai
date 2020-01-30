create procedure FSU_SP_Update_ReleaseDetail(  
@ReleaseID int,  
@UpdateType int,  
--@ID int,  
@Status int,  
@LocalFilePath nvarchar(500),  
@ExtractedFilePath nvarchar(500)=null  
)  
as  
  
-- Updating tblUpdateDetail/tblDocumentDetail/tblMessageDetail  
if @UpdateType=1 --Update  
update tblUpdateDetail set LocalFilePath=@LocalFilePath,ExtractedFilePath=@ExtractedFilePath where ReleaseID=@ReleaseID --and UpdateID=@ID  
  
else if @UpdateType=2 --Document  
update tblDocumentDetail set LocalFilePath=@LocalFilePath where ReleaseID=@ReleaseID --and DocumentID=@ID  
update tblReleaseDetail set Status=Status ^ @Status where (ReleaseID=@ReleaseID) and (Status & @Status)=0  
update tblReleaseDetail set Status=Status ^ 4 where (ReleaseID=@ReleaseID) and (Status & 4)<>0  

