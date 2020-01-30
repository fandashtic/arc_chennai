Create Procedure [SP_DayCloseModules]
AS
BEGIN

	select Module,DayCloseDate,Priority from DayCloseModules ORder by 3 
End 
