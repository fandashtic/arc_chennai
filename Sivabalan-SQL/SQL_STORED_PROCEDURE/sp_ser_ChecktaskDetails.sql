CREATE procedure sp_ser_ChecktaskDetails(@JobcardID int)                     
as             
select Count(*) from Jobcardtaskallocation 
where Jobcardid = @Jobcardid 
	and IsNull(TaskStatus,0) In (1,2) 
	and isnull(startwork, 0) = 1

