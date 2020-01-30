Create Procedure sp_ser_get_CountOpenJobEst
as
Select "Count" = Count(EstimationId),EstimationDate = Min(EstimationDate) 
From EstimationAbstract 
Where IsNull(Status,0)= 1
