CREATE procedure sp_ser_loadEstimationinfo(@JobCardID int)
as
Declare @Prefix nvarchar(15)
Select @Prefix = Prefix
from VoucherPrefix Where TranID = 'JOBESTIMATION'

Select @Prefix 'Prefix', e.DocumentID,  e.EstimationID,  e.EstimationDate from JobCardAbstract J 
Inner Join EstimationAbstract e on e.EstimationID = j.EstimationID 
Where j.JobCardId = @JobCardID

