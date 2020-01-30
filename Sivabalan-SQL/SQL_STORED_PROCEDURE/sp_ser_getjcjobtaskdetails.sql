CREATE procedure sp_ser_getjcjobtaskdetails(@JobCardID Int,@ProductCode nvarchar(15),
@ItemSpec1 nvarchar(50),@JobID nvarchar(100))
as
Select j.TaskID, t.[Description], t.ServiceTax
from JobCardDetail j
Inner Join TaskMaster t on j.TaskID = t.TaskID 
Where j.JobCardID = @JobCardID and j.Product_Code = @ProductCode and j.Product_Specification1 = @ItemSpec1
and j.JobID = @JobID and j.SpareCode = ''


