Create Procedure mERP_spr_CustomerFacingTimeSummaryRpt_ITC_Upload(
	@Salesman nVarchar(2550),
	@Frequency nVarchar(10),
	@FromDate Datetime,
	@ToDate Datetime,
	@Month nVarchar(10),
	@FromWeek Int,
	@ToWeek Int
)
As
Begin
Declare @Delimeter As Char(1)
Declare @WDCode NVarchar(255)  
Declare @WDDest NVarchar(255)  
Declare @CompaniesToUploadCode NVarchar(255)  
Declare @Saleman Table (Salesman nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SalesmanID Int)    
Declare @CMonth nVarchar(10)
Declare @CFromDate nVarchar(10), @CToDate nVarchar(10)
Declare @VFromDate Datetime, @VToDate Datetime
Declare @i Int
Declare @PlannedWorkingDays Int
Declare @DtMonth DateTime 
Declare @DaysDiff Int
--Set @Month = '01/' + @Month
--Declare @ToDate Datetime
--Set @ToDate = Getdate()
----- For Upload only
If (DatePart(dd,@FromDate) = 1 and Datepart(dd,@Todate) = 7) or (DatePart(dd,@FromDate) = 8 and Datepart(dd,@Todate) = 14) or (DatePart(dd,@FromDate) = 15 and Datepart(dd,@Todate) = 21) or (DatePart(dd,@FromDate) = 22 and (Datepart(dd,@Todate) = 30 or Datepart(dd,@Todate) = 31 or Datepart(dd,@Todate) = 28 or Datepart(dd,@Todate) = 29 ))
Begin

Set @Month = '01/' + Case When Len(Cast(datepart(mm,@FromDate) as Nvarchar)) = 1 then '0'+ Cast(datepart(mm,@FromDate) as Nvarchar) Else Cast(datepart(mm,@FromDate) as Nvarchar) End + '/' + Cast(datepart(yyyy,@FromDate) as NVarchar)
Set @DtMonth = Cast(Substring(@Month,1,2) +'/'+ (Substring(@Month,4,2)+'/'+ Substring(@Month,7,4))as DateTime)
Set @ToWeek = Case When Datepart(d,@ToDate) = 7 then 1
				When Datepart(d,@ToDate) = 14 then 2
				When Datepart(d,@ToDate) = 21 then 3
				Else 4
				End
End
Else
Begin
	If (CharIndex('/',@Month)) = 2  /* To format Mth as MM/YYYY*/
	Begin
	 Set @Month = N'0'+@Month
	End
	Set @DtMonth = Cast(Cast(DATEPART(dd, 0) as nVarchar(2)) +'/'+ (Substring(@Month,1,2)+'/'+ Substring(@Month,4,4))as DateTime)
	Set @Month = '01/' + @Month
End

----- For Upload only
Set @Delimeter = Char(15)

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload    
Select Top 1 @WDCode = RegisteredOwner From Setup      
    
If @CompaniesToUploadCode= N'ITC001'    
 Set @WDDest= @WDCode    
Else    
Begin    
 Set @WDDest = @WDCode    
 Set @WDCode = @CompaniesToUploadCode    
End

If @Salesman = N'%'     
   Insert InTo @Saleman Select Distinct Salesman_Name, SalesmanID From Salesman
Else    
   Insert InTo @Saleman Select Distinct Salesman_Name, SalesmanID From Salesman 
   Where Salesman_Name In (Select * from dbo.sp_SplitIn2Rows(@Salesman, @Delimeter))

Set @CFromDate = Convert(nVarchar(10), @FromDate, 103) 
Set @CToDate = Convert(nVarchar(10), @ToDate, 103) 
--Set @CMonth = Cast(Datepart(yyyy, Cast(@Month as DateTime)) As nVarchar) + Cast(Datepart(MM, Cast(@Month as DateTime)) As nVarchar) 
Set @CMonth = Cast(Datepart(yyyy, Cast(@DtMonth as DateTime)) As nVarchar) + Substring(@Month,4,2)
Set @i = 0


