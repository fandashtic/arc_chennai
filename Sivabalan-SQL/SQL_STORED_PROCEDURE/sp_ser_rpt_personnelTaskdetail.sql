CREATE procedure sp_ser_rpt_personnelTaskdetail(@personnelID nvarchar(50),@FromDate datetime,@Todate datetime)        
AS        
      
select         
'Task Description' = [Description],        
'Task Description' = [Description],        
'Start Date' = jobcardtaskallocation.StartDate,        
'Start Time' = isnull(dbo.sp_ser_StripTimeFromDate(Starttime),''),                                  
'End Date' = EndDate,        
'End Time' = isnull(dbo.sp_ser_StripTimeFromDate(Endtime),'')
from jobcardtaskallocation,taskmaster
where jobcardtaskallocation.personnelid  = @personnelID      
--and jobcardtaskallocation.jobcardid = jobcardabstract.jobcardid        
and jobcardtaskallocation.taskstatus = 2      
--and (IsNull(jobcardabstract.Status, 0) & 32) <> 0       
and (jobcardtaskallocation.startdate) between @FromDate and @Todate        
and jobcardtaskallocation.taskid = taskmaster.taskid        
--group by [Description],StartDate,StartTime,EndDate,EndTime      
    
  

