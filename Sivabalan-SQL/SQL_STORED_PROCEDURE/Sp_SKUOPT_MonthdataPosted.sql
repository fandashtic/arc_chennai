Create Procedure dbo.Sp_SKUOPT_MonthdataPosted 
As  
Begin
	Declare @SKUPortfolio as Int
	Declare @WDSKUList as Int
	Declare @Todate as dateTime
	Declare @TranDate as dateTime
	Declare @dataPosting as Int
	Declare @DayCloseGraceDay as Int
	Declare @SystemDate as dateTime
	Declare @LastMonthFirstdate as dateTime

	Set @SystemDate = dbo.stripdatefromtime(Getdate())
	Set @LastMonthFirstdate = Cast(('01/'+ cast(Month(@SystemDate) as Nvarchar)  + '/' + cast(Year(@SystemDate) as Nvarchar)) as DateTime)
	Select @TranDate = TransactionDate From setup
	Set @DayCloseGraceDay = (Select isNull(Value,0) From tbl_mERP_ConfigDetail Where ScreenCode = N'CLSDAY01' And ControlName = N'GracePeriod')
	Select @Todate = DateAdd(day,-(@DayCloseGraceDay),@TranDate)
	Select Top 1 @SKUPortfolio = ID From SKUPortfolio Where Active = 1 and EFFECTIVEFROMDATE <= @LastMonthFirstdate Order by Id Desc
	Select Top 1 @WDSKUList = ID From WDSKUList Where Active = 1 and EFFECTIVEFROMDATE <= @LastMonthFirstdate Order by Id Desc

	If Exists (select Top 1 * from tbl_SKUOpt_Monthly Where WDSKUListID = @WDSKUList and SKUPortfolioID = @SKUPortfolio And Status = 1)
		Begin
			Set @dataPosting = 1
		End
	Else
		Begin
			Set @dataPosting = 0
		End

	Select @dataPosting DataPosting

End
