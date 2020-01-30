CREATE Procedure sp_ser_rpt_Jobs    
as    
Select JobID,'JobID' = JObID, 'Job Name' = JobName,    
(case Isnull(JobMaster.[Free],0) when 0 then 'No' when 1 then 'Yes'else '' end) as 'Free',     
(case JobMaster.Active when 1 then 'Active' when 0 then 'Inactive'else '' end) as 'Active'     
from Jobmaster    

