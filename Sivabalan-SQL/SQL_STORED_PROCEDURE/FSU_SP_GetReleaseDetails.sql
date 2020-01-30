CREATE procedure [dbo].[FSU_SP_GetReleaseDetails]   
(  
@mode int  
)                    
as            
BEGIN
--**************************************************************************************************************            
--*                                            Manual Installation                                             *            
--**************************************************************************************************************                   
create table #tmp(ReleaseID int,FSUID int)                  
insert into #tmp select  RD.ReleaseID,UD.FSUID FROM  tblReleaseDetail RD INNER JOIN                    
                     tblUpdateDetail UD ON RD.ReleaseID = UD.ReleaseID INNER JOIN                    
                         (select distinct FSUID from tblInstallationDetail where (Status & 64=0) and (Status & 4=4) and isnull(ReleaseID,0)=0 and Mode=1) TID ON UD.FSUID = TID.FSUID    --linking field,
						,tbl_merp_configabstract Config
                            where (((RD.status & 4 = 4) or (RD.status & 2 = 0)) and (RD.Status & 256)=0)--Filtering Records from tblReleaseDetail    
							And Config.ScreenCode='FSUCutoff'
							And TID.FSUID >= Cast(Description as int)                                      
        and (UD.IsSpecific=0) --Specific Patch Must be Download          
--If condition is written on 04-dec-2011 because in MISSING and CHECK case   
--it should not update the status of manually installaed FSUs  
if @mode=2                                
begin               
/* if it is directly updated to 320 then below stmt not required              
 --where RD.ReleaseID in (select ReleaseID from #tmp)                  
*/    
Update RD  set RD.Status=RD.Status ^ 256     
        FROM  tblReleaseDetail RD INNER JOIN                    
                     #tmp TRD ON RD.ReleaseID = TRD.ReleaseID            
/* --making 7 bit to zero        */    
Update RD  set RD.Status=RD.Status ^ 64                    
        FROM  tblReleaseDetail RD INNER JOIN                    
                     #tmp TRD ON RD.ReleaseID = TRD.ReleaseID            
                                    where RD.Status & 64=64       
            
        /*--where TID.FSUID in (select FSUID from #tmp)              */    
Update TID  set TID.Status=TID.Status ^ 64, TID.ReleaseID=TRD.ReleaseID                    
        FROM  tblInstallationDetail TID INNER JOIN                    
                     #tmp TRD ON TID.FSUID = TRD.FSUID and isnull(TID.ReleaseID,0)=0  
end                  
drop table #tmp                  
--*************************************Manual Installation end**************************************************            
            
--**************************************************************************************************************            
--*                Selecting those record which is either DownLoad failed or not downloaded                    *            
--**************************************************************************************************************                    
SELECT  RD.ReleaseID,RD.UpdateID,RD.WDCode,RD.UpdateType,UD.FullFileName,UD.chkSum,UD.Targettool,UD.FSUID                        
        FROM  tblReleaseDetail RD INNER JOIN                    
                     tblUpdateDetail UD ON RD.ReleaseID = UD.ReleaseID,tbl_merp_configabstract Config
                        where 
							Config.ScreenCode='FSUCutoff'
							And UD.FSUID >= Cast(Description as int)  And
						((RD.status & 4 = 4) or (RD.status & 2 = 0)) and (RD.Status & 256)=0 --4-->Download Failed 2-->Not Downloaded                    
Union all                    
SELECT  RD.ReleaseID,RD.UpdateID,RD.WDCode,RD.UpdateType,DD.[FileName],DD.chkSum,null,null                        
        FROM  tblReleaseDetail RD INNER JOIN                    
                      tblDocumentDetail DD ON RD.ReleaseID = DD.ReleaseID                     
                        where ((RD.status & 4 = 4) or (RD.status & 2 = 0)) --4-->Download Failed 2-->Not Downloaded                    
--********************************************End***************************************************************  

END
