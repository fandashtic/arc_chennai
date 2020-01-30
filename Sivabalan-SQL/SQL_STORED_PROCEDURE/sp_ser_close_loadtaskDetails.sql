CREATE procedure sp_ser_close_loadtaskDetails(@JobcardID int,@Productcode nvarchar(15),                
@ItemSpec1 nvarchar(50))                   
as                 
Select JT.TaskID, taskmaster.[Description],                
JT.Startdate, JT.Starttime,
'PersonnelId' = Isnull(JT.personnelid,''),              
'Remarks' = Isnull(JT.Remarks,''),
'TaskStatus' = Isnull(TaskStatus,0),
JT.Enddate, JT.Endtime,
'PersonnelName' = Isnull(personnelmaster.personnelname,''),
JT.SerialNo, 
lastendtime =   (Select LASTJC.Endtime from JobcardTaskAllocation LASTJC Where 
	LASTJC.Serialno = (Select Max(MAXJC.Serialno) from JobcardTaskAllocation MAXJC 
	Where MAXJC.Product_Specification1 = JT.Product_Specification1 and 
	MAXJC.Product_Code = JT.Product_Code and MAXJC.JobcardID = JT.JobcardID and 
	MAXJC.TaskID = JT.TaskID and MAXJC.SerialNo <> JT.SerialNo)) 
from JobcardTaskallocation JT 
Inner Join TaskMaster On JT.TaskID = TaskMaster.TaskID
Inner Join personnelmaster On JT.personnelid = Personnelmaster.personnelid
Where JT.jobcardID =@JobcardID and 
	JT.Product_Code = @Productcode and 
	JT.Product_Specification1 = @ItemSpec1 and 
	IsNull(TaskStatus,0) In (1,2) and isnull(StartWork, 0) = 1
order by serialno                 




