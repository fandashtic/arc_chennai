Create Procedure mERP_sp_Get_RFATranDate
As
	Declare @CloseDay DateTime

	If (Select IsNull(Flag, 0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01') > 0
	Begin
		Select @CloseDay = LastInventoryUpload From Setup
		Select 1, @CloseDay
	End
	Else
	Begin
		Select @CloseDay = TransactionDate From Setup 
		Select 0, @CloseDay
	End
	

