CREATE Procedure sp_ser_jobcardTaskAllocation(@JobcardID int,@ProductCode nvarchar(15),                    
@Item_spec1 nvarchar(255),@TaskID nvarchar(255),@personnelName nvarchar(50),@Remarks nvarchar(255),
@TaskStatus int, @serialNo int, @StartWork int,@stdate nvarchar(50),@Sttime nvarchar(50) )                    
as                    
declare @ExistingpersonnelName nvarchar(50)                    
declare @personnelid nvarchar(50)                    
declare @TaskType int  
declare @JobFree int   
              
set nocount  on       
Select @ExistingpersonnelName = Isnull(Personnelname,''), 
	@TaskType = Isnull(TaskType,''), @JobFree = Isnull(JobFree,'')
	from Personnelmaster, jobcardtaskallocation                     
	where jobcardid = @JobcardID and product_code = @ProductCode and                     
	product_specification1 = @Item_spec1 and Taskid = @taskid and 
	Personnelmaster.personnelid = jobcardtaskallocation.PersonnelID and
	serialNo = @serialNo 

Set @personnelid  = NULL      
Select @personnelid  = personnelid from personnelmaster 
	where personnelname = @personnelName                    

if isnull(@Startwork,0) = 0 
begin
	set @Stdate = Null
	set @Sttime = Null
end
Else
Begin
	set @Stdate = @Stdate                    
	set @Sttime = @Sttime
End
      
if isnull(@personnelid,'') = ''       
begin       
	set @TaskStatus = 0                     
	set @Stdate = Null      
	set @StTime = Null      
End      
else       
begin       
	if (IsNull(@ExistingpersonnelName,'') = '')
	begin
		set @Stdate  = @Stdate
		set @Sttime = @Sttime
	end
end      
if (@PersonnelName = @ExistingpersonnelName or IsNull(@ExistingpersonnelName,'') = '')
Begin
	update JobCardTaskAllocation set PersonnelID  = @personnelid ,
	Taskstatus = @TaskStatus, Startdate = @Stdate, starttime = @Sttime,
	Remarks = @Remarks, LastUpdatedTime  = getdate(), startwork = @startwork
	where jobcardid = @JobcardID and Product_code = @ProductCode
	and product_specification1 = @Item_spec1 and Taskid = @Taskid
	and serialno = @SerialNo
	If @@RowCount = 0
	begin
		IF (IsNull(@PersonnelID,'') = '')
		begin 
			Insert into Jobcardtaskallocation (JobcardID,Product_Code,
			product_specification1,Type,TaskID,PersonnelID,Startdate,
			StartTime,Remarks,TaskStatus,
			CreationTime,LastUpdatedTime,TaskType,JobFree,startwork) values                    
			(@JobcardID,@Productcode,@Item_spec1,2,@Taskid,@PersonnelID,@Stdate,
			@Sttime,@Remarks,0,getdate(),getdate(),@TaskType,@JobFree,@startwork)                    
		end       
		else        
		begin          
			Insert into Jobcardtaskallocation (JobcardID,Product_Code,                    
			product_specification1,Type,TaskID,PersonnelID,Startdate,                    
			StartTime,Remarks,TaskStatus,    
			CreationTime,LastUpdatedTime,TaskType,JobFree,startwork) values                    
			(@JobcardID,@Productcode,@Item_spec1,2,@Taskid,@PersonnelID,@Stdate,                    
			@Sttime,@Remarks,1,getdate(),getdate(),@TaskType,@JobFree,@startwork)                    
		end      
	end                                   
End                    
Else if (@PersonnelName <> @ExistingpersonnelName)        
Begin  
	--PersonnelName NewTask Re assign and one row insert    
	update jobcardtaskallocation set TaskStatus = 4  where serialno = @serialNo                    
      
	If (IsNull(@PersonnelID,'') = '')       
		Insert into Jobcardtaskallocation (JobcardID, Product_Code,
		Product_specification1, Type, TaskID, PersonnelID, Startdate,
		StartTime, RefSerialNo, Remarks, TaskStatus,
		CreationTime, LastUpdatedTime, TaskType, JobFree, startwork) values
		(@JobcardID, @Productcode,@Item_spec1, 2, @Taskid, @PersonnelID,@Stdate,
		@Sttime, @SerialNo, @Remarks, 0, getdate(), getdate(), @TaskType, @JobFree, @startwork)
	else      
		Insert into Jobcardtaskallocation (JobcardID, Product_Code,
		Product_specification1, Type, TaskID, PersonnelID, Startdate, 
		StartTime, RefSerialNo, Remarks, TaskStatus,
		CreationTime, LastUpdatedTime, TaskType, JobFree, startwork) values
		(@JobcardID, @Productcode, @Item_spec1,2, @Taskid, @PersonnelID, @Stdate,
		@sttime, @SerialNo, @Remarks, 1, getdate(), getdate(), @TaskType, @JobFree, @startwork)
End                            
Set nocount  Off                     


