CREATE FUNCTION sp_ser_StripTimeFromDate(@CurrentTime datetime)      
RETURNS varchar(5)  
AS      
BEGIN      
DECLARE @hour int   
DECLARE @min int 
Declare @MinStr nvarchar(2)
SET @hour = DatePart(hh, @CurrentTime)      
SET @min = DatePart(mi, @CurrentTime)      
If len(@MIN)= 1 
Begin
	set @MinStr = '0' + CAST(@min AS nVARCHAR(2))		
End 
Else
Begin
	set @MinStr = CAST(@min AS nVARCHAR(2))		
End
RETURN CAST(@hour AS VARCHAR(2)) + ':' + @MinStr
END     

