CREATE procedure sp_ser_Save_closejobcard(@JobcardID int,@ProductCode nvarchar(15),
@Item_spec1 nvarchar(255), @TaskID nvarchar(50), @PersonnelName nvarchar(255),
@TaskStatus nvarchar(20), @Remarks nvarchar(255), @SerialNo int,
@Enddate nvarchar(20), @EndTime nvarchar(30), 
@ReworkPersonnelName nvarchar(255) = Null, 
@StartWork int = Null, @ReworkRemarks nvarchar(500) = Null, @StartDate nvarchar(20) = Null, 
@StartTime nvarchar(30) = Null)
as            
declare @ExistingpersonnelName nvarchar(50)
declare @personnelid nvarchar(50)
declare @Status as int
declare @TaskType int
declare @JobFree int 
declare @ExistStatus as int
declare @JobID as nvarchar(50)
	
/*Previously existing personnel information*/            
Select @ExistingpersonnelName = Isnull(Personnelname,''), @ExistStatus = TaskStatus, 
@TaskType = Isnull(TaskType,''), @JobFree = Isnull(JobFree,''), 
@JobID = IsNull(JobID,'')
From Personnelmaster, Jobcardtaskallocation                               
Where Jobcardid = @JobcardID and Product_code = @ProductCode and
Product_specification1 = @Item_spec1 and Taskid = @taskid and 
Personnelmaster.personnelid = Jobcardtaskallocation.PersonnelID and                               
SerialNo = @serialNo                               
                
/* Input personnelID */            
Set @Personnelid  = NULL
Select @Personnelid  = personnelid from personnelmaster 
where personnelname = @personnelName
set @Status = (select 
case @Taskstatus when 'Closed' then 2 when 'Rework' then 5 else '' end)
select @Status
/*Closed*/            
Select @Status
If @Status = 2
begin
	If @ExistStatus = 2
	begin
		update JobCardTaskAllocation set Remarks = @Remarks, 
		Enddate = @Enddate, Endtime = @EndTime
		where Jobcardid = @JobcardID and Product_code = @ProductCode
		and Product_specification1 = @Item_spec1 and Taskid = @Taskid
		and Serialno = @SerialNo
	end
	else
	begin
		update JobCardTaskAllocation set PersonnelID  = @personnelid,
		Taskstatus = @Status, enddate = @Enddate, endtime = @EndTime, 
		Remarks = @Remarks, LastUpdatedTime  = getdate()
		where Jobcardid = @JobcardID and Product_code = @ProductCode                               
		and product_specification1 = @Item_spec1 and Taskid = @Taskid                        
		and serialno = @SerialNo                  
	end             
End /* End of Close */            
else If (@Status = 5) /* Rework */           
begin           
	set @Personnelid = null 
	Select @Personnelid  = Personnelid from Personnelmaster 
	where Personnelname = @ReworkPersonnelName
	If (isnull(@ReworkPersonnelName, '') <> '')           
	begin           
		update Jobcardtaskallocation set TaskStatus = 5,
		LastUpdatedTime  = getdate()
		where Serialno = @serialNo

		Insert into Jobcardtaskallocation (JobcardID, Product_Code,
		Product_specification1, Type, TaskID, PersonnelID, startdate,
		starttime, RefSerialNo, Remarks, TaskStatus, 
		CreationTime, LastUpdatedTime, TaskType, JobFree, JobID, Startwork) 
		values (@JobcardID, @Productcode, 
		@Item_spec1, 2, @Taskid, @PersonnelID, @StartDate,
		@StartTime, @SerialNo, @ReworkRemarks, 1, 
		getdate(), getdate(), @TaskType, @JobFree, @JobID, @Startwork)
	end        
	else           
	begin          
		update jobcardtaskallocation set TaskStatus = 5,          
		LastUpdatedTime  = getdate()          
		where serialno = @serialNo

		Insert into Jobcardtaskallocation (JobcardID, Product_Code,
		Product_specification1, Type, TaskID, PersonnelID, Startdate,
		StartTime, Enddate, Endtime, RefSerialNo, Remarks, TaskStatus,
		CreationTime, LastUpdatedTime, TaskType, JobFree, JobID, Startwork) 
		values (@JobcardID, @Productcode, 
		@Item_spec1, 2, @Taskid, @PersonnelID, @StartDate,
		@StartTime, Null, Null, @SerialNo, @Remarks, 0, 
		getdate(), getdate(), @TaskType, @JobFree, @JobID, @Startwork)
	end
End /*End of Rework*/          
else if isnull(@Status,'') = ''
begin
	update JobCardTaskAllocation set Remarks = @Remarks
	where jobcardid = @JobcardID and Product_code = @ProductCode
	and product_specification1 = @Item_spec1 and Taskid = @Taskid
	and serialno = @SerialNo
end          


