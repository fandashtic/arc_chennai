Create Function mERP_Fn_ConcateSchemeDetail(@ID nvarchar(4000) = null, @Type int)
Returns nvarchar(max)
As
Begin
    Declare @SchemeID int
    Declare @Result nvarchar(max)
    Declare @Description nvarchar(500)
    Declare @ActiviyCode nvarchar(100) 		
    DECLARE @ProductTotals TABLE(SchemeId int)
	
    DECLARE @CurrentStr nvarchar(2000)
    Declare @PInStrSource char(1)    
    DECLARE @ItemStr int   
    
    
    SET @CurrentStr = @ID
    
	WHILE Datalength(@CurrentStr) > 0    
	BEGIN    
		IF CHARINDEX('|', @CurrentStr,1) > 0     
		BEGIN    
			SET @ItemStr = SUBSTRING (@CurrentStr, 1, CHARINDEX('|', @CurrentStr,1) - 1)    
			SET @CurrentStr = SUBSTRING (@CurrentStr, CHARINDEX('|', @CurrentStr,1) + 1, (Datalength(@CurrentStr) - CHARINDEX('|', @CurrentStr,1) + 1))    
			INSERT @ProductTotals (SchemeId) VALUES (@ItemStr)    
		END    
		ELSE    
		BEGIN                    
			INSERT @ProductTotals (SchemeId) VALUES (cast(@CurrentStr as int))       
			BREAK;    
		END     
	END
    declare Cur_Sch cursor for
	Select S.CS_RecSchID,ActivityCode,Description from 
    tbl_merp_schemeabstract S
    where S.SchemeID in (select Schemeid from @ProductTotals)
    Open Cur_Sch
	set @Result=''
	Fetch From Cur_Sch into @SchemeID,@ActiviyCode,@Description  
	While @@FETCH_STATUS=0 
    Begin			
		If @Type=1
		   set @Result=@Result+'|'+cast(@SchemeID as varchar)
        Else if @Type=2
			set @Result=@Result+'|'+@ActiviyCode
        Else if @Type=3
			set @Result=@Result+'|'+@Description        
        Fetch From Cur_Sch into @SchemeID,@ActiviyCode,@Description  
	End
	Close Cur_Sch
	Deallocate Cur_Sch	   
	Return SUBSTRING(@Result,2,len(@Result))
End
