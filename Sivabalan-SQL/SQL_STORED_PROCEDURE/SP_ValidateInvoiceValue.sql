CREATE Procedure SP_ValidateInvoiceValue(@CustomerID nvarchar(50), @InvoiceValue Decimal(18,6))  
As
Begin
	Declare @MaxValue Decimal(18,2)
	Declare @Result int
	Declare @ErrorMessage nVarchar(500)
	
	Set @Result = 0
	Set @ErrorMessage = ''

	IF (Select isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'InvoiceValue') = 1
	Begin
		Select @MaxValue = [Value] From tblConfig_EffectFrom Where ScreenCode = 'InvoiceValue'

		IF Exists(Select 'x' From Customer Where CustomerID = @CustomerID and isnull(IsRegistered,0) = 0 and isnull(BillingAddress,'') = '')
		Begin
			IF @InvoiceValue >= @MaxValue			
			Begin
				IF (Select isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'UNREGINVLOCK') = 0
				Begin
					Set @Result = 1
					Set @ErrorMessage = 'Billing address is must when Taxable value is more than [' + Cast(@MaxValue as nvarchar) + '] for unregister customer.'
				End
				ELSE
				Begin
					Set @Result = 2
					Set @ErrorMessage = 'Billing address is must when Taxable value is more than [' + Cast(@MaxValue as nvarchar) + '] for unregister customer. Unable to Save invoice.'
				End
			End
		End
	End

	Select Result = @Result, ErrMsg = @ErrorMessage
End
