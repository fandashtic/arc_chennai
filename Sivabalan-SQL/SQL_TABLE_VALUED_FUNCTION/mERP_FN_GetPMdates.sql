Create Function mERP_FN_GetPMdates (@Period NVarchar(25))
Returns @PMDates  Table (FromDate DateTime,ToDate Datetime,Days int)
Begin
	Declare @PMMonth as DateTime
	Declare @DayCloseDate as DateTime

	Declare @Month3FromDate as DateTime
	Declare @Month3ToDate as DateTime
	Declare @Month2FromDate as DateTime
	Declare @Month2ToDate as DateTime
	Declare @Month1FromDate as DateTime
	Declare @Month1ToDate as DateTime

	Declare @Month1Days as Int
	Declare @Month2Days as Int
	Declare @Month3Days as Int


	Set  @PMMonth = cast('01-'+ @Period as DateTime)

	Set @DayCloseDate = (select LastInventoryUpload from Setup)

	Set @Month3ToDate = DateAdd(Day,-1,@PMMonth)

	Set @Month3FromDate = cast(('01/' + cast(Month(@Month3ToDate) as Nvarchar) + '/' + cast(Year(@Month3ToDate) as Nvarchar) ) as DateTime)

	If Isnull(@Month2ToDate, '') = ''
		Begin
			Set @Month2ToDate = DateAdd(Day,-1,@Month3FromDate)
			Set @Month2FromDate = cast(('01/' + cast(Month(@Month2ToDate) as Nvarchar) + '/' + cast(Year(@Month2ToDate) as Nvarchar) ) as DateTime)
		End
	Else
		Begin
			Set @Month2FromDate = cast(('01/' + cast(Month(@Month2ToDate) as Nvarchar) + '/' + cast(Year(@Month2ToDate) as Nvarchar) ) as DateTime)
		End

	Set @Month1ToDate = DateAdd(Day,-1,@Month2FromDate)
	Set @Month1FromDate = cast(('01/' + cast(Month(@Month1ToDate) as Nvarchar) + '/' + cast(Year(@Month1ToDate) as Nvarchar) ) as DateTime)

	Set @Month1Days =  DateDiff(Day,@Month1FromDate,@Month1ToDate)+1
	Set @Month2Days =  DateDiff(Day,@Month2FromDate,@Month2ToDate)+1
	Set @Month3Days =  DateDiff(Day,@Month3FromDate,@Month3ToDate)+1

	If Month(@DayCloseDate) = Month(@Month1ToDate) and Year(@DayCloseDate) <= Year(@Month1ToDate)
	Begin
		Set @Month1ToDate = @DayCloseDate
		Set @Month1Days =  DateDiff(Day,@Month1FromDate,@Month1ToDate)+1
		Set @Month2Days =  0
		Set @Month3Days =  0
	End
	Else If Month(@DayCloseDate) = Month(@Month2ToDate) and Year(@DayCloseDate) <= Year(@Month2ToDate)
	Begin
		Set @Month2ToDate = @DayCloseDate
		Set @Month2Days =  DateDiff(Day,@Month2FromDate,@Month2ToDate)+1
		Set @Month3Days =  0
	End
	Else If Month(@DayCloseDate) = Month(@Month3ToDate) and Year(@DayCloseDate) <= Year(@Month3ToDate)
	Begin
		Set @Month3ToDate = @DayCloseDate
		Set @Month3Days =  DateDiff(Day,@Month3FromDate,@Month3ToDate)+1
	End
	Else If @PMMonth > (cast(('01/' + cast(Month(@DayCloseDate) as Nvarchar) + '/' + cast(Year(@DayCloseDate) as Nvarchar) ) as DateTime))
	Begin
		Set @Month1Days =  0
		Set @Month2Days =  0
		Set @Month3Days =  0
	End
	Else 
	Begin
		Set @Month1Days =  DateDiff(Day,@Month1FromDate,@Month1ToDate)+1
		Set @Month2Days =  DateDiff(Day,@Month2FromDate,@Month2ToDate)+1
		Set @Month3Days =  DateDiff(Day,@Month3FromDate,@Month3ToDate)+1
	End

	Insert into @PMDates
	select @Month3FromDate,@Month3ToDate,@Month3Days

	Insert into @PMDates
	select @Month2FromDate,@Month2ToDate,@Month2Days

	Insert into @PMDates
	select @Month1FromDate,@Month1ToDate,@Month1Days

	Delete From @PMDates Where isnull(days,0) = 0
	Return
END
