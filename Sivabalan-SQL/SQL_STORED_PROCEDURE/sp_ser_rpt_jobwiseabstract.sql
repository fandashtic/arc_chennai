CREATE procedure sp_ser_rpt_jobwiseabstract(@jobName nvarchar(15),@Fromdate datetime, @Todate datetime)                      
As                      
if @jobName <> '%'                    
Begin                    
                    
Select  A.jobName, 'Job Name' = A.JobName ,'No of Times' = Count(*)from                     
(select  jobcardtaskallocation.jobcardid, jobcardtaskallocation.Product_Specification1,                    
'Job ID' = jobcardtaskallocation.jobid, jobmaster.JobName                    
from jobcardtaskallocation, jobmaster, jobcardabstract                       
where taskstatus = 2                      
--and jobcardtaskallocation.jobid = @JobID                
and jobcardtaskallocation.jobid = jobmaster.jobid                       
and jobmaster.jobname like @jobname
and jobcardabstract.jobcardid =  jobcardtaskallocation.jobcardid                      
and (jobcarddate) between @FromDate and @ToDate                      
and (IsNull(jobcardabstract.Status, 0) & 32) <> 0                     
group by jobcardtaskallocation.jobcardid, jobcardtaskallocation.Product_Specification1,                    
jobcardtaskallocation.jobid, jobmaster.JobName) A                     
Group by A.JobName                    
End                    
Else                    
Begin                    
Select A.JobName, 'Job Name' = A.JobName ,'No of Times' = Count(*)from                     
(select jobcardtaskallocation.jobcardid, jobcardtaskallocation.Product_Specification1,                    
'Job ID' = jobcardtaskallocation.jobid,jobmaster.JobName                    
from jobcardtaskallocation, jobmaster, jobcardabstract                       
where taskstatus = 2                      
and jobcardtaskallocation.jobid = jobmaster.jobid                       
and jobcardabstract.jobcardid =  jobcardtaskallocation.jobcardid                      
and (jobcarddate) between @FromDate and @ToDate                      
and (IsNull(jobcardabstract.Status, 0) & 32) <> 0                     
group by jobcardtaskallocation.jobcardid, jobcardtaskallocation.Product_Specification1,                    
jobcardtaskallocation.jobid,jobmaster.JobName) A                    
Group by A.JobName                    
End   

