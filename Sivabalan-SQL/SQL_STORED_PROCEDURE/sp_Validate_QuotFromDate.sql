Create Procedure sp_Validate_QuotFromDate(@FromDate Datetime, @ToDate Datetime)
As
Begin

Declare @Val int
Declare @ErrMsg as nvarchar(100)
Declare @GSTDate as Datetime
Declare @GSTFlag as int

Set Dateformat DMY
Set @Val = 0
Set @ErrMsg = ''

Select @GSTFlag = isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'
Select @GSTDate = dbo.Striptimefromdate(GSTDateEnabled) From Setup
Select @FromDate = dbo.Striptimefromdate(@FromDate)

IF @GSTFlag = 1
Begin
	IF @FromDate < @GSTDate
	Begin
		Set @Val = 1
		Set @ErrMsg = 'From Date is less than GST Enabled Date'
	End
End

Select @Val, @ErrMsg
End
