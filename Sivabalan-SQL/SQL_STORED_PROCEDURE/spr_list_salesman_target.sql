CREATE PROCEDURE [dbo].[spr_list_salesman_target](@SALESMAN int)
AS
SELECT  SalesmanID, "Target" = Target, 
	"Target Measure" = TargetMeasure.Description, 
	"Period" = TargetPeriod.Period,
	"Remarks" = Remarks
FROM SalesmanTarget
Left Outer Join TargetMeasure ON SalesmanTarget.MeasureID = TargetMeasure.MeasureID
Left Outer Join TargetPeriod ON SalesmanTarget.Period = TargetPeriod.PeriodID
WHERE SalesmanTarget.MeasureID = TargetMeasure.MeasureID AND 
SalesmanTarget.SalesmanID = @SALESMAN AND
SalesmanTarget.Period = TargetPeriod.PeriodID
