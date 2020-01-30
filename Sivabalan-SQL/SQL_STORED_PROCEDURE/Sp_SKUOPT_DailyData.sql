Create Procedure dbo.Sp_SKUOPT_DailyData (@DayCloseTodate DateTime)
As  
Begin
	Set DateFormat DMY
	Declare @TranDate as dateTime
	Declare @SystemDate as dateTime
	Declare @LastMonthFirstdate as dateTime
	Declare @DayCloseGraceDay as Int
	Declare @SKUPortfolio as Int
	Declare @WDSKUList as Int
	Declare @HMSKU as Int
	Declare @PendingAlert as Int
	Declare @AlertFlag as Int
	Declare @Todate as DateTime
	Declare @FromDate as DateTime
	Declare @Type as Int
		Begin
				Set @SystemDate = @DayCloseTodate
				Set @Type = 0
				Set @LastMonthFirstdate = Cast(('01/'+ cast(Month(@SystemDate) as Nvarchar)  + '/' + cast(Year(@SystemDate) as Nvarchar)) as DateTime)
				Set @DayCloseGraceDay = (Select isNull(Value,0) From tbl_mERP_ConfigDetail Where ScreenCode = N'CLSDAY01' And ControlName = N'GracePeriod')
				Select @Todate = (select dbo.stripdatefromtime(LastInventoryUpload) From setup)

				Select Top 1 @SKUPortfolio = ID From SKUPortfolio Where Active = 1 and EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
				Select Top 1 @WDSKUList = ID From WDSKUList Where Active = 1 and EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
				Select Top 1 @HMSKU = ID From HMSKU Where Active = 1 and EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc

			If Exists (select Top 1 * from tbl_SKUOpt_Incremental Where WDSKUListID = @WDSKUList and SKUPortfolioID = @SKUPortfolio and Status = 1)
				Begin
					Set @FromDate = (select Top 1 DateAdd(day,+1,Todate) From tbl_SKUOpt_Incremental)
				End
			Else If Exists (select Top 1 * from tbl_SKUOpt_Monthly Where WDSKUListID = @WDSKUList and HMSKUID = Isnull(@HMSKU,0) and SKUPortfolioID = @SKUPortfolio and Status = 1)
				Begin
					Set @FromDate = (select Top 1 DateAdd(day,+1,Todate) From tbl_SKUOpt_Monthly)
				End
			Else
				Begin
					Set @FromDate = @LastMonthFirstdate
				End

			Set @AlertFlag = 0
		End
		If @Todate < @FromDate
			Begin
				Set @Todate = @FromDate
			End
	If Isnull(@FromDate,'') <> '' And Isnull(@Todate,'') <> ''
	Begin
--		insert into tbl_SKUOPT_int Select 0,@FromDate,@Todate,@WDSKUList,@SKUPortfolio,@AlertFlag
		Select @Type [Type], @FromDate FromDate ,@Todate ToDate ,isnull(@WDSKUList,0) WDSKUListID ,isnull(@SKUPortfolio,0) SKUPortfolioID , Isnull(@HMSKU,0) HMSKUID,isnull(@AlertFlag,0) AlertFlag 
	End
	Else
		Select 0,Getdate(),Getdate(),0,0,0,0
End
