
Create Procedure mERP_sp_GetGSTfromSetup
As
Begin
	Declare @IsGSTEnabled as Int
	Declare @BusinessNatureID as int
	Declare @BillingStateID as int
	Declare @ShippingStateID as int
	Declare @GSTIN as nVarChar(15)

	Select @IsGSTEnabled = Isnull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'
	If @IsGSTEnabled = 1 
	Begin
		select @BusinessNatureID = isnull(BusinessNatureID,0),@BillingStateID= isnull(BillingStateID,0),@ShippingStateID = isnull(ShippingStateID,0),@GSTIN = isnull(GSTIN,'')  From Setup
		If @BusinessNatureID = 0 or @BillingStateID = 0 or @ShippingStateID = 0 or @GSTIN = ''
			Select 'Business Nature Or Billing StateCode Or Shipping StateCode Or GSTIN is not Updated.'
		Else
			Select ''
	End
	Else
		Select ''

End
