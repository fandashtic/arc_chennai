CREATE FUNCTION sp_ser_StripDateFromTime(@CurrentDate datetime)  
RETURNS datetime  
AS  
BEGIN  
 DECLARE @Day int  
 DECLARE @Month int  
 DECLARE @Year int  
 SET @Day = DatePart(dd, @CurrentDate)  
 SET @Month = DatePart(mm, @CurrentDate)  
 SET @Year = DatePart(yyyy, @CurrentDate)  
 RETURN CAST(CAST(@Day AS VARCHAR) + '/' + CAST(@Month AS VARCHAR) + '/' + CAST(@Year AS VARCHAR) AS datetime)  
END 

