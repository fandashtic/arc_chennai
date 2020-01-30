CREATE Procedure sp_StateCodeValidation(@Customer nvarchar(250), @Type int)  
As
Begin

	IF @Type = 1
	Begin
		IF Exists(Select 'x' From Customer Where Company_Name = @Customer and isnull(BillingStateID,'') <> '')
			Select 1
		Else
			Select 0
	End
	Else
	Begin
		IF Exists(Select 'x' From Customer Where CustomerID = @Customer and isnull(BillingStateID,'') <> '')
			Select 1
		Else
			Select 0
	End

End
