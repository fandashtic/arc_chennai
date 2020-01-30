CREATE procedure sp_acc_con_rpt_companywiseDetail(@parentid integer,@fromdate datetime, @todate datetime,@Companies nvarchar(2000),@AccountMode integer,@Report nVarchar(255))
as

Declare @TRADINGACCOUNT nVarchar(255),@BALANCESHEET nVarchar(255),@TRIALBALANCE nVarchar(255)
Set @TRADINGACCOUNT=N'Trading - Profit & Loss A/C'
Set @BALANCESHEET = N'Balance Sheet'
Set @TRIALBALANCE = N'Trial Balance'

DECLARE @balance decimal(18,2),@TotalDepAmt Decimal(18,2),@totaldebit decimal(18,2),@totalcredit decimal(18,2)
Declare @Company nvarchar(128),@SpecificCompanyID nvarchar(128),@Fixed Integer,@RequiredCompany nvarchar(2000)
Set @RequiredCompany =@Companies
create Table #TempCompanyDetail(Company nvarchar(255),Debit decimal(18,2),Credit decimal(18,2),ColorInfo int)
If @AccountMode=3 --AccountGroup Level
Begin
	Select @Fixed=IsNull(Fixed,0) from ConsolidateAccountGroup Where GroupID=@ParentID
	If IsNull(@Fixed,0) =0
	Begin
		Select @SpecificCompanyID=CompanyID from ConsolidateAccountGroup Where GroupID=@ParentID
		Set @RequiredCompany=@SpecificCompanyID
	End
End
Else If @AccountMode<>6-- 6-Trading Ac from balance sheeet
Begin
	Select @Fixed=IsNull(Fixed,0) from ConsolidateAccount Where AccountID=@ParentID --and Date=@todate
	If IsNull(@Fixed,0) =0
	Begin
		Select @SpecificCompanyID=CompanyID from ConsolidateAccount Where AccountID=@ParentID --and Date=@todate
		Set @RequiredCompany=@SpecificCompanyID
	End
End
Create Table #TempComp (Company nvarchar(128) Null)
Insert #TempComp
--exec sp_acc_SqlSplit @Companies,','
exec sp_acc_SqlSplit @RequiredCompany,N','
DECLARE scanrootlevel CURSOR KEYSET FOR
select Company  from #TempComp
OPEN scanrootlevel
FETCH FROM scanrootlevel into @Company
WHILE @@FETCH_STATUS =0
BEGIN
	If @Report=@TRADINGACCOUNT
	Begin
	    	execute sp_acc_con_rpt_Companytradingrecursivebalance @parentid,@fromdate,@todate,@Company,@AccountMode,@Fixed,@balance output
		INSERT INTO #TempCompanyDetail
	    	SELECT 'CompanyID'= @Company,'Debit'= CASE WHEN ((@balance)> 0) then 
		@balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,0    
	End
	Else If @Report= @BALANCESHEET
	Begin
		If @AccountMode=6 -- TradingAC from Balance Sheet
		Begin
		    	execute sp_acc_con_rpt_BalanceSheetTradingAC @fromdate,@todate,@Company,@balance output

			INSERT INTO #TempCompanyDetail
		    	SELECT CASE WHEN ((@balance)> 0) then @Company + N' - Loss for the period ' else @Company + N' - Profit for the period ' end,
			'Debit'= CASE WHEN ((@balance)> 0) then @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,0    


		End
		Else
		Begin
		    	execute sp_acc_con_rpt_companybalancesheetrecursivebalance @parentid,@fromdate,@todate,@Company,@AccountMode,@Fixed,@balance output,@TotalDepAmt output
			If @TotalDepAmt=0
			Begin      
				INSERT INTO #TempCompanyDetail
			    	SELECT 'CompanyID'= @Company,'Debit'= CASE WHEN ((@balance)> 0) then 
				@balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,0    
			End
			Else
			Begin
				INSERT INTO #TempCompanyDetail
			    	SELECT 'CompanyID'= @Company + N' less depreciation value ' + cast(@TotalDepAmt as nvarchar(50)),'Debit'= CASE WHEN ((@balance)> 0) then 
					@balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,0
			End
		End
	End
	Else If @Report= @TRIALBALANCE
	Begin
	    	execute sp_acc_con_rpt_Companytrialrecursivebalance @parentid,@fromdate,@todate,@Company,@AccountMode,@Fixed,@balance output,@TotalDepAmt output
		If @TotalDepAmt=0
		Begin      
			INSERT INTO #TempCompanyDetail
		    	SELECT 'CompanyID'= @Company,'Debit'= CASE WHEN ((@balance)> 0) then 
			@balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,0    
		End
		Else
		Begin
			INSERT INTO #TempCompanyDetail
		    	SELECT 'CompanyID'= @Company + N' less depreciation value ' + cast(@TotalDepAmt as nvarchar(50)),'Debit'= CASE WHEN ((@balance)> 0) then 
				@balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,0
		End
	End
	FETCH NEXT FROM scanrootlevel into @Company
END
CLOSE scanrootlevel
DEALLOCATE scanrootlevel
select @totaldebit = SUM(ISNULL(Debit,0)),@totalcredit = SUM(ISNULL(Credit,0)) from #TempCompanyDetail
INSERT #TempCompanyDetail
--select 'Total',@totaldebit,@totalcredit
select 'Balance',CASE WHEN ((@totaldebit-@totalcredit)> 0) then (@totaldebit-@totalcredit) else 0 end,CASE WHEN (((@totaldebit-@totalcredit))< 0) then abs((@totaldebit-@totalcredit)) else 0 end,1
select 'CompanyID'= Company,'Debit'=Debit,'Credit'=Credit,ColorInfo from #TempCompanyDetail
Drop table #TempCompanyDetail

