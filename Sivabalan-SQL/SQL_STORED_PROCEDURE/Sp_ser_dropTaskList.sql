CREATE Procedure Sp_ser_dropTaskList(@Jobid nvarchar(50),  
@Taskid nvarchar(4000),@Mode int)  
as  
if @mode = 1  
Begin  
	Create table #TempTask(Taskid1 nvarchar(50) collate SQL_Latin1_General_Cp1_CI_AS null)
	
	Insert into #TempTask 
	exec sp_ser_SqlSplit @Taskid,','

	delete from  job_Tasks  
	where jobid = @jobid and Taskid not in(select taskid1 from #TempTask)
	
	drop table #TempTask  
End    
Else if @Mode =2    
Begin    
	Delete job_tasks      
	Where jobid = @jobid    
End 
  


