Create Procedure mERP_sp_GetScreenStatus(@ScreenName As nVarchar(100))
As
Begin
		Select ScreenCode, IsNull(Flag, 1) as Flag
		From tbl_mERP_ConfigAbstract 
		Where ScreenName = @ScreenName
End
