Create Procedure sp_check_IF_CategoryCanBeDeactivated(@CategoryID as Int)
As
Begin
Declare @Deactivate Int
	if (Select Count(*) From ItemCategories Where ParentID = @CategoryID) > 0 
		Set @Deactivate = 0
	else
	begin
		If (Select Count(*) From Items Where CategoryID = @CategoryID ) > 0
			Set @Deactivate = 2
		else
			Set @Deactivate = 1
	end
	Select @Deactivate
End
