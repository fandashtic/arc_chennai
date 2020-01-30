CREATE procedure sp_ser_canceljobestimation(@EstimationID Int)
as

-- Reversing Item Information 
Update i Set i.Product_Status = 0
From EstimationDetail d  
Inner Join Item_Information i on d.Product_Code = i.Product_Code and d.Product_Specification1 = i.Product_Specification1
Where d.EstimationID = @EstimationID

-- Update abstract
Update EstimationAbstract
Set Status = (isnull(status,0) | 192)
Where EstimationID = @EstimationID 

