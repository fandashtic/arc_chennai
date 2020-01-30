create function sp_acc_SqlSplitDenominations(@Text nVarchar(4000), @Delimiter nVarchar(15)) 
Returns @X Table(Field1 nVarchar(250))
As
Begin
--	Declare @X Table(Field1 Varchar(250))
	Declare @LenText Int
	Declare @Start Int
	Declare @Index Int
	Declare @i Int
	
	
	Set @LenText = Len(@Text)
	Set @Start = 1
	Set @Index = 0
	
	While @Start <= @LenText
	Begin
	    	Set @i = CharIndex(@Delimiter, @Text, @Start)
		If @i <> 0 
		Begin
			Insert into @x Values(SubString(@Text,@Start,(@i-@Start)))
		        Set @Start = @i + 1
		        Set @Index = @Index + 1
	        End
	    	Else
		Begin
			Insert into @X Values(SubString(@Text, @Start, (@LenText - @Start) + 1))
			Break        
		End
	End

Return --(Select Field1 from @X)
End










