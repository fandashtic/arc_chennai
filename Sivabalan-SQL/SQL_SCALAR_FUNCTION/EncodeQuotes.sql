Create Function EncodeQuotes (@String as nvarchar(255))
Returns nvarchar(255)
As
Begin
Declare @temp as nvarchar(255)
Declare @Start as Int
Declare @Index as Int
Declare @bFound as Int

Set @Start = 1
Set @Index = CharIndex('''', @String, @Start)
Set @bFound = 0
While @Index <> 0
Begin
	Set @temp = IsNull(@temp, N'') + SubString (@String, @Start, (@Index - @Start + 1)) + ''''
	Set @Start = @Index + 1	
	Set @Index = CharIndex('''', @String, @Start)
	Set @bFound = 1
End
If @bFound = 0 
	Set @temp = @String
Else
	Set @temp = @temp + IsNull(SubString (@String, @Start, (Len(@String) - @Start + 1)), N'')
Return @temp
End

