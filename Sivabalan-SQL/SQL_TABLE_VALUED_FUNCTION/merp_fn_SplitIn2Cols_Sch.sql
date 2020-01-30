CREATE FUNCTION merp_fn_SplitIn2Cols_Sch(@PInStrSource nvarchar(4000) = NULL, @pInChrSeparator char(1) = '|')    
RETURNS @ARRAY TABLE (SchemeId int,SlabId Int,SchemeAmount decimal(18,6),SchemePerc decimal(18,6))    
AS    
BEGIN    
-- Declare @PInStrSource nvarchar(4000) 
-- set @PInStrSource	= '48|1|4|2.244540|'
-- Declare @pInChrSeparator char(1) 
-- set @pInChrSeparator = '|'
-- Declare @ARRAY TABLE (SchemeId int,SlabId Int,SchemeAmount decimal(18,6),SchemePerc decimal(18,6))    
 DECLARE @CurrentStr nvarchar(4000)    
 DECLARE @SchemeId int
 Declare @SlabId Int
 Declare @SchemeAmount decimal(18,6)
 Declare @SchemePerc decimal(18,6)
Declare @szSchAmt nVarchar(4000)
 	
 
 SET @CurrentStr = replace(@PInStrSource ,char(15),'|')   + '|'
 
 WHILE Datalength(@CurrentStr) > 0    
 BEGIN    
  IF CHARINDEX(@pInChrSeparator, @CurrentStr,1) > 0     
   BEGIN    
	SET @schemeId = cast(SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)    as Int)
	SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1))    
	SET @SlabId = cast(SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)    as Int)	
	SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1))    

-- Schemsale
--SET @SchemeAmount = cast(SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)    as decimal(18,6))
		--Set @szSchAmt = Substring(@SchDetail,1,Charindex('|',@SchDetail) - 1)
		Set @szSchAmt = SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)   
		if (Charindex('E+',@szSchAmt) > 0  Or Charindex('E-',@szSchAmt) > 0)
			set @SchemeAmount = convert(decimal(18,6), str(@szSchAmt, 18, 6))
		Else
			set @SchemeAmount = cast(@szSchAmt as decimal(18,6))
-- Schemsale

	SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1))    
	SET @SchemePerc = cast(SUBSTRING (@CurrentStr, 1, CHARINDEX(@pInChrSeparator, @CurrentStr,1) - 1)    as decimal(18,6))
	SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX(@pInChrSeparator, @CurrentStr,1) + 1))    
	INSERT @ARRAY (SchemeId ,SlabId ,SchemeAmount ,SchemePerc) VALUES (@SchemeId ,@SlabId ,@SchemeAmount ,@SchemePerc)    
   END    
   ELSE    
   --BEGIN                    
	--
    BREAK;    
   --END     
 END    
 RETURN    
END    
