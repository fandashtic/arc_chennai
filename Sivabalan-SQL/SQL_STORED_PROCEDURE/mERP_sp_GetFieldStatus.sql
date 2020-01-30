Create Procedure mERP_sp_GetFieldStatus(@ScreenCode nVarchar(100),@Flag Int = -1)
As
Begin
	If @Flag = -1
		Select ControlName, ControlIndex, isNull(Flag,1) As Flag,AllowConfig, TabIndex, TabLevel
		From tbl_mERP_ConfigDetail
		Where ScreenCode = @ScreenCode	
	Else
		Select ControlName, ControlIndex, isNull(Flag,1) As Flag,AllowConfig, TabIndex, TabLevel
		From tbl_mERP_ConfigDetail
		Where ScreenCode = @ScreenCode	And isNull(Flag,1) = @Flag
End

