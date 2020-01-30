Create Procedure dbo.Sp_SKUOPT_Exists(@Type Int = 1)
As  
Begin
	Declare @Exists as int
	Set DateFormat DMY
	Declare @LastMonthEndDayclosedate as dateTime
	Declare @LastMonthFirstdate as dateTime
	Declare @SystemDate as dateTime
	Declare @LastDaycloseDate as dateTime
	Declare @SKUPortfolio as Int
	Declare @WDSKUList as Int
	Declare @HMSKU as Int
	Declare @GraceDay as Int
	
	Set @SystemDate = dbo.stripdatefromtime(Getdate())
	Set @LastMonthFirstdate = Cast(('01/'+ cast(Month(@SystemDate) as Nvarchar)  + '/' + cast(Year(@SystemDate) as Nvarchar)) as DateTime)
	Set @LastMonthEndDayclosedate = DateAdd(day,-1,Cast(('01/'+ cast(Month(@SystemDate) as Nvarchar)  + '/' + cast(Year(@SystemDate) as Nvarchar)) as DateTime))
	Select Top 1 @SKUPortfolio = Isnull(ID,0) From SKUPortfolio Where Active = 1  And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
	Select Top 1 @WDSKUList = Isnull(ID,0) From WDSKUList Where Active = 1 And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
	Select Top 1 @HMSKU = Isnull(ID,0) From HMSKU Where Active = 1  And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
	Select @LastDaycloseDate = LastInventoryUpload From setup
	Set @GraceDay = (Select Top 1 [Value] from tbl_merp_configdetail where screencode='SKUOPT')

	If @Type = 1
	Begin
		If @WDSKUList > 0
			Begin
				If Exists (select * from tbl_SKUOpt_Monthly Where SKUPortfolioId = isnull(@SKUPortfolio,0) and WDSKUListId = isnull(@WDSKUList,0) and HMSKUID = isnull(@HMSKU,0) and @LastMonthEndDayclosedate in (Todate))
					Begin
						Set @Exists =  1
					End
				Else
					Begin
						Set @Exists =  0
					End
			End
	End
	
	If @Type = 0
	Begin
		Set @SKUPortfolio = (select Top 1 SKUPortfolioId From tbl_SKUOpt_Monthly Where Status = 1)
		Set @WDSKUList = (select Top 1 SKUPortfolioId From tbl_SKUOpt_Monthly Where Status = 1)

		If @SKUPortfolio > 0 And @WDSKUList > 0
			Begin
				If (select top 1 Count(*) from tbl_SKUOpt_Incremental Where SKUPortfolioId = isnull(@SKUPortfolio,0) ) > 0 and (select top 1 Count(*) from tbl_SKUOpt_Incremental Where WDSKUListId = isnull(@WDSKUList,0)) > 0 
					Begin
						Set @Exists =  1
					End
				Else
					Begin
						Set @Exists =  0
					End
			End
	End
	
	Select Isnull(@Exists,0) DataExists
End
