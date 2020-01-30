CREATE procedure sp_acc_con_rpt_tradingacdetail(@fromdate datetime,@todate datetime ,@parentid  integer,@docref integer,@doctype integer,@mode integer,@Info nvarchar(4000) = Null)
as
DECLARE @debit decimal(18,2),@credit decimal(18,2),@account nvarchar(30),@group nvarchar(50)
DECLARE @totaldebit decimal(18,2),@totalcredit decimal(18,2)
DECLARE @parentgroup1 integer,@groupid integer,@parentgroup  integer
DECLARE @balance decimal(18,2),@ConvertInfo Decimal(18,2)

DECLARE @LEAFACCOUNT integer
DECLARE @ACCOUNTGROUP integer
DECLARE @NEXTLEVEL integer
DECLARE @NONEXTLEVEL integer
DECLARE @SPECIALCASE4 Integer
DECLARE @SPECIALCASE2 Integer

SET @NEXTLEVEL =0
SET @NONEXTLEVEL =1
SET @LEAFACCOUNT =2
SET @ACCOUNTGROUP =3
SET @SPECIALCASE4=100
SET @SPECIALCASE2 =5

Declare @DayCount int
Set @DayCount=DateDiff(day,@FromDate,@ToDate)+1

Declare @OpenDate DateTime -- Opening date from setup
Select @OpenDate=OpeningDate from setup


IF @mode = @ACCOUNTGROUP 
BEGIN

	set @parentgroup1 = @parentid
	
	create Table #TempRegister(GroupID integer,GroupName nvarchar(50),Debit decimal(18,2),Credit decimal(18,2),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)
	
	DECLARE scanrootlevel CURSOR KEYSET FOR
	select [GroupID],[GroupName]  from ConsolidateAccountGroup where [ParentGroup]=@parentgroup1 
	--and isnull(Active,0)=1
	
	OPEN scanrootlevel
	
	FETCH FROM scanrootlevel into @groupid,@group
	
	WHILE @@FETCH_STATUS =0
	 BEGIN
	    execute sp_acc_con_rpt_tradingacrecursivebalance @groupid,@fromdate,@todate,@balance output
	       
	    INSERT INTO #TempRegister
	    SELECT 'GroupID'= @groupid,'GroupName'=@group,'Debit'= CASE WHEN ((@balance)> 0) then 
	    @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP     
	
	  FETCH NEXT FROM scanrootlevel into @groupid,@group
	 END
	CLOSE scanrootlevel
	DEALLOCATE scanrootlevel

	Declare @AccountID Int,@AccountName nvarchar(50),@LastBalance Decimal(18,2),@FromDateOpeningBalance Decimal(18,2)
	Declare @DEPRECIATION Int,@FIXEDASSETS Int
	Set @DEPRECIATION=24
	Set @FIXEDASSETS=13

	Declare @OPENINGSTOCK INT,@CLOSINGSTOCK Int,@TAXONCLOSINGSTOCK Int,@TAXONOPENINGSTOCK Int
	SET @OPENINGSTOCK=22
	Set @CLOSINGSTOCK=23
	Set @TAXONCLOSINGSTOCK=88
	Set @TAXONOPENINGSTOCK=89

	DECLARE scanbalancesheetaccounts CURSOR KEYSET FOR
	select AccountID,AccountName from ConsolidateAccount where [GroupID]= @parentid --and isnull(Active,0)=1
	OPEN scanbalancesheetaccounts
	FETCH FROM scanbalancesheetaccounts into @AccountID,@AccountName
	WHILE @@FETCH_STATUS=0
	Begin
		If @AccountID=@OPENINGSTOCK Or @AccountID=@TAXONOPENINGSTOCK
		Begin
			Select @balance=IsNull(ClosingBalance,0) from  ConsolidateAccount where AccountID=@AccountID
			set @balance =isnull(@balance,0)

			INSERT #TempRegister
			select 'Group ID'= @AccountID,'Group Name'= @AccountName,
			'Debit'= abs(@balance),'Credit' = 0,
			@fromdate,@todate,0,0,@SPECIALCASE2
		End
		Else If @AccountID=@CLOSINGSTOCK Or @AccountID=@TAXONCLOSINGSTOCK
		Begin
			Select @balance=IsNull(ClosingBalance,0) from  ConsolidateAccount where AccountID=@AccountID
			set @balance =isnull(@balance,0)

			INSERT #TempRegister
			select 'Group ID'= @AccountID,'Group Name'= @AccountName,
			'Debit'= 0,'Credit' = abs(@balance),
			@fromdate,@todate,0,0,@SPECIALCASE2
		End
		Else
		Begin
			Select @LastBalance= isNull(ClosingBalance,0),@FromDateOpeningBalance= isNull(FromDateOpeningBalance,0) from ConsolidateAccount where AccountId=@AccountID --and isnull(Active,0)=1
			Set @Balance=IsNull(@LastBalance,0)-IsNull(@FromDateOpeningBalance,0)
			INSERT #TempRegister
			select 'Group ID'= @AccountID,'Group Name'= @AccountName,
			'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,
			'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,
			@fromdate,@todate,0,0,@SPECIALCASE2

		End

		FETCH NEXT FROM scanbalancesheetaccounts into @AccountID,@AccountName
	End
	CLOSE scanbalancesheetaccounts
	DEALLOCATE scanbalancesheetaccounts

	

	
	select @totaldebit = SUM(ISNULL(Debit,0)),@totalcredit = SUM(ISNULL(Credit,0)) from #TempRegister
	
	INSERT #TempRegister
	select '','Total',@totaldebit,@totalcredit,@fromdate,@todate,0,0,@NONEXTLEVEL
	
	select 'Account/Group'= GroupName,'Debit'=Debit,'Credit'=Credit,'', 'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,@fromdate,@todate,DocRef,DocType,ColorInfo,ColorInfo from #TempRegister 
	Drop table #TempRegister
END
-- ELSE IF @mode=@LEAFACCOUNT 
-- BEGIN
--    exec sp_acc_rpt_account @fromdate,@todate,@parentid
-- END
-- ELSE IF @mode =@NEXTLEVEL
-- BEGIN
--    exec sp_acc_rpt_accountdetail @docref,@doctype,@Info
-- END
-- ELSE IF @mode =@SPECIALCASE4
-- BEGIN
--    Set @ConvertInfo=Cast(@Info as Decimal(18,2))
--    exec sp_acc_rpt_netprofitdetail @ConvertInfo
-- END

