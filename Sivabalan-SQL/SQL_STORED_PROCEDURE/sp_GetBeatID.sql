
CREATE  Procedure sp_GetBeatID(@Beat nvarchar(250))
As
Begin
	Declare @ID int
	Select @ID = BeatID From Beat Where Description = @Beat
	
	If @ID >  0
		Select @ID
	Else
	Begin
		Insert Into Beat (Description) Values (@Beat)
		Select @@Identity
	End
	
End

