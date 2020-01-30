create procedure FSU_sp_ResetStatus_tblReleaseDetail(  
@ReleaseID int,  
@Status int,  
@BitValue int)  
as  
-- Updating tblReleaseDetail  
if @BitValue=0  
update tblReleaseDetail set Status=Status ^ @Status where (ReleaseID=@ReleaseID) and (Status & @Status)<>0  
else  
update tblReleaseDetail set Status=Status ^ @Status where (ReleaseID=@ReleaseID) and (Status & @Status)=0  
Select "Rows" =  @@ROWCOUNT   