If @Frequency = N'Weekly'
Begin
	--Set @Toweek = Case When @ToWeek > 4 Then 4 Else @toweek End
	Set @i = Case When @FromWeek > @ToWeek Then 0
				  When (@FromWeek > 4) Or (@FromWeek < 1) Then 0
				  When (@ToWeek > 4) Or (@ToWeek < 1) Then 0
			 Else 1 End
	If @i = 1
	Begin
		Set @VToDate = Cast((N'1/' + Cast(Datepart(MM, Cast(@DtMonth as DateTime)) As nVarchar) + N'/' + Cast(Datepart(yyyy, Cast(@DtMonth as DateTime)) As nVarchar)) As Datetime)
		Set @VToDate = Dateadd(ss, -1, Dateadd(MM, 1, @VToDate))

		Set @VFromDate = Cast((Cast((Case @FromWeek When 1 Then 1 
													When 2 Then 8
													When 3 Then 15
													When 4 Then 22 End) As nVarchar) + N'/' + 
			Cast(Datepart(MM, Cast(@DtMonth as DateTime)) As nVarchar) + N'/' + Cast(Datepart(yyyy, Cast(@DtMonth as DateTime)) As nVarchar)) As Datetime)

		Set @VToDate = Cast((Cast((Case @ToWeek When 1 Then 7 
													When 2 Then 14
													When 3 Then 21
													When 4 Then Datepart(dd, @VToDate) End) As nVarchar) + N'/' + 
			Cast(Datepart(MM, Cast(@DtMonth as DateTime)) As nVarchar) + N'/' + Cast(Datepart(yyyy, Cast(@DtMonth as DateTime)) As nVarchar)) As Datetime)

	    Set @VToDate = Dateadd(ss, -1, Dateadd(dd, 1, @VToDate))

		Set @PlannedWorkingDays = Datediff(dd, @VFromDate, @VToDate) + 1
		
