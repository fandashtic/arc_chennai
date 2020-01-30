Create Procedure mERP_isValidTranDate
As
Begin
	Declare @CheckCloseDay as Int
	Declare @LastTranDate as Datetime
	Declare @LastDayCloseDate as Datetime
	Declare @CurrentDate  as Datetime
	Declare @GraceDays as Int
	Declare @GraceDate as Datetime
	Declare @ValidDate as Int

	Select @CheckCloseDay = isNull(Flag,0) From tbl_mERP_ConfigAbstract  where ScreenCode=N'CLSDAY01'
	Set @ValidDate = 1
	
	If @CheckCloseDay = 1
	Begin
		Select @LastDayCloseDate = dbo.StripTimeFromDate(LastInventoryUpload),
		@LastTranDate = dbo.stripTimeFromDate(TransactionDate) From  SetUp

		Select @GraceDays = isNull(Value,0) From  tbl_mERP_ConfigDetail  where ScreenCode=N'CLSDAY01' and Controlname=N'GracePeriod'

		Select @GraceDate = DateAdd(Day,@GraceDays,@LastDayCloseDate)

		Select @CurrentDate = dbo.StripTimeFromDate(GetDate())

		
		If (@CurrentDate <= @LastDayCloseDate) Or (@CurrentDate > @GraceDate)
			Set @ValidDate = 0
	End

	Select @ValidDate
	
	
End

