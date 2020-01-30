CREATE procedure sp_ser_rpt_TaskAnalysis
(@TaskName nvarchar(50), @FromDate datetime, @Todate datetime)
As
Select Serviceinvoicedetail.Taskid,
'Task ID' = Serviceinvoicedetail.Taskid,
'Task Description' = [Description], 
'No of Occurence' = Sum(1)
from serviceinvoiceabstract, serviceinvoicedetail, taskmaster
where                        
serviceinvoicedetail.taskid = taskmaster.taskid
and serviceinvoiceabstract.serviceinvoiceid = serviceinvoicedetail.serviceinvoiceid
and (IsNull(Serviceinvoiceabstract.Status,0) & 192) <> 192
and Isnull(Serviceinvoicedetail.Taskid,'')  <> '' and Isnull(Serviceinvoicedetail.sparecode,'') = '' 
and taskMaster.Description like @TaskName
and (Serviceinvoiceabstract.serviceinvoicedate between @FromDate and @Todate)
Group by Serviceinvoicedetail.Taskid, [Description]
Order by 3

