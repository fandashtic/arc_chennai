CREATE FUNCTION fn_SplitIn2Rows_CRN(@PInStrSource nvarchar(4000) = NULL, @pInChrSeparator char(1) = ',')    
RETURNS @ARRAY TABLE (ItemValue nVarchar(10) )    
AS    
BEGIN    
 DECLARE @CurrentStr nvarchar(2000)    
 DECLARE @ItemStr nVarchar(10)
     
 SET @CurrentStr = @PInStrSource    
      
 WHILE Datalength(@CurrentStr) > 0    
 BEGIN    
  IF CHARINDEX(@pInChrSeparator, @CurrentStr,1) > 0     
   BEGIN    
	SET @ItemStr = SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)
	SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1))    
	INSERT @ARRAY (ItemValue) VALUES (RTRIM(LTRIM(@ItemStr)))    
   END    
   ELSE    
   BEGIN                    
	INSERT @ARRAY (ItemValue) VALUES (RTRIM(LTRIM(@CurrentStr))) 
    BREAK;    
   END     
 END    
 RETURN    
END    
