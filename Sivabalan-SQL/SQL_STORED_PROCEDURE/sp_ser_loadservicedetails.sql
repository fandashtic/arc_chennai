CREATE procedure [dbo].[sp_ser_loadservicedetails] 
(@EstimationID Int, @ProductCode nvarchar(15), @ItemSpec1 nvarchar(50))
as
Select Type,SpareCode,'SpareName' = dbo.sp_ser_getitemname(EstimationDetail.SpareCode),
JobName,EstimationDetail.JobID,EstimationDetail.TaskID,
'Description' =TaskMaster.[Description],Price,Quantity,
'SalesTaxPayable' =Case When IsNull(LstPayable,0) =0 then 
IsNull(CSTpayable,0) else IsNull(LSTPayable,0) end,SalesTax,
TaxSuffered_Percentage,TaxSuffered,EstimationDetail.UOM,
EstimationDetail.UOMQty,UOMPrice,ServiceTax_Percentage,EstimationDetail.ServiceTax,
EstimationDetail.TaskDuration,'UOMDescription' = UOM.[Description],Amount,NetValue, 
IsNull([Free],0) 'JobFree', serialno
from EstimationDetail,JobMaster,TaskMaster,UOM
Where EstimationID = @EstimationID and Product_Code = @ProductCode
and Product_Specification1 = @ItemSpec1 and IsNull(EstimationDetail.JobID,'') *= JobMaster.JobID
and IsNUll(EstimationDetail.TaskID, '') *= TaskMaster.TaskID
and EstimationDetail.UOM *= UOM.[UOM] 
order by serialno
