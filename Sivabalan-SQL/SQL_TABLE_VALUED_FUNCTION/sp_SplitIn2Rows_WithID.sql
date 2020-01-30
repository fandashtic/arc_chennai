CREATE FUNCTION sp_SplitIn2Rows_WithID(@PInStrSource nvarchar(4000) = NULL, @pInChrSeparator char(1) = ',')    
RETURNS @ARRAY TABLE (RowID int Identity,ItemValue nVARCHAR(1000) COLLATE SQL_Latin1_General_CP1_CI_AS)    
AS    
BEGIN    
 DECLARE @CurrentStr nvarchar(2000)    
 DECLARE @ItemStr nvarchar(200)    
     
 SET @CurrentStr = @PInStrSource    
      
 WHILE Datalength(@CurrentStr) > 0    
 BEGIN    
  IF CHARINDEX(@pInChrSeparator, @CurrentStr,1) > 0     
   BEGIN    
             SET @ItemStr = SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)    
                 SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1))    
   INSERT @ARRAY (ItemValue) VALUES (@ItemStr)    
      END    
   ELSE    
    BEGIN                    
    INSERT @ARRAY (ItemValue) VALUES (@CurrentStr)        
             BREAK;    
          END     
 END    
 RETURN    
END
