
CREATE procedure sp_acc_con_rpt_trialbalancegroupwise(@fromdate datetime,@todate datetime ,@parentid  integer,@docref integer,@doctype integer,@mode integer,@Info nvarchar(4000) = Null)
	as
	DECLARE @debit decimal(18,2),@credit decimal(18,2),@account nvarchar(30),@group nvarchar(50)
	DECLARE @totaldebit decimal(18,2),@totalcredit decimal(18,2)
	DECLARE @parentgroup1 integer,@groupid integer,@parentgroup  integer
	DECLARE @balance decimal(18,2),@TotalDepAmt Decimal(18,2)
	
	DECLARE @LEAFACCOUNT integer
	DECLARE @ACCOUNTGROUP integer
	DECLARE @NEXTLEVEL integer
	DECLARE @NONEXTLEVEL integer
	DECLARE @SPECIALCASE2 Integer
	
	
	SET @NEXTLEVEL =0
	SET @NONEXTLEVEL =1
	SET @LEAFACCOUNT =2
	SET @ACCOUNTGROUP =3
	SET @SPECIALCASE2 =5
	
	Declare @TranID1 Int,@Debit1 Decimal(18,2),@Credit1 Decimal(18,2)
	Declare @TotalDebit1 Decimal(18,2),@TotalCredit1 Decimal(18,2)
	IF @mode = @ACCOUNTGROUP 
	BEGIN
	
		set @parentgroup1 = @parentid
		
		create Table #TempRegister(GroupID integer,GroupName nvarchar(255),Debit decimal(18,2),Credit decimal(18,2),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)
		
		DECLARE scanrootlevel CURSOR KEYSET FOR
--		select [GroupID],[GroupName]  from [AccountGroup] where [ParentGroup]=@parentgroup1 and [GroupID]<> 21 -- stock in trade =21
		select [GroupID],[GroupName]  from ConsolidateAccountGroup where [ParentGroup]=@parentgroup1 and [GroupID] not in (55,500) --Closing Stock,User AccountGroup Start
		
		OPEN scanrootlevel
		
		FETCH FROM scanrootlevel into @groupid,@group
		
		WHILE @@FETCH_STATUS =0
		 BEGIN
		    execute sp_acc_con_rpt_trialrecursivebalance @groupid,@fromdate,@todate,@balance output,@TotalDepAmt output
		
		    If @TotalDepAmt=0
		    begin   
		    	INSERT INTO #TempRegister
		    	SELECT 'GroupID'= @groupid,'GroupName'=@group,'Debit'= CASE WHEN ((@balance)> 0) then 
		    	@balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP     
		    end	
		    else
		    begin
		    	INSERT INTO #TempRegister
		    	SELECT 'GroupID'= @groupid,'GroupName'=@group + N' less depreciation value ' + cast(@TotalDepAmt as nvarchar(50)),'Debit'= CASE WHEN ((@balance)> 0) then 
		    	@balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP     
		    end		
		
		  FETCH NEXT FROM scanrootlevel into @groupid,@group
		 END
		CLOSE scanrootlevel
		DEALLOCATE scanrootlevel
	
		Declare @CLOSINGSTOCK Int,@DEPRECIATION Int,@FIXEDASSETS Int,@Exists Int,@TAXONCLOSINGSTOCK Int,@TAXONOPENINGSTOCK Int
		Declare @OPENINGSTOCK Int
		Set @OPENINGSTOCK=22
		Set @CLOSINGSTOCK=23
		Set @DEPRECIATION=24
		Set @FIXEDASSETS=13
		Set @TAXONCLOSINGSTOCK=88
		Set @TAXONOPENINGSTOCK=89
		Declare @AccountID Int,@AccountName nvarchar(50),@LastBalance decimal(18,2)
		Declare @DepPercent Decimal(18,2), @DepAmount Decimal(18,2), @OpeningBalance Decimal(18,2)
		Declare @DepOpeningBalance Decimal(18,2),@DepOpeningBalanceAmt Decimal(18,2),@DepAPVBalanceAmt Decimal(18,2),@DepARVBalanceAmt Decimal(18,2)
		DECLARE scantrialbalanceaccounts CURSOR KEYSET FOR
		select AccountID,AccountName from ConsolidateAccount where [GroupID]= @parentid 
		and AccountID not in (@CLOSINGSTOCK,@TAXONCLOSINGSTOCK)  --and isnull(Active,0)=1
		OPEN scantrialbalanceaccounts
		FETCH FROM scantrialbalanceaccounts into @AccountID,@AccountName
		WHILE @@FETCH_STATUS=0
		Begin
			-- Depreciation value deducted from fixed Assest leaf account
			Exec sp_acc_con_rpt_fixedAssetrecursive @AccountID,@Exists output
			If @Exists=1
			Begin
				Select @balance= isNull(ClosingBalance,0),@DepAmount=IsNull(Depreciation,0) from ConsolidateAccount where AccountId=@AccountID --and isnull(Active,0)=1
				Set @balance=IsNull(@balance,0) - IsNull(@DepAmount,0)
				INSERT #TempRegister
				select 'Group ID'= @AccountID,'Group Name'= @AccountName + N' less depreciation value ' + cast(@DepAmount as nvarchar(50)),
				'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,
				'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,
				@fromdate,@todate,0,0,@SPECIALCASE2 
			End
			Else
			Begin
				If @AccountID=@OPENINGSTOCK or @AccountID=@TAXONOPENINGSTOCK
				Begin
					Select @balance= isNull(OpeningBalance,0) from ConsolidateAccount where AccountId=@AccountID --and isnull(Active,0)=1
				End
				Else
				Begin
					Select @balance= isNull(ClosingBalance,0) from ConsolidateAccount where AccountId=@AccountID --and isnull(Active,0)=1
				End
				INSERT #TempRegister
				select 'Group ID'= @AccountID,'Group Name'= @AccountName ,
				'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,
				'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,
				@fromdate,@todate,0,0,@SPECIALCASE2 
			End
			FETCH NEXT FROM scantrialbalanceaccounts into @AccountID,@AccountName
		End
		CLOSE scantrialbalanceaccounts
		DEALLOCATE scantrialbalanceaccounts	
		
		select @totaldebit = SUM(ISNULL(Debit,0)),@totalcredit = SUM(ISNULL(Credit,0)) from #TempRegister
		
		INSERT #TempRegister
		select '','Total',@totaldebit,@totalcredit,@fromdate,@todate,0,0,@NONEXTLEVEL
		
		select 'Account/Group'= GroupName,'Debit'=Debit,'Credit'=Credit,'', 
		'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,
		@fromdate,@todate,DocRef,DocType,ColorInfo,ColorInfo from #TempRegister --to match parameters column, extra colorinfo column added
		Drop table #TempRegister
	END
-- 	ELSE IF @mode=@LEAFACCOUNT 
-- 	BEGIN
-- 	   exec sp_acc_rpt_account @fromdate,@todate,@parentid
-- 	END
-- 	ELSE IF @mode =@NEXTLEVEL
-- 	BEGIN
-- 	   exec sp_acc_rpt_accountdetail @docref,@doctype,@Info
-- 	END

