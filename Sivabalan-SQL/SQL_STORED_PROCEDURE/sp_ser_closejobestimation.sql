CREATE procedure sp_ser_closejobestimation(@EstimationID Int)
as
Update EstimationAbstract
Set status = (isnull(status,0) | 128) 
Where EstimationID = @EstimationID

