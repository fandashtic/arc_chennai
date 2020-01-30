Create Procedure dbo.Sp_SKUOPT_AlertCheck (@SystemDate dateTime,@Pending Int = 0, @MsgAlrt Int = 0, @Dayclose Int = 0)
As  
Begin
	Set DateFormat DMY
	Declare @LastMonthFirstdate as dateTime
	Declare @LastMonthEndDayclosedate as dateTime
	Declare @GraceDay as Int
	Declare @SKUPortfolio as Int
	Declare @WDSKUList as Int
	Declare @HMSKU as Int
	Declare @PendingAlert as Int
	Declare @GraceDayFlag as Int
	Declare @LastDaycloseDate as dateTime
	Declare @SKUId as Int
	Declare @WDID as Int
	Declare @HMSKUId as Int	
	Declare @SKUPortfolioAlertFromday as dateTime
	Declare @WDSKUListAlertFromday as dateTime
	Declare @SKUPortfolioAlertToday as dateTime
	Declare @WDSKUListAlertToday as dateTime
	Declare @HMSKUAlertFromday as dateTime
	Declare @HMSKUAlertToday as dateTime
	Declare @CurrentMonthStart as dateTime
	Declare @CurrentMonthEnd as dateTime
	Declare @PreviousMonthFirstDate as dateTime
	Declare @PreviousMonthEndDate as dateTime
	Declare @MonthEndFlag as Int
	Set @SystemDate = dbo.stripdatefromtime(@SystemDate)

	Set @LastMonthFirstdate = Cast(('01/'+ cast(Month(@SystemDate) as Nvarchar)  + '/' + cast(Year(@SystemDate) as Nvarchar)) as DateTime)
	Set @LastMonthEndDayclosedate = DateAdd(day,-1,@LastMonthFirstdate)
	Set @GraceDay = (Select Top 1 [Value] from tbl_merp_configdetail where screencode='SKUOPT')
	Set @CurrentMonthStart = Cast(('01/'+ cast(Month(@SystemDate) as Nvarchar)  + '/' + cast(Year(@SystemDate) as Nvarchar)) as DateTime)
	Set @CurrentMonthEnd = DateAdd(Day,-1,(dateAdd(Month,+1,@CurrentMonthStart)))
	Set @PreviousMonthFirstDate = Cast(('01/' + Cast(Month(@LastMonthEndDayclosedate) as Nvarchar) + '/' + cast(Year(@LastMonthEndDayclosedate) as Nvarchar)) as DateTime)
	Set @PreviousMonthEndDate = DateAdd(Day,-1,@PreviousMonthFirstDate)

	Select @LastDaycloseDate = LastInventoryUpload From setup

	If @LastDaycloseDate >= @LastMonthEndDayclosedate
		Begin
			Select Top 1 @SKUPortfolio = ID From SKUPortfolio Where Active = 1 And dbo.stripdatefromtime(EFFECTIVEFROMDATE) < @LastMonthFirstdate Order by Id Desc
			Select Top 1 @WDSKUList = ID From WDSKUList Where Active = 1 And dbo.stripdatefromtime(EFFECTIVEFROMDATE) < @LastMonthFirstdate Order by Id Desc
			Select Top 1 @HMSKU = ID From HMSKU Where Active = 1 And dbo.stripdatefromtime(EFFECTIVEFROMDATE) < @LastMonthFirstdate Order by Id Desc
		End
	Else If @LastDaycloseDate >= @PreviousMonthEndDate
		Begin
			Select Top 1 @SKUPortfolio = ID From SKUPortfolio Where Active = 1 And dbo.stripdatefromtime(EFFECTIVEFROMDATE) <= @PreviousMonthEndDate Order by Id Desc
			Select Top 1 @WDSKUList = ID From WDSKUList Where Active = 1 And dbo.stripdatefromtime(EFFECTIVEFROMDATE) <= @PreviousMonthEndDate Order by Id Desc
			Select Top 1 @HMSKU = ID From HMSKU Where Active = 1 And dbo.stripdatefromtime(EFFECTIVEFROMDATE) <= @PreviousMonthEndDate Order by Id Desc
		End

	Set @SKUPortfolio = Isnull(@SKUPortfolio,0)
	Set @WDSKUList = Isnull(@WDSKUList,0)
	Set @HMSKU = Isnull(@HMSKU,0)
	If @WDSKUList = 0
		Begin
			Goto OUT
		End
