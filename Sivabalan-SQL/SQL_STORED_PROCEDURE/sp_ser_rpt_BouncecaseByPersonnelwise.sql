CREATE Procedure sp_ser_rpt_BouncecaseByPersonnelwise 
(@Fromdate datetime, @Todate datetime)  
As  
Select pb.PersonnelID, pb.PersonnelID 'PersonnelID', pb.PersonnelName 'Personnel Name', 
'No of Bounce Cases' = Sum(1)
from JobCardAbstract j 
Inner Join JobCardTaskAllocation jt On j.JobCardID = jt.JobCardID and jt.Type = 2 and 
	IsNull(jt.TaskStatus, 0) = 2  and (IsNull(jt.TaskType,0) = 1) 
Inner Join 
	(Select d.JobCardID, d.Product_Code, d.Product_Specification1, 
	IsNull(d.TaskId,'') TaskID, IsNull(d.JobCardID_Bounced, 0) BounceJCID 
	from JobcardDetail d 
	Where d.Type = 2 and IsNull(d.SpareCode, '') = '' and (IsNull(d.TaskType,0) = 1)) jd  
	On j.JobcardID = jd.JobcardID and jt.Product_Code = jd.Product_Code and 
	jt.Product_Specification1 = jd.Product_Specification1 and jt.TaskID = jd.TaskID 
Inner Join 
	(Select jtb.JobcardID, jtb.Product_Specification1, jtb.PersonnelID, 
	jtb.Product_Code, jtb.TaskID from JobCardTaskAllocation jtb 
	Where jtb.Type = 2 and IsNull(jtb.TaskStatus, 0) = 2) b
--	Where jtb.Type = 2 and IsNull(jtb.TaskStatus, 0) = 2 and IsNull(TaskType,0) = 1) b
	On b.JobcardID = jd.BounceJCID and b.Product_Code = jd.Product_Code and
	b.Product_Specification1 = jd.Product_Specification1 and b.TaskID = jd.TaskID
Inner Join PersonnelMaster pb On pb.PersonnelID = b.PersonnelID
Where (IsNull(j.Status, 0) & 192 <> 192) and (j.JobcardDate between  @FromDate and @ToDate) 
Group by pb.PersonnelID, pb.PersonnelName
order by pb.PersonnelID, pb.PersonnelName



