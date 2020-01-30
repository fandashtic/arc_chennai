CREATE Function Sp_Acc_GetOperatingDate(@GivenDate Datetime)
Returns DateTime
As
Begin
	Declare @OperatingDate DateTime
	
	Select @OperatingDate =  Operating_Date From SetUp
	If @OperatingDate Is Null
	Begin
		Set @OperatingDate = @GivenDate
	End
Return @OperatingDate
End