--		Set @PlannedWorkingDays = @PlannedWorkingDays - ((Case When DATENAME(dw, @VFromDate) = N'Sunday' Then 1 Else 0 End) 
--			+ (Case When DATENAME(dw, @VToDate) = N'Sunday' Then 1 Else 0 End))
--
--		Set @PlannedWorkingDays = @PlannedWorkingDays - (@PlannedWorkingDays / 7)

        Set @DaysDiff = DateDiff(dd,DateAdd(day, (8-DatePart(weekday, DateAdd(Day, DateDiff(Day, 0, @VFromDate), 0)))%7, DateAdd(Day, DateDiff(day, 0, @VFromDate), 0)),@VToDate)
        Set @PlannedWorkingDays = @PlannedWorkingDays - ((@DaysDiff/7) + 1 )


		Select @WDCode, "WDCode" = @WDCode, "WDDest" = @WDDest, "Month" = @CMonth, "From Week" = @FromWeek, 
			"To Week" = @ToWeek, "FromDate" = @VFromDate , "ToDate" = @VToDate , "Salesman_Code" = sm.SalesmanID, 
			"Salesman_Name" = sm.Salesman, 
			"DS Type" = (Select Top 1 DSTypeValue From DSType_Master Where DsTypeID     
				 In ( Select DSTypeID From DSType_Details Where SalesmanID = sm.SalesmanID)    
				 And Active = 1 And DSTypeCtlPos = 1),
			"Planned Working Days" = @PlannedWorkingDays ,
			"Actual Working Days" = Cast(IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 0, @VFromDate, @VToDate), 0) As Int), 

			"Total calls made in the Period" = Cast(IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 1, @VFromDate, @VToDate), 0) As Int), 

			"Average Calls/Day" = Cast((IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 1, @VFromDate, @VToDate), 0) / 
								   Case IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 0, @VFromDate, @VToDate), 0) When 0 Then 1 Else
								   IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 0, @VFromDate, @VToDate), 0) End) As Decimal(18, 6)),					

			"Average No. of Hours in Mkt/Day (HH:MM)" = --Replace(Cast(Cast(IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 2, @VFromDate, @VToDate), 0) As Decimal(18, 2)) As nVarchar) , '.', ':'),  
											Convert(Char(5), DateAdd(n,IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 2, @VFromDate, @VToDate), 0),0), 108),

			"Average Transaction time (HH:MM)" = --Replace(Cast(Cast(IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 3, @VFromDate, @VToDate), 0) As Decimal(18, 2)) As nVarchar), '.', ':'),
											Convert(Char(5), DateAdd(n, IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 3, @VFromDate, @VToDate), 0), 0), 108),						

			"Average Time Spent at Outlet (%) Less Than 1 Min" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 4, @VFromDate, @VToDate), 
			"Average Time Spent at Outlet (%) 1 - 5 Min" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 5, @VFromDate, @VToDate), 
			"Average Time Spent at Outlet (%) 5 - 10 Min" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 6, @VFromDate, @VToDate), 
			"Average Time Spent at Outlet (%) Greater Than 10 Min" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 7, @VFromDate, @VToDate),
			--"Market Start Time (%) Before 10 AM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 8, @VFromDate, @VToDate), 
			"Market Start Time (%) Before 9 AM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 15, @VFromDate, @VToDate), 
			"Market Start Time (%) 9 AM - 10 AM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 16, @VFromDate, @VToDate),
			"Market Start Time (%) 10 AM - 11 AM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 9, @VFromDate, @VToDate), 
			"Market Start Time (%) After 11 AM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 10, @VFromDate, @VToDate), 
			"Market End Time (%) Before 2 PM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 11, @VFromDate, @VToDate), 
			"Market End Time (%) 2 PM - 3 PM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 12, @VFromDate, @VToDate), 
			"Market End Time (%) 3 PM - 4 PM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 13, @VFromDate, @VToDate), 
			"Market End Time (%) After 4 PM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 14, @VFromDate, @VToDate),
            "DeviceID" = (  Select top 1 isnull(Dst.DeviceId,'') from DS_TimeSpent Dst where isnull(Dst.DeviceId,'') <> '' And Dst.SLSMAN_CD = sm.SalesmanID order by Dst.CALL_DATE desc, Dst.time_out desc ) 
		From @Saleman sm 
		Where sm.SalesmanID In (Select SLSMAN_CD From DS_TimeSpent 
								Where CALL_DATE Between @VFromDate And @VToDate)
	End
	Else
	Begin
		Select * InTo #tmpEnpty From (
		Select "WD" = @WDCode, "WDCode" = '', "WDDest" = '', "Month" = '', "From Week" = '', "To Week" = '', 
			"FromDate" = '', "ToDate" = '', "Salesman_Code" = '', "Salesman_Name" = '', 
			"DS Type" = '', 
			"Planned Working Days" = '', "Actual Working Days" = '', "Total calls made in the Period" = '', 
		    "Average Calls/Day" = '', "Average No. of Hours in Mkt/Day (HH:MM)" = '', 
			"Average Transaction time (HH:MM)" = '', 
			"Average Time Spent at Outlet (%) Less Than 1 Min" = '', 
			"Average Time Spent at Outlet (%) 1 - 5 Min" = '', 
			"Average Time Spent at Outlet (%) 5 - 10 Min" = '', 
			"Average Time Spent at Outlet (%) Greater Than 10 Min" = '',
			--"Market Start Time (%) Before 10 AM" = '', 
			"Market Start Time (%) Before 9 AM" = '', 
			"Market Start Time (%) 9 AM - 10 AM" = '',
			"Market Start Time (%) 10 AM - 11 AM" = '', 
			"Market Start Time (%) After 11 AM" = '', 
			"Market Start Time (%) Before 2 PM" = '', 
			"Market Start Time (%) 2 PM - 3 PM" = '', 
			"Market Start Time (%) 3 PM - 4 PM" = '', 
			"Market Start Time (%) After 4 PM" = '', 
			"DeviceID" = '') As als 
		Truncate Table #tmpEnpty
		Select * From #tmpEnpty 
		Drop Table #tmpEnpty 
	End
