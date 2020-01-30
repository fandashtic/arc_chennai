Create Function sp_acc_GetVersion()
Returns Int
As
Begin
	Declare @Start1 Int
	Declare @Start2 Int
	Declare @Version nVarchar(255)
	
	Select @Version = Version from Setup
	Set @Start1 = charindex (N'.', @Version) + 1
	Set @Start2 = charindex (N'.', @Version, @Start1)
	Set @Version = Substring(@Version, @Start1, @Start2-@Start1)
	Return @Version

End

