CREATE FUNCTION [dbo].[merp_fn_SplitIn2Cols_Disp](@PInStrSource nvarchar(4000) = NULL, @pInChrSeparator char(1) = '|')    
RETURNS @ARRAY TABLE (SchemeId int,PayoutId Int)    
AS    
BEGIN 

 DECLARE @CurrentStr nvarchar(4000)    
 DECLARE @SchemeId int
 Declare @PayoutId Int

 SET @CurrentStr = replace(@PInStrSource ,char(15),'|')

 WHILE Datalength(@CurrentStr) > 0    
 BEGIN    
	IF CHARINDEX(@pInChrSeparator, @CurrentStr,1) > 0     
	Begin 
		SET @schemeId = cast(SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)    as Int)
		SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1))    

		INSERT @ARRAY (SchemeId ,PayoutId) Values(@SchemeID, @CurrentStr)
	
	End	
	Else
		break;
 End
RETURN    
END    
