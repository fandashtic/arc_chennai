CREATE Procedure sp_ser_rpt_TaskAnalysisDetail
(@TaskID nvarchar(50),@FromDate datetime,@Todate datetime)  
As  
Declare @Count as Decimal 

Select @Count = Count(*)  
from jobcardtaskallocation,serviceinvoiceabstract
Where jobcardtaskallocation.TaskID = @TaskID
and (Serviceinvoiceabstract.serviceinvoicedate between @FromDate and @Todate)
and (IsNull(Serviceinvoiceabstract.Status,0) & 192) <> 192  
and serviceinvoiceabstract.jobcardid = jobcardtaskallocation.jobcardid  
and Isnull(Taskstatus,0) = 2  
group by TaskID

Select 'Personnel ID' = jobcardtaskallocation.personnelid,  
'Personnel ID' = jobcardtaskallocation.personnelid,  
'Personnel Name' = PersonnelMaster.PersonnelName,  
'No of Occurance' = Count(*),   
'No of Occurance%' = Cast(((Count(*) * 100) / @Count) as Decimal(18,6)) 
from jobcardtaskallocation,serviceinvoiceabstract,personnelmaster  
where personnelmaster.personnelid = jobcardtaskallocation.personnelid          
and serviceinvoiceabstract.jobcardid = jobcardtaskallocation.jobcardid  
and Isnull(Taskstatus,0) = 2  
and (Serviceinvoiceabstract.serviceinvoicedate) between @FromDate and @Todate                  
and (IsNull(Serviceinvoiceabstract.Status,0) & 192) <> 192  
and jobcardtaskallocation.TaskID  = @TaskID
group by jobcardtaskallocation.PersonnelID,personnelmaster.PersonnelName


