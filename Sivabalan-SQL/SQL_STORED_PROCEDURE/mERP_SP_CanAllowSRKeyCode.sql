CREATE Procedure mERP_SP_CanAllowSRKeyCode(@KeyCode nVarchar(25))
As
Begin

	Declare @Result int
	Set @Result = 0

	IF @KeyCode = 'VBKEYF8'
	Begin
		IF (Select isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'SRF8') = 1
		Begin
				Set @Result = 1
		End
	End
	Else IF @KeyCode = 'VBKEYF9'
	Begin
		IF (Select isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'SRF9') = 1
		Begin
				Set @Result = 1
		End
	End
	
	Select @Result
End
