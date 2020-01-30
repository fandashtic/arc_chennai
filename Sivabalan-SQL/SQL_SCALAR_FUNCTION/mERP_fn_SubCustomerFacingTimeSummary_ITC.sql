CREATE Function mERP_fn_SubCustomerFacingTimeSummary_ITC(@SalesmanID Int, @ColumnType Int, 
	@FromDate Datetime, @ToDate Datetime)    
Returns Decimal(18, 6)
As    
Begin    

Declare @CallsCount Table(CallDate Datetime, CustID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
Declare @AvgHrInMrk Table(TimeIn Datetime, TimeOut Datetime, CallDate Datetime)
Declare @AvgTimeInOutlet Table(CallDate Datetime, CustID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, Timespent Int)
Declare @MrkStartTime Table(CallDate Datetime, CustID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, TimeIn Datetime)
Declare @MrkEndTime Table(CallDate Datetime, CustID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, TimeOut Datetime)


Declare @ActualWorkingDays Int
Declare @Timespent Int
Declare @Output Decimal(18, 6)
Declare @TempOutput Decimal(18, 6)
Declare @Hr Int, @Min Int
Declare @TotalVisitCount Decimal(18, 6), @TotalTimeInCount Decimal(18, 6), @TotalTimeOutCount Decimal(18, 6)
Declare @LessThanOne Decimal(18, 6), @OneToFive Decimal(18, 6), @FiveToTen Decimal(18, 6), @GreaterThanTen Decimal(18, 6)
Declare @TimeInBeforeTen Decimal(18, 6), @TimeInTenToEleven Decimal(18, 6), @TimeInAfterEleven Decimal(18, 6)
Declare @TimeOutBeforeTwo Decimal(18, 6), @TimeOutTwoToThree Decimal(18, 6), @TimeOutThreeTofour Decimal(18, 6), @TimeOutAfterfour Decimal(18, 6)

Declare @TimeInBeforeNine Decimal(18, 6), @TimeInNineToTen Decimal(18, 6)

Set @Output = 0
Set @TempOutput = 0
Set @Hr = 0 
Set @Min = 0

If @ColumnType = 0
Begin
	Select @ActualWorkingDays = Count(Distinct CALL_DATE) From DS_TimeSpent dst
										Where dst.SLSMAN_CD = @SalesmanID And
											dst.CALL_DATE Between @FromDate And @ToDate

	Set @Output = @ActualWorkingDays
End

If @ColumnType = 1
Begin
	Insert InTo @CallsCount 
	Select CALL_DATE, CUST_CD From DS_TimeSpent dst
	Where dst.SLSMAN_CD = @SalesmanID And dst.CALL_DATE Between @FromDate And @ToDate
	Group By CALL_DATE, CUST_CD 

	Select @Output = Count(CustID) From @CallsCount
End

If @ColumnType = 2
Begin
	Insert InTo @AvgHrInMrk
	Select Min(TIME_IN), Max(TIME_OUT), CALL_DATE From DS_TimeSpent dst
	Where dst.SLSMAN_CD = @SalesmanID And dst.CALL_DATE Between @FromDate And @ToDate
	Group By CALL_DATE 

	Select @Output = Sum(Datediff(mi, TimeIn, TimeOut)) From @AvgHrInMrk
	
	Select @ActualWorkingDays = Count(Distinct CALL_DATE) From DS_TimeSpent dst
										Where dst.SLSMAN_CD = @SalesmanID And
											dst.CALL_DATE Between @FromDate And @ToDate

	Set @TempOutput = (Cast(@Output As Int) / @ActualWorkingDays) 
	Set @Output = @TempOutput --/ 60.00
--	Set @Min = @TempOutput - (Cast(@Output As Int) * 60)
--	Set @Hr = Cast(@Output As Int)
--	Set @Output = Cast((Cast(@Hr As nVarchar) + '.' + Cast(@Min As nVarchar)) As Decimal(18, 6))
End

If @ColumnType = 3
Begin
	Select @Timespent = Sum(col1) From (
	Select Sum(TIME_SPENT) / 60  col1 From DS_TimeSpent dst
	Where dst.SLSMAN_CD = @SalesmanID And dst.CALL_DATE Between @FromDate And @ToDate
	Group by dst.Call_date) a

	Set @Output = @Timespent --/ 60
	
	Select @ActualWorkingDays = Count(Distinct CALL_DATE) From DS_TimeSpent dst
										Where dst.SLSMAN_CD = @SalesmanID And
											dst.CALL_DATE Between @FromDate And @ToDate

	Set @TempOutput = (Cast(@Output As Int) / @ActualWorkingDays) 
	Set @Output = @TempOutput --/ 60.00
--	Set @Min = @TempOutput - (Cast(@Output As Int) * 60)
--	Set @Hr = Cast(@Output As Int)
--	Set @Output = Cast((Cast(@Hr As nVarchar) + '.' + Cast(@Min As nVarchar)) As Decimal(18, 6))
End

/*-----Averge Time Spent at Outlet--------------------*/
If @ColumnType In (4, 5, 6, 7)
Begin

	Insert InTo @AvgTimeInOutlet
	Select CALL_DATE, CUST_CD, Sum(TIME_SPENT) From DS_TimeSpent dst
	Where dst.SLSMAN_CD = @SalesmanID And dst.CALL_DATE Between @FromDate And @ToDate
	Group By CALL_DATE, CUST_CD 

	Select @TotalVisitCount = Count(CallDate) From @AvgTimeInOutlet

	If @ColumnType = 4
	Begin
		Select @LessThanOne = Count(CallDate) From @AvgTimeInOutlet
		Where (Timespent / 60) < 1

		Set @Output = (@LessThanOne / Case IsNull(@TotalVisitCount, 0) When 0 Then 1 Else @TotalVisitCount End) * 100
	End
	
	If @ColumnType = 5
	Begin
		Select @OneToFive = Count(CallDate) From @AvgTimeInOutlet
		Where (Timespent / 60) >= 1 And (Timespent / 60) < 5

		Set @Output = (@OneToFive / Case IsNull(@TotalVisitCount, 0) When 0 Then 1 Else @TotalVisitCount End) * 100
	End
	
	If @ColumnType = 6
	Begin
		Select @FiveToTen = Count(CallDate) From @AvgTimeInOutlet
		Where (Timespent / 60) >= 5 And (Timespent / 60) < 10

		Set @Output = (@FiveToTen / Case IsNull(@TotalVisitCount, 0) When 0 Then 1 Else @TotalVisitCount End) * 100
	End
	
	If @ColumnType = 7
	Begin
		Select @GreaterThanTen = Count(CallDate) From @AvgTimeInOutlet
		Where (Timespent / 60) >= 10

		Set @Output = (@GreaterThanTen / Case IsNull(@TotalVisitCount, 0) When 0 Then 1 Else @TotalVisitCount End) * 100
	End
End

/*----Market Start Time------------------------------*/
If @ColumnType In (8, 9, 10, 15, 16)
Begin
	Insert InTo @MrkStartTime 
	Select CALL_DATE, '', Min(TIME_IN) From DS_TimeSpent dst
	Where dst.SLSMAN_CD = @SalesmanID And dst.CALL_DATE Between @FromDate And @ToDate
	Group By CALL_DATE

	Select @TotalTimeInCount = Count(CallDate) From @MrkStartTime

	Select @ActualWorkingDays = Count(Distinct CALL_DATE) From DS_TimeSpent dst
										Where dst.SLSMAN_CD = @SalesmanID And
											dst.CALL_DATE Between @FromDate And @ToDate

	
	If @ColumnType = 8
	Begin
		Select @TimeInBeforeTen = Count(TimeIn) From @MrkStartTime
		Where Datepart(hh, TimeIn) < 10 

		Set @Output = (@TimeInBeforeTen / Case IsNull(@ActualWorkingDays, 0) When 0 Then 1 Else @ActualWorkingDays End) * 100
	End
	
	If @ColumnType = 9
	Begin
		Select @TimeInTenToEleven = Count(TimeIn) From @MrkStartTime
		Where Datepart(hh, TimeIn) >= 10 And Datepart(hh, TimeIn) <= 11 And 
		Datepart(mi, TimeIn) < Case Datepart(hh, TimeIn) When 11 Then 1 Else 70 End And
		Datepart(ss, TimeIn) < Case Datepart(hh, TimeIn) When 11 Then 1 Else 70 End


		Set @Output = (@TimeInTenToEleven / Case IsNull(@ActualWorkingDays, 0) When 0 Then 1 Else @ActualWorkingDays End) * 100
	End
	
	If @ColumnType = 10
	Begin
		Select @TimeInAfterEleven = Count(TimeIn) From @MrkStartTime
		Where Datepart(hh, TimeIn) >= 11 And 
		(Datepart(mi, TimeIn) > Case Datepart(hh, TimeIn) When 11 Then 0 Else -1 End or
		Datepart(ss, TimeIn) > Case Datepart(hh, TimeIn) When 11 Then 0 Else -1 End)


		Set @Output = (@TimeInAfterEleven / Case IsNull(@ActualWorkingDays, 0) When 0 Then 1 Else @ActualWorkingDays End) * 100
	End

	If @ColumnType = 15
	Begin
		Select @TimeInBeforeNine = Count(TimeIn) From @MrkStartTime
		Where Datepart(hh, TimeIn) < 9 

		Set @Output = (@TimeInBeforeNine / Case IsNull(@ActualWorkingDays, 0) When 0 Then 1 Else @ActualWorkingDays End) * 100
	End
	
	If @ColumnType = 16
	Begin
		Select @TimeInNineToTen = Count(TimeIn) From @MrkStartTime
		Where Datepart(hh, TimeIn) >= 9 And Datepart(hh, TimeIn) < 10 And 
		Datepart(mi, TimeIn) < Case Datepart(hh, TimeIn) When 10 Then 1 Else 70 End And
		Datepart(ss, TimeIn) < Case Datepart(hh, TimeIn) When 10 Then 1 Else 70 End

		Set @Output = (@TimeInNineToTen / Case IsNull(@ActualWorkingDays, 0) When 0 Then 1 Else @ActualWorkingDays End) * 100
	End

End

/*----Market End Time-------------------------*/
If @ColumnType In (11, 12, 13, 14)
Begin
	Insert InTo @MrkEndTime
	Select CALL_DATE, '', Max(TIME_OUT) From DS_TimeSpent dst
	Where dst.SLSMAN_CD = @SalesmanID And dst.CALL_DATE Between @FromDate And @ToDate
	Group By CALL_DATE

	Select @TotalTimeOutCount = Count(CallDate) From @MrkEndTime

	Select @ActualWorkingDays = Count(Distinct CALL_DATE) From DS_TimeSpent dst
										Where dst.SLSMAN_CD = @SalesmanID And
											dst.CALL_DATE Between @FromDate And @ToDate
	
	If @ColumnType = 11
	Begin
		Select @TimeOutBeforeTwo = Count(TimeOut) From @MrkEndTime
		Where Datepart(hh, TimeOut) < 14

		Set @Output = (@TimeOutBeforeTwo / Case IsNull(@ActualWorkingDays, 0) When 0 Then 1 Else @ActualWorkingDays End) * 100
	End
	
	If @ColumnType = 12
	Begin
		Select @TimeOutTwoToThree = Count(TimeOut) From @MrkEndTime
		Where Datepart(hh, TimeOut) >= 14 And Datepart(hh, TimeOut) < 15

		Set @Output = (@TimeOutTwoToThree / Case IsNull(@ActualWorkingDays, 0) When 0 Then 1 Else @ActualWorkingDays End) * 100
	End
	
	If @ColumnType = 13
	Begin
		Select @TimeOutThreeTofour = Count(TimeOut) From @MrkEndTime
		Where Datepart(hh, TimeOut) >= 15 And Datepart(hh, TimeOut) <= 16 And 
		Datepart(mi, TimeOut) < Case Datepart(hh, TimeOut) When 16 Then 1 Else 70 End And
		Datepart(ss, TimeOut) < Case Datepart(hh, TimeOut) When 16 Then 1 Else 70 End


		Set @Output = (@TimeOutThreeTofour / Case IsNull(@ActualWorkingDays, 0) When 0 Then 1 Else @ActualWorkingDays End) * 100
	End

	If @ColumnType = 14
	Begin
		Select @TimeOutAfterfour = Count(TimeOut) From @MrkEndTime
		Where Datepart(hh, TimeOut) >= 16 And 
		(Datepart(mi, TimeOut) > Case Datepart(hh, TimeOut) When 16 Then 0 Else -1 End or
		Datepart(ss, TimeOut) > Case Datepart(hh, TimeOut) When 16 Then 0 Else -1 End)

		Set @Output = (@TimeOutAfterfour / Case IsNull(@ActualWorkingDays, 0) When 0 Then 1 Else @ActualWorkingDays End) * 100
	End
End

Return @Output

End
