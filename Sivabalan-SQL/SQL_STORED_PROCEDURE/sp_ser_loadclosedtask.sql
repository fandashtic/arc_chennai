CREATE procedure sp_ser_loadclosedtask 
(@JobCardID as int, @Product_Code as nvarchar(15), @Product_Specification1 as nvarchar(50))   
as

Select 
	TaskMaster.TaskID, 
	TaskMaster.Description, 
	IsNull(EstimationDetail.Price,0) EstRate, 
	Task_Items.Rate, 
	IsNull(ServiceTaxMaster.Percentage,0) Percentage, 
	IsNull(ServiceTaxMaster.ServiceTaxCode,0) TaxCode, 
	JobcardTaskAllocation.SerialNo, 
	IsNull(JobcardTaskAllocation.TaskType, 0) TaskType,
	IsNull(JobMaster.JobName, '') 'JobName', IsNull(JobFree,0) JobFree, 
	IsNull(JobcardTaskAllocation.JobID,'') 'JOBID'
From JobcardAbstract 
Inner Join JobcardTaskAllocation On 
 	JobcardTaskAllocation.JobCardId = @JobCardID and 
	JobcardTaskAllocation.Product_Code = @Product_Code and 
	JobcardTaskAllocation.Product_Specification1 = @Product_Specification1 and 
	JobcardTaskAllocation.Taskstatus = 2  
Inner Join TaskMaster On TaskMaster.TaskID = JobcardTaskAllocation.TaskID 
Inner Join Task_Items On TaskMaster.TaskID = Task_Items.TaskID and 
	JobcardTaskAllocation.Product_Code = Task_Items.Product_Code 
Left Outer Join EstimationDetail On 
	EstimationDetail.EstimationID = JobcardAbstract.EstimationID and 
	JobcardTaskAllocation.Product_Code = EstimationDetail.Product_Code and 
	JobcardTaskAllocation.Product_Specification1 = EstimationDetail.Product_Specification1 and 
	JobcardTaskAllocation.TaskID = IsNull(EstimationDetail.TaskID,'') and 
	IsNull(EstimationDetail.SpareCode,'') = '' and 
	JobcardTaskAllocation.JobID = IsNull(EstimationDetail.JobID, '')
Left Outer Join ServiceTaxMaster On ServiceTaxMaster.ServiceTaxCode = TaskMaster.ServiceTax 
left Outer Join JobMaster On JobMaster.JobID = IsNull(JobcardTaskAllocation.JobID,'')
Where 
	JobcardAbstract.JobCardID = @JobCardID and 
	JobcardTaskAllocation.Product_Code = @Product_Code and 
	JobcardTaskAllocation.Product_Specification1 = @Product_Specification1  
Order by JobcardTaskAllocation.SerialNo