-- Data Posting Pending ALert :
--	If @SKUPortfolio > 0 and @WDSKUList > 0 and @LastDaycloseDate >= @LastMonthEndDayclosedate
	If @WDSKUList > 0 and @LastDaycloseDate >= @LastMonthEndDayclosedate
		Begin
			If Not Exists (Select Top 1 * From tbl_SKUOpt_Monthly Where @LastMonthEndDayclosedate in (Todate))
				Begin
					Set @PendingAlert = 1
				End
			Else If Not Exists (Select Top 1 * From tbl_SKUOpt_Monthly Where SKUPortfolioID = @SKUPortfolio and WDSKUListID = @WDSKUList and HMSKUID = @HMSKU and Status = 1)
				Begin
					Set @PendingAlert = 1
				End
			Else
				Begin
					Set @PendingAlert = 0
				End
		End
--	Else If @SKUPortfolio > 0 and @WDSKUList > 0 and @LastDaycloseDate >= @PreviousMonthEndDate
	Else If @WDSKUList > 0 and @LastDaycloseDate >= @PreviousMonthEndDate
		Begin
			If Not Exists (Select Top 1 * From tbl_SKUOpt_Monthly Where @PreviousMonthEndDate in (Todate))
				Begin
					Set @PendingAlert = 1
				End
			Else If Not Exists (Select Top 1 * From tbl_SKUOpt_Monthly Where SKUPortfolioID = @SKUPortfolio and WDSKUListID = @WDSKUList and HMSKUID = @HMSKU and Status = 1)
				Begin
					Set @PendingAlert = 1
				End
			Else
				Begin
					Set @PendingAlert = 0
				End
		End
	Else If @HMSKU > 0 and @LastDaycloseDate >= @LastMonthEndDayclosedate
		Begin
			If Not Exists (Select Top 1 * From tbl_SKUOpt_Monthly Where @LastMonthEndDayclosedate in (Todate))
				Begin
					Set @PendingAlert = 1
				End
			Else If Not Exists (Select Top 1 * From tbl_SKUOpt_Monthly Where SKUPortfolioID = @SKUPortfolio and WDSKUListID = @WDSKUList and HMSKUID = @HMSKU and Status = 1)
				Begin
					Set @PendingAlert = 1
				End
			Else
				Begin
					Set @PendingAlert = 0
				End
		End
	Else If @HMSKU > 0 and @LastDaycloseDate >= @PreviousMonthEndDate
		Begin
			If Not Exists (Select Top 1 * From tbl_SKUOpt_Monthly Where @PreviousMonthEndDate in (Todate))
				Begin
					Set @PendingAlert = 1
				End
			Else If Not Exists (Select Top 1 * From tbl_SKUOpt_Monthly Where SKUPortfolioID = @SKUPortfolio and WDSKUListID = @WDSKUList and HMSKUID = @HMSKU and Status = 1)
				Begin
					Set @PendingAlert = 1
				End
			Else
				Begin
					Set @PendingAlert = 0
				End
		End
	Else
		Begin
			Set @PendingAlert = 0
		End
--Grace Day Alert:
	select Top 1 @SKUPortfolioAlertFromday = (dbo.stripdatefromtime(CreationDate)), @SKUId = ID From SKUPortfolio Where Active = 1 and AlertStatus = 1 And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
	select Top 1 @WDSKUListAlertFromday = (dbo.stripdatefromtime(CreationDate)), @WDID = ID From WDSKUList Where Active = 1 and AlertStatus = 1 And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
	select Top 1 @HMSKUAlertFromday = (dbo.stripdatefromtime(CreationDate)), @HMSKUId = ID From HMSKU Where Active = 1 and AlertStatus = 1 And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
	Set @SKUPortfolioAlertToday = DateAdd(day, @GraceDay,(select Top 1 dbo.stripdatefromtime(CreationDate) From SKUPortfolio Where Active = 1 and AlertStatus = 1 And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc ))
	Set @WDSKUListAlertToday = DateAdd(day, @GraceDay,(select Top 1 dbo.stripdatefromtime(CreationDate) From WDSKUList Where Active = 1 and AlertStatus = 1 And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc ))
	Set @HMSKUAlertToday = DateAdd(day, @GraceDay,(select Top 1 dbo.stripdatefromtime(CreationDate) From HMSKU Where Active = 1 and AlertStatus = 1 And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc ))

	Set @SKUId = Isnull(@SKUId,0)
	Set @WDID = Isnull(@WDID,0)
	Set @HMSKUId = Isnull(@HMSKUId,0)
