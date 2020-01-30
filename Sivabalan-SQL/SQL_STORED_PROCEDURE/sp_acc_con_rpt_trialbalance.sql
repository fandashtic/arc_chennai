
CREATE procedure sp_acc_con_rpt_trialbalance(@fromdate datetime,@todate datetime)
	as
	DECLARE @debit decimal(18,2),@credit decimal(18,2),@account nvarchar(30),@group nvarchar(50)
	DECLARE @accountid integer,@groupid integer,@totaldebit decimal(18,2),@totalcredit decimal(18,2)
	DECLARE @parentid integer,@parentgroup integer 
	DECLARE @balance decimal(18,2),@TotalDepAmt Decimal(18,2)
	DECLARE @LEAFACCOUNT integer
	DECLARE @ACCOUNTGROUP integer
	DECLARE @NONEXTLEVEL integer
	
	SET @LEAFACCOUNT =2
	SET @ACCOUNTGROUP =3
	SET @NONEXTLEVEL =1
	 
	
	
	set @parentgroup = 0
	
	create Table #TempRegister(GroupID integer,GroupName nvarchar(255),Debit decimal(18,2),Credit 
	decimal(18,2),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)
	
	DECLARE scanrootlevel CURSOR KEYSET FOR
	select [GroupID],[GroupName]  from ConsolidateAccountGroup where [ParentGroup]=@parentgroup
	and isnull(GroupID,0)<>500
	OPEN scanrootlevel
	
	FETCH FROM scanrootlevel into @groupid,@group
	
	WHILE @@FETCH_STATUS =0
	BEGIN
		--Set @Balance=0
	   	-- execute sp_acc_rpt_recursivebalance @groupid,@fromdate,@todate,@balance output
	    		execute sp_acc_con_rpt_trialrecursivebalance @groupid,@fromdate,@todate,@balance output,@TotalDepAmt output
    		If @TotalDepAmt=0
		Begin      
    			INSERT INTO #TempRegister
		    	SELECT 'GroupID'= @groupid,'GroupName'=@group,'Debit'= CASE WHEN ((@balance)> 0) then 
    			@balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP     
		End
		Else
		Begin
    			INSERT INTO #TempRegister
		    	SELECT 'GroupID'= @groupid,'GroupName'=@group + N' less depreciation value ' + cast(@TotalDepAmt as nvarchar(50)),'Debit'= CASE WHEN ((@balance)> 0) then 
    			@balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP     
		End
  		FETCH NEXT FROM scanrootlevel into @groupid,@group
 	END
	CLOSE scanrootlevel
	DEALLOCATE scanrootlevel
	
	select @totaldebit = SUM(ISNULL(Debit,0)),@totalcredit = SUM(ISNULL(Credit,0)) from #TempRegister
	
	INSERT #TempRegister
	select Null,'Total',@totaldebit,@totalcredit,@fromdate,@todate,0,0,@NONEXTLEVEL     
	
	select 'Account Group'= GroupName,'Debit'=Debit,'Credit'=Credit,'', 'GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,@fromdate,@todate,DocRef,DocType,ColorInfo,ColorInfo from #TempRegister 
	Drop table #TempRegister

