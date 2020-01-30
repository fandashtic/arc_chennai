Create Procedure dbo.SP_ValidateItemDeactivation (@Flag Int = Null)
As 
Begin

	Set DateFormat DMY
	Declare @ThisMonth as DateTime
	Declare @DayClose as DateTime
	Declare @Start as Int
	Declare @ConfigDaycloseDate as Int

	Set @Start = 0
	If Exists(Select 'x' From Tbl_Merp_ConfigAbstract Where Screencode = 'ITEMDEACTINIT' And Isnull(Flag,0) = 1)
	Begin
		Set @Start = 1
		Goto OUT
	End

/* The Item deactivation process should run once the day close is performed for 8th date of the every month.*/
	Set @ConfigDaycloseDate = 08

	Select @DayClose = LastInventoryUpload From Setup

	Select @ThisMonth = Cast((Cast(@ConfigDaycloseDate as Nvarchar) + '/' + Cast(Month(Getdate()) as NVarchar) + '/'+ Cast(year(Getdate()) as Nvarchar)) as DateTime)

	If Not Exists(Select 'X' From ValidateItemDeactivation Where ProcessDate = @ThisMonth)
	Begin
		Insert Into ValidateItemDeactivation (ProcessDate,Status)
		Values(@ThisMonth,0)
	End

	If Exists(Select 'X' From ValidateItemDeactivation Where Isnull(Status,0) = 1 and Month(ProcessDate) = Month(Getdate()) and Year(ProcessDate) = Year(Getdate()))
	Begin
		Goto OUT
	End

	If Exists (Select 'X' From ValidateItemDeactivation Where ProcessDate = @ThisMonth And Isnull(Status,0) = 0)
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
	If Isnull(@Flag,0) = 1
	Begin
		Update ValidateItemDeactivation set Status = 1,Modifydate = Getdate() Where ProcessDate = @ThisMonth
		Update Tbl_Merp_ConfigAbstract Set Flag = 0 Where Screencode = 'ITEMDEACTINIT' And Isnull(Flag,0) = 1
	End
	Else
	Begin
		Select @Start AS Flag
	End

END
