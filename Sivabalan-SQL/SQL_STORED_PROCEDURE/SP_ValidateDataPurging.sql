Create Procedure dbo.SP_ValidateDataPurging
As 
Begin

	Set DateFormat DMY
	Declare @ThisMonth as DateTime
	Declare @DayClose as DateTime
	Declare @Start as Int
	Declare @Value as Int

	Select @DayClose = LastInventoryUpload From Setup
	Set @Value = (Select Top 1 Isnull(Flag,0) From Tbl_Merp_ConfigAbstract Where Screencode = 'DATAPURGE')
	
	Set @Start = 0
	
	IF Isnull(@Value,0) = -1
	Begin
		Set @Start = 1
		Goto OUT
	End

	Select @ThisMonth = Cast((Cast(@Value as Nvarchar) + '/' + Cast(Month(Getdate()) as NVarchar) + '/'+ Cast(year(Getdate()) as Nvarchar)) as DateTime)
	
	If Not Exists(Select 'X' From ValidateDataPurging Where ProcessDate = @ThisMonth)
	Begin
		Insert Into ValidateDataPurging (ProcessDate,Status)
		Values(@ThisMonth,0)
	End

	If Exists(Select 'X' From ValidateDataPurging Where Isnull(Status,0) = 1 and Month(ProcessDate) = Month(Getdate()) and Year(ProcessDate) = Year(Getdate()))
	Begin
		Goto OUT
	End

	If Exists (Select 'X' From ValidateDataPurging Where ProcessDate = @ThisMonth And Isnull(Status,0) = 0)
	Begin
		If @DayClose >=  @ThisMonth
		Begin
			Set @Start = 1
		End
		Else
		Begin
			Set @Start = 0
		End
	End

OUT:
	Select @Start AS Flag

END
