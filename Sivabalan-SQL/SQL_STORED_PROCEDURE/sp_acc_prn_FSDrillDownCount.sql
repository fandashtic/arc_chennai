CREATE Procedure sp_acc_prn_FSDrillDownCount(@fromdate datetime,@todate datetime ,@parentid  integer,@Hide0BalAC Int =0)
	as
	DECLARE @debit decimal(18,6),@credit decimal(18,6),@account nvarchar(30),@group nvarchar(50)
	DECLARE @totaldebit decimal(18,6),@totalcredit decimal(18,6)
	DECLARE @parentgroup1 integer,@groupid integer,@parentgroup  integer
	DECLARE @balance decimal(18,6),@TotalDepAmt Decimal(18,6)
	Declare @Count Int
	
	DECLARE @LEAFACCOUNT integer
	DECLARE @ACCOUNTGROUP integer
	DECLARE @NEXTLEVEL integer
	DECLARE @NONEXTLEVEL integer
	
	
	SET @NEXTLEVEL =0
	SET @NONEXTLEVEL =1
	SET @LEAFACCOUNT =2
	SET @ACCOUNTGROUP =3
	
	Declare @TranID1 Int,@Debit1 Decimal(18,6),@Credit1 Decimal(18,6)
	Declare @TotalDebit1 Decimal(18,6),@TotalCredit1 Decimal(18,6)
		set @parentgroup1 = @parentid
		
		create Table #TempRegister(GroupID integer,GroupName nvarchar(50),Debit decimal(18,6),Credit decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)
		
		DECLARE scanrootlevel CURSOR KEYSET FOR
		select [GroupID],[GroupName]  from [AccountGroup] where [ParentGroup]=@parentgroup1 and isnull(Active,0)=1
		
		OPEN scanrootlevel
		
		FETCH FROM scanrootlevel into @groupid,@group
		
		WHILE @@FETCH_STATUS =0
		 BEGIN
		    execute sp_acc_rpt_trialrecursivebalance @groupid,@fromdate,@todate,@balance output,@TotalDepAmt output
		
		    If @TotalDepAmt=0
		    begin   
		    	INSERT INTO #TempRegister
		    	SELECT 'GroupID'= @groupid,'GroupName'=@group,'Debit'= CASE WHEN ((@balance)> 0) then 
		    	@balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP     
		    end	
		    else
		    begin
		    	INSERT INTO #TempRegister
		    	SELECT 'GroupID'= @groupid,'GroupName'=@group + dbo.LookupDictionaryItem(' less depreciation value ',Default)  + cast(@TotalDepAmt as nvarchar(50)),'Debit'= CASE WHEN ((@balance)> 0) then 
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

		Declare @AccountID Int,@AccountName nvarchar(50),@LastBalance decimal(18,6)
		Declare @DepPercent Decimal(18,6), @DepAmount Decimal(18,6), @OpeningBalance Decimal(18,6)
		Declare @DepOpeningBalance Decimal(18,6),@DepOpeningBalanceAmt Decimal(18,6),@DepAPVBalanceAmt Decimal(18,6),@DepARVBalanceAmt Decimal(18,6)
		Declare @CheckDate as datetime,@StrDate as nvarchar(255), @APVBalanceAmt as Decimal(18,6)
		Select @StrDate=  N'1/' + Cast(IsNull(FiscalYear,4) as nvarchar) + N'/' + Cast(Year(OpeningDate) As nVarchar(50)) From Setup
		Set @CheckDate =Cast(@StrDate As DateTime)
		set @CheckDate = DateAdd(m, 6, @CheckDate)
		set @CheckDate = DateAdd(d, 0-1, @CheckDate)

		DECLARE scantrialbalanceaccounts CURSOR KEYSET FOR
		select AccountID,AccountName from AccountsMaster where [GroupID]= @parentid 
		and AccountID not in (@CLOSINGSTOCK,@TAXONCLOSINGSTOCK) and isnull(Active,0)=1
		OPEN scantrialbalanceaccounts
		FETCH FROM scantrialbalanceaccounts into @AccountID,@AccountName
		WHILE @@FETCH_STATUS=0
		Begin
