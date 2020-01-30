Create procedure sp_ser_checkDuplicationTaskInJob 
	(@JobId nvarchar(100), @CheckJobId nvarchar(100)) 
as 
Select Count(*) from Job_Tasks J where J.JobId = @JobId and 
J.TaskID in (Select C.TaskID from Job_Tasks C Where C.JobId = @CheckJobId)

