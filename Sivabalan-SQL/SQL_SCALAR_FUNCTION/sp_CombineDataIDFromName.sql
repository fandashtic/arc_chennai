CREATE function sp_CombineDataIDFromName (@PInStrSource nvarchar(4000) = NULL,   
 @pInChrSeparator char(1) = ',')      
 RETURNS nVARCHAR(4000)  
AS   
BEGIN      
 DECLARE @CurrentStr nvarchar(2000)      
 DECLARE @ItemStr nvarchar(200)      
 Declare @Val nvarchar(4000)     
 Declare @Data1 nVarchar(100)   
 Declare @Qry nVarchar(4000)  
 SET @CurrentStr = @PInStrSource      
 set @val = ''  
 WHILE Datalength(@CurrentStr) > 0      
 BEGIN      
  IF CHARINDEX(@pInChrSeparator, @CurrentStr,1) > 0       
   BEGIN      
  SET @ItemStr = SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)                 
     SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1))         Select @Data1 = [Description]  From Awareness Where AwarenessID = @ItemStr  
  set @Val = @Val + ',' + @Data1     
      END      
   ELSE      
   BEGIN                      
  Select @Data1 = [Description]  From Awareness Where AwarenessID = @CurrentStr  
  set @Val = ltrim(@Val) + ',' + Ltrim(@Data1)   
  Set @Val = Substring(@Val,2,len(@val))      
        BREAK;      
    END       
 END      
 RETURN @val  
END      
  