-- X <= ReceiveGracedate And X > ReceiveGracedate
	If @Dayclose = 1
		Begin
			Goto MonthEndchecking
		End
	If @SKUId > 0
		Begin 		
			If @SystemDate Between dbo.stripdatefromtime(@SKUPortfolioAlertFromday) and dbo.stripdatefromtime(DateAdd(Day,-1,@SKUPortfolioAlertToday)) and @LastDaycloseDate >= @LastMonthEndDayclosedate
				Begin
					Set @GraceDayFlag = 1
					Update SKUPortfolio Set AlertStatus  = 1 Where Id = @SKUId
					Goto OUT
				End
			Else If @SystemDate > dbo.stripdatefromtime(DateAdd(Day,-1,@SKUPortfolioAlertToday)) and @LastDaycloseDate >= @LastMonthEndDayclosedate
				Begin
					Set @GraceDayFlag = 0
					Update SKUPortfolio Set AlertStatus  = 0 Where Id = @SKUId
					/* FITC-4044 - As alert message did not shown in the below mentioned scenario, we changed the below checking*/
					/* Receive SKUopt on 16/11/2012 --> do dataposting. --> Change the system date to 02/12/2012 and do close day till 
					30/11/2012. Alert message did not shown*/
					Set @MonthEndFlag = 1
					Goto OUT
		--			Goto MonthEndchecking
				End
			Else If @SystemDate Between dbo.stripdatefromtime(@SKUPortfolioAlertFromday) And dbo.stripdatefromtime(DateAdd(Day,-1,@SKUPortfolioAlertToday))  and @LastDaycloseDate >= @PreviousMonthEndDate
				Begin
					Set @GraceDayFlag = 1
					Update SKUPortfolio Set AlertStatus  = 1 Where Id = @SKUId
					Goto Out
				End
			Else If @SystemDate > dbo.stripdatefromtime(DateAdd(Day,-1,@SKUPortfolioAlertToday)) and @LastDaycloseDate >= @PreviousMonthEndDate
				Begin
					Set @GraceDayFlag = 0
--					Set @MonthEndFlag = 1
					Goto Out
				End
			Else If @SystemDate < dbo.stripdatefromtime(@SKUPortfolioAlertFromday)
				Begin
					Set @GraceDayFlag = 2
				End
		End
	If @HMSKUId > 0
		Begin 		
			If @SystemDate Between dbo.stripdatefromtime(@HMSKUAlertFromday) And dbo.stripdatefromtime(DateAdd(Day,-1,@HMSKUAlertToday))  and @LastDaycloseDate >= @LastMonthEndDayclosedate
				Begin
					Set @GraceDayFlag = 1
					Goto OUT
				End
			Else If @SystemDate > dbo.stripdatefromtime(DateAdd(Day,-1,@HMSKUAlertToday)) and @LastDaycloseDate >= @LastMonthEndDayclosedate
				Begin
					Set @GraceDayFlag = 0
					Set @MonthEndFlag = 1
					Goto OUT
				End
			Else If @SystemDate Between dbo.stripdatefromtime(@HMSKUAlertFromday) And dbo.stripdatefromtime(DateAdd(Day,-1,@HMSKUAlertToday))  and @LastDaycloseDate >= @PreviousMonthEndDate
				Begin
					Set @GraceDayFlag = 1
					Goto OUT
				End
			Else If @SystemDate > dbo.stripdatefromtime(DateAdd(Day,-1,@HMSKUAlertToday)) and @LastDaycloseDate >= @PreviousMonthEndDate
				Begin
					Set @GraceDayFlag = 0
