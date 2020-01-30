
CREATE FUNCTION sp_ser_StripTimeDifference(@StartDate DateTime, @EndDate DateTime)      
RETURNS varchar(20)  
AS      
BEGIN      
DECLARE @hour int   
DECLARE @min int 
Declare @MinStr nvarchar(2)

Set @min = DateDiff(mi, @StartDate, @EndDate) % 60

If DateDiff(mi, @StartDate, @EndDate) < 60
	Begin
		Set @hour = 0
	End
Else
	Begin
		If DatePart(mi, @StartDate) <= DatePart(mi, @EndDate)
			Set @hour = DateDiff(hh, @StartDate, @EndDate)
		else
			Set @hour = DateDiff(hh, @StartDate, @EndDate) - 1
	End	


If len(@min)= 1 
Begin
	set @MinStr = '0' + CAST(@min AS nVARCHAR(3))		
End 
Else
Begin
	set @MinStr = CAST(@min AS nVARCHAR(3))		
End

RETURN CAST(@hour AS VARCHAR(100)) + ':' + @MinStr
END

