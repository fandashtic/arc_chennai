Create Procedure dbo.Sp_SKUOPT_CheckMonthEnd (@Givendate DateTime)
As  
Begin 
	Set DateFormat DMY
	Declare @LastMonthFirstdate as DateTime
	Declare @CurrnetMonthEnd as DateTime
	Declare @GraceTodate as DateTime
	Declare @GraceDay as Int
	Set @GraceDay = (Select Top 1 [Value] from tbl_merp_configdetail where screencode='SKUOPT')
	Set @CurrnetMonthEnd = DateAdd(day,-1,DateAdd(Month,+1,Cast(('01/'+ cast(Month(@Givendate) as Nvarchar) + '/' + cast(Year(@Givendate) as Nvarchar)) as dateTime)))
	Set @LastMonthFirstdate = Cast(('01/'+ cast(Month(@Givendate) as Nvarchar)  + '/' + cast(Year(@Givendate) as Nvarchar)) as DateTime)
	Set @GraceTodate = DateAdd(day,@GraceDay-1,@LastMonthFirstdate)

	If dbo.stripdatefromtime(@Givendate) = dbo.stripdatefromtime(@CurrnetMonthEnd)
		Begin
			select 1 Data
			Update Setup set LastInventoryUpload = @Givendate
		End
	Else If dbo.stripdatefromtime(@Givendate) Between dbo.stripdatefromtime(@LastMonthFirstdate) and dbo.stripdatefromtime(@GraceTodate)
		Begin
			select 1 Data
			Update Setup set LastInventoryUpload = @Givendate
		End
	Else If dbo.stripdatefromtime(@Givendate) >= dbo.stripdatefromtime(@LastMonthFirstdate)
		Begin
			select 1 Data
			Update Setup set LastInventoryUpload = @Givendate
		End
	Else
		Begin
			select 0 Data
			Update Setup set LastInventoryUpload = @Givendate
		End
End
