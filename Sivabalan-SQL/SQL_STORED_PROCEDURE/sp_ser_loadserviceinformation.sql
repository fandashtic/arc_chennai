CREATE procedure sp_ser_loadserviceinformation(@ServiceDescription nvarchar(255),
@ProductCode nvarchar(15),@Mode Int,@CustomerID nvarchar(50))
as
Declare @ServiceID nvarchar(50)
Declare @Locality Int, @Free int 
If @Mode  = 1
Begin
	Select @ServiceID = JobID, @Free = (case Isnull(Free, 0) when 1 then 0 else 1 end)
	From JobMaster Where JobName = @ServiceDescription

	Select @Locality = IsNull(Locality,1) from
	Customer Where CustomerID = @CustomerID

	Select Job_Tasks.TaskID, [Description], @Free * ServiceTax 'ServiceTax', 
	@Free * Rate 'rate', TaskDuration, 
	'ServiceTaxPercentage' = (case @Free when 0 then 0 else 
			IsNull(dbo.sp_ser_gettaxpercenatge(@Locality,Servicetax,1),0) end)
	From Job_Tasks, TaskMaster, Task_Items
	Where Job_Tasks.JobID = @ServiceID
	and Task_Items.TaskID = Job_Tasks.TaskID
	and Task_Items.Product_Code = @ProductCode
	and TaskMaster.TaskID = Job_Tasks.TaskID
End




