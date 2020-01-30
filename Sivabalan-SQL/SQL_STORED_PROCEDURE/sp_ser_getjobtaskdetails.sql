CREATE procedure sp_ser_getjobtaskdetails(@EstimationID Int,@ProductCode nvarchar(15),  
@ItemSpec1 nvarchar(50),@JobID nvarchar(100))  
as  
Select EstimationDetail.TaskID, TaskMaster.[Description],Price,ServiceTax_Percentage,  
EstimationDetail.ServiceTax,TaskDuration,Amount,NetValue   
from EstimationDetail, TaskMaster Where EstimationID = @EstimationID  
and Product_Code = @ProductCode and Product_Specification1 = @ItemSpec1  
and JobID = @JobID and isnull(SpareCode, '') = ''  
and EstimationDetail.TaskID = Taskmaster.TaskID  


