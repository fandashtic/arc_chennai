Create Procedure mERP_sp_Allow_ToImport(@ScreenName nVarchar(100))
As
Begin
	--0 - Locked When Both AddNew And Modify Screen is locked  in the ConfigAbstract Table then dont load
	--the import screen.
	
	Declare @NewImport As Int
	Declare @ModifyImport As Int

	If @ScreenName = 'Import Customer'
	Begin
		Select @NewImport = isNull(Flag,1) From tbl_mERP_ConfigAbstract Where ScreenName = 'Import Customer Add'
		Select @ModifyImport = isNull(Flag,1) From tbl_mERP_ConfigAbstract Where ScreenName = 'Import Customer Modify'
	End
	Else if @ScreenName =  'Import Customer TMD' 
	Begin
		Select @NewImport = isNull(Flag,1) From tbl_mERP_ConfigAbstract Where ScreenName = 'Import Customer TMD Add'
		Select @ModifyImport = isNull(Flag,1) From tbl_mERP_ConfigAbstract Where ScreenName = 'Import Customer TMD Modify'
	End 
	Else If @ScreenName = 'Import Item'
	Begin
		Select @NewImport = isNull(Flag,1) From tbl_mERP_ConfigAbstract Where ScreenName = 'Import Item Add'
		Select @ModifyImport = isNull(Flag,1) From tbl_mERP_ConfigAbstract Where ScreenName = 'Import Item Modify'
	End
	Else If @ScreenName = 'Import Category'
	Begin
		Select @NewImport = isNull(Flag,1) From tbl_mERP_ConfigAbstract Where ScreenName = 'Import Category Add'
		Select @ModifyImport = isNull(Flag,1) From tbl_mERP_ConfigAbstract Where ScreenName = 'Import Category Modify'
	End
	Else If @ScreenName = 'Customer ActiveDeactive'
	Begin
		Select @ModifyImport = isNull(Flag,1) From tbl_mERP_ConfigAbstract Where ScreenName = 'Customer ActiveDeactive'
		Set @NewImport = 0
	End
	if @NewImport = 0 And @ModifyImport = 0 
		Select 0
	Else
		Select 1

End

