Create Procedure mERP_sp_CheckGracePeriod
As
Declare	@RepID Int
Declare @Frequency Int
Declare @DayOfMonthWeek Int
Declare @ReportDataID Int
Declare @GracePeriod Int
Declare @LatestDoc Int
Declare @LUDate DateTime
Declare @FirstFromDate  DateTime
Declare @NewToDate DateTime
Declare @GraceDate DateTime
Declare @TempDate DateTime
Declare @Result Int

Set DateFormat DMY

Declare ARUList Cursor For 
Select ReportID, Frequency, IsNull(DayOfMonthWeek,0), ReportDataID, IsNull(GracePeriod,0), IsNull(LatestDoc,0), DateAdd(d,1,LastUploadDate) From Reports_To_Upload
Where IsNull(Frequency,0) > 0 and IsNull(GracePeriod,0) > 0 

Open ARUList
Fetch From ARUList InTo @RepID, @Frequency, @DayOfMonthWeek, @ReportDataID, @GracePeriod, @LatestDoc, @LUDate

While @@Fetch_Status = 0
Begin
	If @Frequency = 1
	Begin
		Set @NewToDate = DateAdd(d,1,@LUDate)
		If @GracePeriod = 1 
		Begin
			If @LatestDoc = 1
				Set @NewToDate = DateAdd(d,-1,GetDate())
			Set @GraceDate = DateAdd(d,@GracePeriod,@NewToDate)
		End
		Else
		Begin
			Set @GraceDate = GetDate() +1
		End
	End
	Else If @Frequency = 2
	Begin
		Set @FirstFromDate = Cast((Cast(@DayOfMonthWeek As nVarChar) + '-' + Cast(Month(@LUDate) As nVarChar)+ '-' + Cast(Year(@LUDate) As nVarChar) ) As DateTime)
		If @DayOfMonthWeek > Day(@LUDate)
			Set @FirstFromDate = DateAdd(m,-1,@FirstFromDate)
		Set @NewToDate = DateAdd(d,-1,DateAdd(m,1,@FirstFromDate))
		If @GracePeriod < = 28
		Begin
			If @LatestDoc = 1
			Begin
				Set @TempDate = @NewToDate
				While @TempDate <= GetDate()
				Begin
					Set @NewToDate = @TempDate
					Set @TempDate = DateAdd(d,-1,DateAdd(m,1,DateAdd(d,1,@TempDate)))
				End
			End
			Set @GraceDate = DateAdd(d,@GracePeriod,@NewToDate)
		End
		Else
		Begin
			Set @GraceDate = GetDate() +1
		End
	End
	Else If @Frequency = 3
	Begin		
		Set @FirstFromDate = DateAdd(d,(@DayOfMonthWeek-DatePart(dw,@LUDate)),@LUDate)
		If @DayOfMonthWeek > DatePart(dw,@LUDate)
			Set @FirstFromDate = DateAdd(d,-7,@FirstFromDate)
		Set @NewToDate = DateAdd(d,-1,DateAdd(d,7,@FirstFromDate))
		If @GracePeriod < 7
		Begin
			If @LatestDoc = 1
			Begin
				Set @TempDate = @NewToDate
				While @TempDate <= GetDate()
				Begin
					Set @NewToDate = @TempDate
					Set @TempDate = DateAdd(d,7,@TempDate)
				End     
			End
			Set @GraceDate = DateAdd(d,@GracePeriod,@NewToDate)
		End
		Else
		Begin
			Set @GraceDate = GetDate() +1
		End
	End
	Else If @Frequency = 4 Or @Frequency = 5
	Begin
		If Day(@LUDate) < 7
			Set @FirstFromDate = Cast(('1-' + Cast(Month(@LUDate) As nVarChar) + '-' + Cast(Year(@LUDate) As nVarChar)) As DateTime)
		Else If Day(@LUDate) >= 7  And Day(@LUDate) < 14
			Set @FirstFromDate = Cast(('8-' + Cast(Month(@LUDate) As nVarChar) + '-' + Cast(Year(@LUDate) As nVarChar)) As DateTime)
		Else If Day(@LUDate) >= 14 And Day(@LUDate) < 21
			Set @FirstFromDate = Cast(('15-' + Cast(Month(@LUDate) As nVarChar) + '-' + Cast(Year(@LUDate) As nVarChar)) As DateTime)
		Else IF Day(@LUDate) >= 21
			Set @FirstFromDate = Cast(('22-' + Cast(Month(@LUDate) As nVarChar) + '-' + Cast(Year(@LUDate) As nVarChar)) As DateTime)

		If Day(@FirstFromDate) = 1 Or Day(@FirstFromDate) = 8 Or Day(@FirstFromDate) = 15
			Set @NewToDate = DateAdd(d,6,@FirstFromDate)
		Else If Day(@FirstFromDate) = 22
			Set @NewToDate = dbo.Get_Last_DayoftheMonth(@FirstFromDate)

		If @GracePeriod < 7
		Begin
			If @LatestDoc = 1
			Begin
				Set @TempDate = @NewToDate
				While @TempDate <= GetDate()
				Begin
					Set @NewToDate = @TempDate
					If Day(DateAdd(d,1,@TempDate)) = 1 Or Day(@TempDate) = 7 Or Day(@TempDate) = 14
						Set @TempDate = DateAdd(d,7,@TempDate)
					Else If Day(@TempDate) = 21
						Set @TempDate = dbo.Get_Last_DayoftheMonth(@TempDate)
				End     
			End
			Set @GraceDate = DateAdd(d,@GracePeriod,@NewToDate)
		End
		Else
		Begin
			Set @GraceDate = GetDate() +1
		End
	End
	If @GraceDate <= GetDate()
	Begin
		Set @Result = 1
		GoTo SelectResult
	End
	-- The following Select Statement is used to Back End Checking or debugging
	-- Select  @RepID, @Frequency, @DayOfMonthWeek, @ReportDataID, @GracePeriod, @LatestDoc, @LUDate ,@FirstFromDate, @NewToDate, @GraceDate,@Result
	Fetch Next From ARUList InTo @RepID, @Frequency, @DayOfMonthWeek, @ReportDataID, @GracePeriod, @LatestDoc, @LUDate
End

Set @Result = 0

SelectResult:

Close ARUList 
DeAllocate ARUList

Select "Result" = @Result

