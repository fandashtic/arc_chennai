CREATE function sp_ConvertToSpace(@PInStrSource nvarchar(4000) = NULL, @pInChrSeparator char(1) = ',',  
 @Space Char(1)=' ')          
RETURNS nVARCHAR(1000)      
AS          
BEGIN          
 DECLARE @CurrentStr nvarchar(2000)          
 DECLARE @ItemStr nvarchar(200)          
 Declare @Val nvarchar(1000)          
-- Declare @Space Varchar(1)      
 SET @CurrentStr = @PInStrSource          
 set @val = ''      
 WHILE Datalength(@CurrentStr) > 0          
 BEGIN          
  IF CHARINDEX(@pInChrSeparator, @CurrentStr,1) > 0           
   BEGIN          
            SET @ItemStr = SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)                   
   SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1))          
  set @Val = @Val + @Space + @ItemStr         
      END          
   ELSE          
    BEGIN                          
  set @Val = ltrim(@Val) + @Space + Ltrim(@CurrentStr)  
    set @Val = ltrim(@Val)  
  If @Space <> ' '  
  Begin  
   set @Val = Substring(@Val,2,len(@Val))  
  End         
             BREAK;          
          END           
 END          
 RETURN @val      
END          
      
    
  


