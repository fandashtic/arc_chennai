CREATE Function Fn_GetOperartingDate(@GivenDate DateTime)
Returns DateTime
As
Begin
Declare @OperatingDate DateTime

Select @OperatingDate =  Operating_Date From SetUp
If @OperatingDate Is Null
	Set @OperatingDate = @GivenDate
Return @OperatingDate
End


