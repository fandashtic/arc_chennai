
CREATE Procedure sp_get_Schemes_FreeUOM( @SCHEMEID as Int, @TOTQTY as Decimal(18,6))    
As    
DECLARE @HASSLAB as int
BEGIN
    SELECT @HASSLAB=ISNULL(HasSlabs,0) FROM Schemes Where SchemeID = @SCHEMEID
    IF @HASSLAB = 0 
	Select Top 1 FreeUOM From SchemeItems Where SchemeID = @SCHEMEID    
    Else
	Select FreeUOM From SchemeItems SI Where SI.SchemeID = @SCHEMEID    
	And (@TOTQTY Between  StartValue and EndValue)  
END  

