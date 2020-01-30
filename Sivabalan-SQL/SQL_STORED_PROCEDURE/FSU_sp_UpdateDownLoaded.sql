CREATE procedure FSU_sp_UpdateDownLoaded(@releaseId int,@FSUId int)    
as    
 declare @locPath nvarchar(500),@ret int--,@FSUId int    
-- set @FSUId=0    
--if exists(  
set @ret=0
select @locPath=LocalFilePath from tblUpdateDetail UD    
                        inner join tblReleaseDetail RD on UD.releaseID=RD.releaseID    
                                where (UD.FSUId=@FSUId) and (RD.status & 3=3)--)    
--select @locPath    
if not (isnull(@locPath,'empty')='empty')    
    begin    
        Update tblReleaseDetail set status=status|2 where releaseID=@releaseId     
        Update tblUpdateDetail set LocalFilePath=@locPath where releaseID=@releaseId     
        --set @ret=1    
    end    
--else    
--    begin    
--        set @ret=0     
--    end    
select @ret    

SET QUOTED_IDENTIFIER OFF
