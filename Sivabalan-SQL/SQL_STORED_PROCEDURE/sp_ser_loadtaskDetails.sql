CREATE procedure sp_ser_loadtaskDetails
(@JobcardID int, @Productcode nvarchar(15), @ItemSpec1 nvarchar(50))                   
as                               
Select JC.TaskID,taskmaster.[Description],                
JC.Startdate,  
JC.starttime, 
Personnelid = Isnull(JC.personnelid,''),   
'Remarks' = Isnull(JC.Remarks,''),   
'personnelname' = Isnull(personnelmaster.personnelname,''),
JC.SerialNo,
TaskStatus = Isnull(TaskStatus,0),
StartWork = Isnull(StartWork,0),
'LastStartTime' = (Select LASTJC.Starttime from JobcardTaskAllocation LASTJC Where 
	LASTJC.Serialno = (Select Max(MAXJC.Serialno) from JobcardTaskAllocation MAXJC 
	Where MAXJC.Product_Specification1 = JC.Product_Specification1 and 
	MAXJC.Product_Code = JC.Product_Code and MAXJC.JobcardID = JC.JobcardID and 
	MAXJC.TaskID = JC.TaskID and MAXJC.SerialNo <> JC.SerialNo))
from JobCardTaskAllocation JC
Inner Join TaskMaster On JC.TaskID = TaskMaster.TaskID
Left Outer Join Personnelmaster on JC.Personnelid = Personnelmaster.Personnelid
Where JC.jobcardID = @JobcardID and 
JC.Product_Code = @Productcode and 
JC.Product_Specification1 = @ItemSpec1 and 
IsNull(JC.TaskStatus,0) In (0,1)
order by Serialno



