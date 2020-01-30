Create Procedure mERP_SP_Get_ColRange(@nCol Int)
As
Begin
	Declare @i  Int
	Declare @CharVal Int
	Declare @Columns nVarchar(1000)
	
	Set @CharVal =  65
	Set @i = 1
	Set @Columns = ''
	While @i <= @nCol
	Begin
		
		Select @Columns = @Columns + ','+ char(@CharVal)
		Set @i = @i + 1
		Set @CharVal = @CharVal + 1
	End
	
	If @Columns <> ''
	Select @Columns =  Substring(@Columns,6,Len(@Columns))

	Select @Columns
End