End
Else
Begin

	Set @PlannedWorkingDays = Datediff(dd, @FromDate, @ToDate) + 1
	
	Set @PlannedWorkingDays = @PlannedWorkingDays - ((Case When DATENAME(dw, @FromDate) = N'Sunday' Then 1 Else 0 End) 
		+ (Case When DATENAME(dw, @ToDate) = N'Sunday' Then 1 Else 0 End))

	Set @PlannedWorkingDays = @PlannedWorkingDays - (@PlannedWorkingDays / 7)

	Select @WDCode, "WDCode" = @WDCode, "WDDest" = @WDDest, "Month" = '', "From Week" = '', 
		"To Week" = '', "FromDate" = @CFromDate, "ToDate" = @CToDate, "Salesman_Code" = sm.SalesmanID, 
		"Salesman_Name" = sm.Salesman, 
		"DS Type" = (Select Top 1 DSTypeValue From DSType_Master Where DsTypeID     
				 In ( Select DSTypeID From DSType_Details Where SalesmanID = sm.SalesmanID)    
				 And Active = 1 And DSTypeCtlPos = 1),
		"Planned Working Days" = @PlannedWorkingDays ,
		"Actual Working Days" = Cast(IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 0,  @FromDate, @ToDate), 0) As Int), 

		"Total calls made in the Period" = Cast(IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 1,  @FromDate, @ToDate), 0) As Int), 

		"Average Calls/Day" = Cast((IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 1,  @FromDate, @ToDate), 0) / 
							   Case IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 0,  @FromDate, @ToDate), 0) When 0 Then 1 Else
							   IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 0,  @FromDate, @ToDate), 0) End) As Decimal(18, 6)),					

		"Average No. of Hours in Mkt/Day (HH:MM)" = --Replace(Cast(Cast(IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 2,  @FromDate, @ToDate), 0) As Decimal(18, 2)) As nVarchar) , '.', ':'),  
										Convert(Char(5), DateAdd(n,IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 2, @FromDate, @ToDate), 0),0), 108),

		"Average Transaction time (HH:MM)" = --Replace(Cast(Cast(IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 3,  @FromDate, @ToDate), 0) As Decimal(18, 2)) As nVarchar), '.', ':'),
										Convert(Char(5), DateAdd(n, IsNull(dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 3, @FromDate, @ToDate), 0), 0), 108),

		"Average Time Spent at Outlet (%) Less Than 1 Min" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 4, @FromDate, @ToDate), 
		"Average Time Spent at Outlet (%) 1 - 5 Min" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 5, @FromDate, @ToDate), 
		"Average Time Spent at Outlet (%) 5 - 10 Min" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 6, @FromDate, @ToDate), 
		"Average Time Spent at Outlet (%) Greater Than 10 Min" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 7, @FromDate, @ToDate),
		--"Market Start Time (%) Before 10 AM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 8, @FromDate, @ToDate), 
		"Market Start Time (%) Before 9 AM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 15, @FromDate, @ToDate), 
		"Market Start Time (%) 9 AM - 10 AM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 16, @FromDate, @ToDate),
		"Market Start Time (%) 10 AM - 11 AM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 9, @FromDate, @ToDate), 
		"Market Start Time (%) After 11 AM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 10, @FromDate, @ToDate), 
		"Market End Time (%) Before 2 PM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 11, @FromDate, @ToDate), 
		"Market End Time (%) 2 PM - 3 PM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 12, @FromDate, @ToDate), 
		"Market End Time (%) 3 PM - 4 PM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 13, @FromDate, @ToDate), 
		"Market End Time (%) After 4 PM" = dbo.mERP_fn_SubCustomerFacingTimeSummary_ITC(sm.SalesmanID, 14, @FromDate, @ToDate),
        "DeviceID" = (  Select top 1 isnull(Dst.DeviceId,'') from DS_TimeSpent Dst where isnull(Dst.DeviceID,'') <> '' and Dst.SLSMAN_CD = sm.SalesmanID order by Dst.CALL_DATE desc, Dst.time_out desc ) 
	From @Saleman sm 
	Where sm.SalesmanID In (Select SLSMAN_CD From DS_TimeSpent 
							Where CALL_DATE Between @FromDate And @ToDate)
End

End
