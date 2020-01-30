IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'fn_Arc_GetMonthName')
BEGIN
    DROP FUNCTION [fn_Arc_GetMonthName]
END
GO
CREATE  FUNCTION fn_Arc_GetMonthName(@Month Int)    
RETURNS NVarchar(255)    
As    
Begin    
	Declare @MonthName as Varchar(5);
	SET @MonthName = 
	CASE
		WHEN ISNULL(@Month, 0) = 1 THEN 'Jan'
		WHEN ISNULL(@Month, 0) = 2 THEN 'Feb'
		WHEN ISNULL(@Month, 0) = 3 THEN 'Mar'
		WHEN ISNULL(@Month, 0) = 4 THEN 'Apr'
		WHEN ISNULL(@Month, 0) = 5 THEN 'May'
		WHEN ISNULL(@Month, 0) = 6 THEN 'Jun'
		WHEN ISNULL(@Month, 0) = 7 THEN 'Jul'
		WHEN ISNULL(@Month, 0) = 8 THEN 'Aug'
		WHEN ISNULL(@Month, 0) = 9 THEN 'Sep'
		WHEN ISNULL(@Month, 0) = 10 THEN 'Oct'
		WHEN ISNULL(@Month, 0) = 11 THEN 'Nov'
		WHEN ISNULL(@Month, 0) = 12 THEN 'Dec'
		ELSE  'Jan'
	END;

	RETURN @MonthName
End    
GO