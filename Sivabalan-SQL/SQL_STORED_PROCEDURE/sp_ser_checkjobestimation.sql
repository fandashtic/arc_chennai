CREATE Procedure sp_ser_checkjobestimation(@EstimationID as int)
as    
	Select "Status" = isNull(Status,0) from EstimationAbstract
	where (isNull(Status,0) & 192 = 192 or isNull(Status,0) & 128 = 128)
	and EstimationID = @EstimationID
