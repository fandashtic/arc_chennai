

CREATE Function SqlSplit1(@Text nvarchar(4000), @Delimiter nvarchar(15)) 
Returns @Y Table(field1 nvarchar(50))
As
begin
	Declare @LenText Int
	Declare @Start Int
	Declare @Index Int
	Declare @i Int
	Declare @X Table(field1 nvarchar(50))
	
	Set @LenText = Len(@Text)
	Set @Start = 1
	Set @Index = 0
	
	While @Start <= @LenText
	Begin
	    	Set @i = CharIndex(@Delimiter, @Text, @Start)
		If @i <> 0 
		Begin
			Insert into @x Values(substring(@Text,@Start,(@i-@Start)))
		        Set @Start = @i + 1
		        Set @Index = @Index + 1
	        End
	    	Else
		Begin
			Insert into @x Values(substring(@Text, @Start, (@LenText - @Start) + 1))
			Break        
		End
	End
	INSERT @Y
   	SELECT field1 FROM @X
   	RETURN

end




