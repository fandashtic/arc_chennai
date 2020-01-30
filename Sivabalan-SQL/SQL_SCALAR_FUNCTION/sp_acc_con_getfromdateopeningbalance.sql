CREATE function sp_acc_con_getfromdateopeningbalance(@FromDate DateTime,@CompanyID nVarchar(255),@Mode Int,@AccountID Int)
Returns Decimal(18,2)
as
Begin
Declare @OPENINGSTOCK Int,@TAXONOPENINGSTOCK Int
Declare @OpeningBalance Decimal(18,2) 
Declare @DynamicSQL nVarchar(4000)

SET @OPENINGSTOCK=22
Set @TAXONOPENINGSTOCK=89

Declare @TempCompanies Table(CompanyInfo nVarchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS Null)

Insert @TempCompanies
Select * from sp_acc_SqlSplitDenominations(@CompanyID,N',')

If @AccountID=@OPENINGSTOCK or @AccountID=@TAXONOPENINGSTOCK
Begin
	If @Mode = 1
	Begin
	-- 	Set @DynamicSQL = 'Set @OpeningBalance = Select Sum(IsNull(OpeningBalance,0))From ReceiveAccount ' + 
	-- 	'Where CompanyID in (Select * from @TempCompanies)' + ' and dbo.stripdatefromtime([Date]) = ' + convert(varchar,@FromDate,103) +
	-- 	' and Fixed = 1 and AccountID = ' + cast(@AccountID as Varchar(4000)) 
		Set @OpeningBalance = (Select Sum(IsNull(ClosingBalance,0))From ReceiveAccount 
		Where CompanyID in (Select * from @TempCompanies) and dbo.stripdatefromtime([Date]) = @FromDate
		and Fixed = 1 and AccountID = @AccountID)
	--Execute sp_executesql @DynamicSQl
	End
	Else If @Mode = 2
	Begin
	-- 	Set @DynamicSQL = 'Set @OpeningBalnce = Select IsNull(OpeningBalance,0) From ReceiveAccount ' + 
	-- 	'Where CompanyID in (Select * from @TempCompanies) ' + 
	-- 	'and dbo.stripdatefromtime([Date]) = ' + convert(varchar,@FromDate,3) +
	-- 	' and AccountID = ' +  cast(@AccountID as Varchar(4000)) + ' and Fixed <> 1' 
	-- 	Execute sp_executesql @DynamicSQl
		Set @OpeningBalance = (Select IsNull(ClosingBalance,0) From ReceiveAccount
		Where CompanyID in (Select * from @TempCompanies)and dbo.stripdatefromtime([Date]) = dbo.stripdatefromtime(@FromDate)
		and AccountID = @AccountID and Fixed <> 1)
	End
End
Else
Begin
	If @Mode = 1
	Begin
	-- 	Set @DynamicSQL = 'Set @OpeningBalance = Select Sum(IsNull(OpeningBalance,0))From ReceiveAccount ' + 
	-- 	'Where CompanyID in (Select * from @TempCompanies)' + ' and dbo.stripdatefromtime([Date]) = ' + convert(varchar,@FromDate,103) +
	-- 	' and Fixed = 1 and AccountID = ' + cast(@AccountID as Varchar(4000)) 
		Set @OpeningBalance = (Select Sum(IsNull(OpeningBalance,0))From ReceiveAccount 
		Where CompanyID in (Select * from @TempCompanies) and dbo.stripdatefromtime([Date]) = @FromDate
		and Fixed = 1 and AccountID = @AccountID)
		--Execute sp_executesql @DynamicSQl
	End
	Else If @Mode = 2
	Begin
	-- 	Set @DynamicSQL = 'Set @OpeningBalnce = Select IsNull(OpeningBalance,0) From ReceiveAccount ' + 
	-- 	'Where CompanyID in (Select * from @TempCompanies) ' + 
	-- 	'and dbo.stripdatefromtime([Date]) = ' + convert(varchar,@FromDate,3) +
	-- 	' and AccountID = ' +  cast(@AccountID as Varchar(4000)) + ' and Fixed <> 1' 
	-- 	Execute sp_executesql @DynamicSQl
		Set @OpeningBalance = (Select IsNull(OpeningBalance,0) From ReceiveAccount
		Where CompanyID in (Select * from @TempCompanies)and dbo.stripdatefromtime([Date]) = dbo.stripdatefromtime(@FromDate)
		and AccountID = @AccountID and Fixed <> 1)
	End
End
Return @OpeningBalance
End

