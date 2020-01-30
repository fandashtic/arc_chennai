CREATE Procedure mERP_SP_CanAllowSRWithoutReference
As
Begin
	Set DateFormat DMY
	Declare @CurrentDate Datetime
	Declare @EffectFrom Datetime
	Declare @Result int

	Set @Result = 0
	Select @CurrentDate = dbo.Striptimefromdate(Getdate())

	IF (Select isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'GSTaxEnabled') = 1
	Begin 
		IF (Select isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'SRWithoutReference') = 1
		Begin
			Select @EffectFrom = dbo.Striptimefromdate(EffectFrom) From tblConfig_EffectFrom Where ScreenCode = 'SRWithoutReference'
			IF @CurrentDate >= @EffectFrom
				Set @Result = 1
		End	
	End

	Select @Result
End
