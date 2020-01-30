CREATE procedure sp_ser_checkjobcard (@JobcardID as int) 
as 

Select 
IsNull((Select Count(*) from Issueabstract 
Where JobCardID = @JobCardID and IsNull(Status, 0) & 192 = 0),0) + 
IsNull((Select Count(*) from Jobcardtaskallocation 
Where JobCardID = @JobCardID and TaskStatus in (1,2)),0) 

