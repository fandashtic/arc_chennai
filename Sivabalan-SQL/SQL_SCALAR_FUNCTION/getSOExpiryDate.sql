Create Function dbo.getSOExpiryDate()
Returns Datetime
AS
BEGIN
	Declare @ExpiryDate datetime
	Declare @CurrentDate Datetime
	Declare @FlagValue int
	Set @CurrentDate=getdate()

	/*Flag is enabled,so check the expiry date*/
	If (select isnull(Flag,0) from Tbl_merp_Configabstract where ScreenCode='SOEXPIRY')=1
	BEGIN
		Select @FlagValue= isnull(value,0) from Tbl_merp_ConfigDetail where ScreenCode='SOEXPIRY' and ControlName='Expiry'
		set @ExpiryDate=Dateadd(d,(-@FlagValue)+1,getdate())
	END
	ELSE
	BEGIN
		Set @ExpiryDate='01/01/1900'
	END
Return Convert(Nvarchar(10),@ExpiryDate,103) 
END
