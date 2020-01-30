Create Procedure sp_ser_get_PendingJobCardsInfo
As

Select "Count"=Count(JobCardID),"JobCardDate" = Min(JobCardDate)
from JobCardAbstract 
where (IsNull(Status, 0) & 192) = 0 and (IsNull(Status, 0) & 32) = 0  
and (isNull( 
	(select Count(JCS.JobCardID)from JobCardSpares JCS
	where isNull(JCS.PendingQty,0)>0 and Isnull(JCS.SpareStatus, 0) <> 2 and   
 	JobCardAbstract.JobCardID=JCS.JobCardID ),0)  
	+ isNull(  
	(select Count(JCT.JobCardID)from JobCardTaskAllocation JCT   
 	where isNull(JCT.TaskStatus,0) in (0,1) and JCT.JobCardID = JobCardAbstract.JobCardID)  
	,0)) = 0

