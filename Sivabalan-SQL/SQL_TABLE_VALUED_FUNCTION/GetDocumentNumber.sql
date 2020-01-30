Create Function GetDocumentNumber (@DocumentNumber nvarchar(255))
Returns @DocList Table(DocNo nvarchar(50))
As
Begin
Declare @Start Int
Declare @End Int
Declare @Len Int

Set @Len = Len(@DocumentNumber)
Set @Start = 1

While (@Start <= @Len)
Begin
	Set @End = CharIndex(',', @DocumentNumber, @Start)
	If @End = 0 Set @End = @Len + 1
	Insert Into @DocList Values (SubString(@DocumentNumber, @Start, @End - @Start))
	Set @Start = @End + 1
End
Return
End
