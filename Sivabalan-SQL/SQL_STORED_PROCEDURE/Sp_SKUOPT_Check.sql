Create Procedure dbo.Sp_SKUOPT_Check (@SystemDate DateTime,@Type Int)
As  
Begin
	Set DateFormat DMY
	Declare @TranDate as dateTime
	Declare @LastDaycloseDate as dateTime
	Declare @LastMonthEndDayclosedate as dateTime
	Declare @LastMonthFirstdate as dateTime
	Declare @FromDate as dateTime
	Declare @Todate as dateTime
	Declare @GraceDay as Int
	Declare @SKUPortfolio as Int
	Declare @WDSKUList as Int
	Declare @HMSKUID as Int
	Declare @AlertFlag as Int
	Declare @DayCloseGraceDay as Int
	Declare @PreviousMonthFirstDate as dateTime
	Declare @PreviousMonthEndDate as dateTime
	Set @SystemDate = dbo.stripdatefromtime(Getdate())

	Set @LastMonthFirstdate = Cast(('01/'+ cast(Month(@SystemDate) as Nvarchar)  + '/' + cast(Year(@SystemDate) as Nvarchar)) as DateTime)
	Select @LastDaycloseDate = LastInventoryUpload, @TranDate = TransactionDate From setup
	Set @GraceDay = (Select Top 1 [Value] from tbl_merp_configdetail where screencode='SKUOPT')
	Set @DayCloseGraceDay = (Select isNull(Value,0) From tbl_mERP_ConfigDetail Where ScreenCode = N'CLSDAY01' And ControlName = N'GracePeriod')

	If @Type = 1
		Begin

			Set @LastMonthEndDayclosedate = DateAdd(day,-1,Cast(('01/'+ cast(Month(@SystemDate) as Nvarchar)  + '/' + cast(Year(@SystemDate) as Nvarchar)) as DateTime))
			Set @PreviousMonthFirstDate = Cast(('01/' + Cast(Month(@LastMonthEndDayclosedate) as Nvarchar) + '/' + cast(Year(@LastMonthEndDayclosedate) as Nvarchar)) as DateTime)
			Set @PreviousMonthEndDate = DateAdd(Day,-1,@PreviousMonthFirstDate)

			Select Top 1 @SKUPortfolio = ID From SKUPortfolio Where Active = 1 And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
			Select Top 1 @WDSKUList = ID From WDSKUList Where Active = 1 And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
			Select Top 1 @HMSKUID = ID From HMSKU Where Active = 1 And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc

			If @LastMonthEndDayclosedate <= @LastDaycloseDate 
				Begin
					Set @Todate = dbo.stripdatefromtime(@LastMonthEndDayclosedate)
					Set @FromDate = cast(('01/' + cast(Month(DateAdd(Month,-1,@Todate)) as Nvarchar) +  '/'  + cast(Year(DateAdd(Month,-1,@Todate)) as Nvarchar)) as DateTime)
				End
			Else If @LastDaycloseDate >= @PreviousMonthEndDate
				Begin
					Set @Todate = dbo.stripdatefromtime(@PreviousMonthEndDate)
					Set @FromDate = cast(('01/' + cast(Month(DateAdd(Month,-1,@Todate)) as Nvarchar) +  '/'  + cast(Year(DateAdd(Month,-1,@Todate)) as Nvarchar)) as DateTime)
				End
	
			If @SystemDate <= (dbo.stripdatefromtime(DateAdd(day,@GraceDay,@Todate)))
				Begin
					Set @AlertFlag = 0
				End

			If @SystemDate < (dbo.stripdatefromtime(DateAdd(day,@GraceDay,@Todate))) and @SystemDate > @Todate
				Begin
					Set @AlertFlag = 1
				End

			If @SystemDate <= @Todate
				Begin
					Set @AlertFlag = 2
				End



	End

	Else If @Type = 0
		Begin
				Select @Todate = DateAdd(day,-(@DayCloseGraceDay),@TranDate)
				Select Top 1 @SKUPortfolio = ID From SKUPortfolio Where Active = 1 and EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
				Select Top 1 @WDSKUList = ID From WDSKUList Where Active = 1 and EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
				Select Top 1 @HMSKUID = ID From HMSKU Where Active = 1 and EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc

			If Exists (select Top 1 * from tbl_SKUOpt_Incremental Where WDSKUListID = @WDSKUList and SKUPortfolioID = @SKUPortfolio)
				Begin
					Set @FromDate = (select Top 1 DateAdd(day,+1,Todate) From tbl_SKUOpt_Incremental)
				End
			Else
				Begin
					Set @FromDate = (select Top 1 DateAdd(day,+1,Todate) From tbl_SKUOpt_Monthly)
				End

			Set @AlertFlag = 0
		End
	Truncate Table tbl_SKUOPT_int
	Insert Into tbl_SKUOPT_int (Type,FromDate,Todate,WDSKUListID,SKUPortfolioID,HMSKUID,AlertFlag)
	Select @Type [Type], @FromDate FromDate ,@Todate ToDate ,isnull(@WDSKUList,0) WDSKUListID ,isnull(@SKUPortfolio,0) SKUPortfolioID ,Isnull(@HMSKUID,0),isnull(@AlertFlag,0) AlertFlag 

End
