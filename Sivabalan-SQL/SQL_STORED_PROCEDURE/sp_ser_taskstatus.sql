CREATE procedure sp_ser_taskstatus(@Taskid nvarchar(50),@JobcardID int,
@Productcode nvarchar(15),@ItemSpec1 nvarchar(50))               
as  
select taskstatus from jobcardtaskallocation
where jobcardid = @Jobcardid 
and taskid = @Taskid 
and Product_Code = @ProductCode
and Product_Specification1 =  @ItemSpec1  
and IsNull(TaskStatus,0)= 2

