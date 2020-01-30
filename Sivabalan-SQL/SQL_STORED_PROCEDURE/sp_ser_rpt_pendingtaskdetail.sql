CREATE procedure sp_ser_rpt_pendingtaskdetail(@personnelid nvarchar(50),@FromDate datetime,@Todate datetime)    
As    
select 'Task ID' = JT.taskid,    
'Task ID' = JT.taskid,    
'Description' = [Description],    
'Start Work' = (Case Isnull(JT.startwork, -1) when 0 then 'No' when 1 then 'Yes' else '' end), 
'Start Date' = JT.startdate,    
'Start Time' = isnull(dbo.sp_ser_StripTimeFromDate(JT.Starttime),''),                                    
'JobCard ID' = JT.jobcardid,    
'JobCard Date' = JB.jobcarddate    
from Jobcardtaskallocation JT, taskmaster, Jobcardabstract JB   
where JT.personnelid = @personnelid    
and JT.jobcardid = JB.jobcardid    
and isnull(JT.taskstatus,0) =1  
and JT.taskid = taskmaster.taskid    
and (JB.Jobcarddate) between @FromDate and @Todate                    
and (IsNull(JB.Status,0) & 192) = 0                                          

