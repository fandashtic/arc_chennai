CREATE Procedure [dbo].[FSU_sp_InsertThinserverInstallationDetail]   
As  
begin  
DECLARE @ClientID int;  
select @ClientID = max(ClientID) from tblClientMaster where IsServer = 1  
--PRINT @ClientID   
insert into tblInstallationDetail(  
ClientID ,ReleaseID ,SeverityType ,LocalPath,ExtractedFilePath,FSUID ,FileName ,Mode ,Targettool ,MaxSkip ,InstallationDate,Status)  
select @ClientID, RD.ReleaseID,SeverityType,UD.LocalFilePath+'\'+UD.FullFileName,UD.Extractedfilepath,UD.FSUID,UD.FileName,2 as "Mode",UD.TargetTool,UD.SkipCount,UD.InstallationDate,  
case when RD.Status & 2 = 2 then 1  
else 0  
end as "Status"  
from tblReleaseDetail RD   
 inner join tblUpdateDetail UD on RD.ReleaseId = UD.ReleaseID  
 where RD.Status & 2 = 2   
 And RD.status & 444= 0  
and RD.ReleaseID not in (Select isnull(ReleaseID,0) from tblInstallationDetail where ClientID=@ClientID  )  
-- Updating installation table status value if the download failed in InstallationDetail Table  
Update IND  
set IND.Status  = case when RD.Status & 2 = 2 then 1  
      else 0  
      end  
from tblInstallationDetail IND  
inner join tblReleaseDetail RD on IND.ReleaseId = RD.ReleaseID  
where RD.Status & 2 = 2   
And RD.status & 444 = 0  
AND IND.Status & 2 = 2  
And IND.Status & 124 = 0  
END 

SET QUOTED_IDENTIFIER OFF
