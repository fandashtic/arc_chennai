Create Procedure dbo.Sp_SKUOPT_Daily_Int (@FromDate DateTime, @Todate DateTime) 
As  
Begin
	Set DateFormat DMY
	Declare @WDSKUListID as Int
	Declare @SKUPortfolioID as Int

	Declare @SystemDate as dateTime
	Declare @LastMonthFirstdate as dateTime
	Set @SystemDate = dbo.stripdatefromtime(Getdate())
	Set @LastMonthFirstdate = Cast(('01/'+ cast(Month(@SystemDate) as Nvarchar)  + '/' + cast(Year(@SystemDate) as Nvarchar)) as DateTime)
	Select Top 1 @SKUPortfolioID = ID From SKUPortfolio Where Active = 1  And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
	Select Top 1 @WDSKUListID = ID From WDSKUList Where Active = 1 And EFFECTIVEFROMDATE < @LastMonthFirstdate Order by Id Desc
--	select Top 1 @SKUPortfolioID = SKUPortfolioID, @WDSKUListID = WDSKUListID From tbl_SKUOpt_Monthly 

	Truncate Table tbl_SKUOPT_int
	If isnull(@WDSKUListID,0) > 0 
		Begin
			Insert Into tbl_SKUOPT_int (Type,FromDate,Todate,WDSKUListID,SKUPortfolioID,AlertFlag)
			Values (0,@FromDate,@Todate,Isnull(@WDSKUListID,0),Isnull(@SKUPortfolioID,0),0)
		End
	
	select Count(*) Row From tbl_SKUOPT_int

End
