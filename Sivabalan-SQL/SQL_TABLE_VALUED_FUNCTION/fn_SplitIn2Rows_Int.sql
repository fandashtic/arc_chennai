CREATE FUNCTION fn_SplitIn2Rows_Int(@PInStrSource nvarchar(4000) = NULL, @pInChrSeparator char(1) = ',')    
RETURNS @ARRAY TABLE (ItemValue Int )    
AS    
BEGIN    
 DECLARE @CurrentStr nvarchar(2000)    
 DECLARE @ItemStr Int
     
 SET @CurrentStr = @PInStrSource    
      
 WHILE Datalength(@CurrentStr) > 0    
 BEGIN    
  IF CHARINDEX(@pInChrSeparator, @CurrentStr,1) > 0     
   BEGIN    
	SET @ItemStr = cast(SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)    as Int)
	SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1))    
	INSERT @ARRAY (ItemValue) VALUES (@ItemStr)    
   END    
   ELSE    
   BEGIN                    
	INSERT @ARRAY (ItemValue) VALUES (cast(@CurrentStr as Int))        
    BREAK;    
   END     
 END    
 RETURN    
END    