/*			If @AccountID=@CLOSINGSTOCK
			Begin
				If @Todate<dbo.stripdatefromtime(getdate())
				Begin
					Select @balance=sum(opening_Value)from OpeningDetails 
					where Opening_Date=dateadd(day,1,@ToDate)
				End
				Else
				Begin
					Select @balance= sum(Quantity*PurchasePrice)from Batch_Products
				End
				set @balance =isnull(@balance,0)
				INSERT #TempRegister
				select 'Group ID'= @AccountID,'Group Name'= @AccountName ,
				'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,
				'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,
				@fromdate,@todate,0,0,@LEAFACCOUNT 
	
			End
*/
			If @AccountID=@DEPRECIATION
			Begin
				execute sp_acc_rpt_depreciationComputation @ToDate,@FIXEDASSETS,@balance output
				set @balance =isnull(@balance,0)
				INSERT #TempRegister
				select 'Group ID'= @AccountID,'Group Name'= @AccountName ,
				'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,
				'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,
				@fromdate,@todate,0,0,@LEAFACCOUNT 
	
			End
			Else if @AccountID=@OPENINGSTOCK
			Begin
				Select @OpeningBalance=sum(isnull(Opening_Value,0)) from OpeningDetails where Opening_Date=@FromDate
				Set @OpeningBalance=isnull(@OpeningBalance,0)
				INSERT #TempRegister
				select 'Group ID'= @AccountID,'Group Name'= @AccountName ,
				'Debit'= CASE WHEN (@OpeningBalance)> 0 THEN (@OpeningBalance)ELSE 0 END,
				'Credit' = CASE WHEN (@OpeningBalance)< 0 THEN abs(@OpeningBalance)ELSE 0 END,
				@fromdate,@todate,0,0,@LEAFACCOUNT 

			End
			Else if @AccountID=@TAXONOPENINGSTOCK
			Begin
				Select @OpeningBalance=Sum(Case When (IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0)) <> 0 Then 
				(IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0))/100 Else 0 End) from OpeningDetails where Opening_Date=@FromDate
				Set @OpeningBalance=isnull(@OpeningBalance,0)
				INSERT #TempRegister
				select 'Group ID'= @AccountID,'Group Name'= @AccountName ,
				'Debit'= CASE WHEN (@OpeningBalance)> 0 THEN (@OpeningBalance)ELSE 0 END,
				'Credit' = CASE WHEN (@OpeningBalance)< 0 THEN abs(@OpeningBalance)ELSE 0 END,
				@fromdate,@todate,0,0,@LEAFACCOUNT 

			End

			Else
			Begin
				If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@todate and AccountID =@AccountID)
				Begin
					Select @LastBalance= isNull(Sum(OpeningBalance),0) from AccountsMaster where AccountId =@AccountID and isnull(Active,0)=1
				End
				Else
				Begin	
					set @LastBalance= isnull((Select Sum(OpeningValue) from AccountOpeningBalance where OpeningDate=@todate and AccountID =@AccountID),0)
				End
			
				
				-- Depreciation value deducted from fixed Assest leaf account
				Exec sp_acc_rpt_fixedAssetrecursive @AccountID,@Exists output
				If @Exists=1
				Begin
					Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID and isnull(Active,0)=1),0)
				
					--If @DepPercent>0 
					--Begin
						Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when dbo.stripdatefromtime(IsNull(BillDate,0))<=@CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
						from Batch_Assets where IsNull(Saleable,0)=1 and AccountID=@AccountID
						set @DepAmount=IsNull(@DepAPVBalanceAmt,0)
						Set @Balance=IsNull(@APVBalanceAmt,0)
					--End
					Set @balance=IsNull(@balance,0) - IsNull(@DepAmount,0)

					INSERT #TempRegister
					select 'Group ID'= @AccountID,'Group Name'= @AccountName + dbo.LookupDictionaryItem(' less depreciation value ',Default)  + cast(@DepAmount as nvarchar(50)),
					'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,
					'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,
					@fromdate,@todate,0,0,@LEAFACCOUNT 

				End
				Else
				Begin
					set @balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal 
					where dbo.stripdatefromtime([TransactionDate]) = @todate and [AccountID] = @AccountID and 
					documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63)),0)
					set @balance=@balance + @LastBalance
					INSERT #TempRegister
					select 'Group ID'= @AccountID,'Group Name'= @AccountName ,
					'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,
					'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,
					@fromdate,@todate,0,0,@LEAFACCOUNT 

				End
			End
			/*INSERT #TempRegister
			select 'Group ID'= @AccountID,'Group Name'= @AccountName ,
			'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,
			'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,
			@fromdate,@todate,0,0,@LEAFACCOUNT 
			*/
			FETCH NEXT FROM scantrialbalanceaccounts into @AccountID,@AccountName
		End
		CLOSE scantrialbalanceaccounts
		DEALLOCATE scantrialbalanceaccounts	
	/*	
		INSERT #TempRegister
		select 'GroupID'= [GeneralJournal].[AccountID],'GroupName'= [AccountsMaster].[AccountName],
		'Debit'= CASE WHEN (sum(debit)- sum(credit))> 0 THEN sum(debit)- sum(credit) ELSE 0 END,
		'Credit' = CASE WHEN (sum(debit)- sum(credit))< 0 THEN abs(sum(debit)- sum(credit))ELSE 0 END,
		@fromdate,@todate,0,0,@LEAFACCOUNT from AccountsMaster,GeneralJournal where
		dbo.stripdatefromtime([TransactionDate]) between @fromdate and @todate and [AccountsMaster].[AccountID]= [GeneralJournal].[AccountID]
		and [AccountsMaster].[AccountID] in (select AccountID from AccountsMaster where [GroupID]= @parentid)
		group by [GeneralJournal].[AccountID],[AccountsMaster].[AccountName]
	*/	
		
-- 		select @totaldebit = SUM(ISNULL(Debit,0)),@totalcredit = SUM(ISNULL(Credit,0)) from #TempRegister
-- 		
-- 		INSERT #TempRegister
-- 		select '','Total',@totaldebit,@totalcredit,@fromdate,@todate,0,0,@NONEXTLEVEL
		
		/* select 'Account/Group'= GroupName,'Debit'=Debit,'Credit'=Credit,'', 
		'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,
		@fromdate,@todate,DocRef,DocType,ColorInfo,ColorInfo from #TempRegister --to match parameters column, extra colorinfo column added
		Drop table #TempRegister
		*/
		If @Hide0BalAC = 0
		Begin
			Select @Count=Count(*) from #TempRegister
		End
		Else
		Begin
			Select @Count=Count(*) from #TempRegister
			Where ((Isnull(Debit,0) + Isnull(Credit,0)) > 0 or isnull(colorinfo,0) in (1,3))
		End
--	END
	Select @Count
-- 	ELSE IF @mode=@LEAFACCOUNT 
-- 	BEGIN
-- 	   exec sp_acc_rpt_account @fromdate,@todate,@parentid
-- 	END


