CREATE procedure sp_ser_loadjobcardservicedetails 
(@JobCardId Int,@Product_Code nvarchar(15),@ItemSpec1 nvarchar(50))
as

Select d.SerialNo, d.JobCardID, d.Product_Code, d.Product_Specification1,
d.Type, d.JobID, d.TaskID, d.SpareCode, d.Quantity, d.UOM, d.UOMQty,
d.SpareStatus, 'SpareName' = dbo.sp_ser_getitemname(d.SpareCode), 
'JobName' = JobMaster.JobName, 'TaskDesc' =TaskMaster.[Description], 
'UOMDesc' = UOM.[Description], Isnull(taskType,0) 'taskType', IsNull(JobFree, 0) 'JobFree'
from JobCardDetail d 
Left Outer Join JobMaster On JobMaster.JobID = d.JobID
Left Outer Join TaskMaster On TaskMaster.TaskId = d.TaskID 
Left Outer Join UOM On UOM.[UOM] = d.UOM
Where d.JobCardID = @JobCardId and d.Product_Code = @Product_Code and 
d.Product_Specification1 = @ItemSpec1
Order by SerialNo