--					Set @MonthEndFlag = 1
					Goto OUT					
				End
			Else If @SystemDate < dbo.stripdatefromtime(@HMSKUAlertFromday)
				Begin
					Set @GraceDayFlag = 2					
				End
		End

	If @SystemDate Between dbo.stripdatefromtime(@WDSKUListAlertFromday) And dbo.stripdatefromtime(DateAdd(Day,-1,@WDSKUListAlertToday))  and @LastDaycloseDate >= @LastMonthEndDayclosedate
		Begin
			Set @GraceDayFlag = 1
			Goto Out
		End
	Else If @SystemDate > dbo.stripdatefromtime(DateAdd(Day,-1,@WDSKUListAlertToday)) and @LastDaycloseDate >= @LastMonthEndDayclosedate
		Begin
			Set @GraceDayFlag = 0
			Set @MonthEndFlag = 1
			/* FITC-4044 - As alert message did not shown in the below mentioned scenario, we changed the below checking*/
			/* Receive SKUopt on 16/11/2012 --> do dataposting. --> Change the system date to 02/12/2012 and do close day till 
			30/11/2012. Alert message did not shown*/
			Goto Out
--			Goto MonthEndchecking
		End
	Else If @SystemDate Between dbo.stripdatefromtime(@WDSKUListAlertFromday) And dbo.stripdatefromtime(DateAdd(Day,-1,@WDSKUListAlertToday))  and @LastDaycloseDate >= @PreviousMonthEndDate
		Begin
			Set @GraceDayFlag = 1
			Goto Out
		End
	Else If @SystemDate > dbo.stripdatefromtime(DateAdd(Day,-1,@WDSKUListAlertToday)) and @LastDaycloseDate >= @PreviousMonthEndDate
		Begin
			Set @GraceDayFlag = 0
--			Set @MonthEndFlag = 1
			Goto Out
		End
	Else If @SystemDate < dbo.stripdatefromtime(@WDSKUListAlertFromday)
		Begin
			Set @GraceDayFlag = 2
		End
Goto OUT
MonthEndchecking:
-- X <= GraceTodate And X > MonthEndDate
			If @SystemDate >= dbo.stripdatefromtime(@LastMonthEndDayclosedate) and @LastDaycloseDate >= @LastMonthEndDayclosedate
				Begin
					If @SystemDate BEtween dbo.stripdatefromtime(@LastMonthEndDayclosedate) and  DateAdd(Day,(@GraceDay),dbo.stripdatefromtime(@LastMonthEndDayclosedate))
						Begin
							Set @GraceDayFlag = 1
							Goto OUT
						End
					Else If @SystemDate = dbo.stripdatefromtime(@CurrentMonthEnd)
						Begin
							Set @GraceDayFlag = 1
							Goto OUT
						End
					Else If @SystemDate > DateAdd(Day,(@GraceDay),dbo.stripdatefromtime(@LastMonthEndDayclosedate))
						Begin
							Set @GraceDayFlag = 0
							set @MonthEndFlag=0
						End
					Else
						Begin
							Set @GraceDayFlag = 2
						End
				End
			Else If @SystemDate >= dbo.stripdatefromtime(@PreviousMonthEndDate) and @LastDaycloseDate >= @PreviousMonthEndDate
				Begin
					If @SystemDate BEtween dbo.stripdatefromtime(@PreviousMonthEndDate) and  DateAdd(Day,(@GraceDay),dbo.stripdatefromtime(@PreviousMonthEndDate))
						Begin
							Set @GraceDayFlag = 1
						End
					Else If @SystemDate > DateAdd(Day,(@GraceDay),dbo.stripdatefromtime(@PreviousMonthEndDate))
						Begin
							Set @GraceDayFlag = 1
						End
					Else
						Begin
							Set @GraceDayFlag = 2
						End
				End
			Else
				Begin
					Set @GraceDayFlag = 2
				End
-- For OutPut:
Out:
	If Isnull(@MonthEndFlag,0) = 1 and Isnull(@GraceDayFlag,0) = 0
		Begin
			Goto MonthEndchecking
		End
	If @Pending > 0
		Begin
			select Isnull(@PendingAlert,0) PendingAlert
		End

	If @MsgAlrt > 0
		Begin
			select Isnull(@GraceDayFlag,0) GraceDayAlert
		End

End
