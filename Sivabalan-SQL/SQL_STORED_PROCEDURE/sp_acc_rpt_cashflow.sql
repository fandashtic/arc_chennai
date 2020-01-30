CREATE procedure sp_acc_rpt_cashflow (@fromdate datetime,@todate datetime)
	as
	DECLARE @debit decimal(18,6),@credit decimal(18,6),@account nvarchar(30),@group nvarchar(50)
	DECLARE @accountid integer,@groupid integer,@totaldebit decimal(18,6),@totalcredit decimal(18,6)
	DECLARE @parentid integer,@parentgroup integer 
	DECLARE @balance decimal(18,6),@TotalDepAmt Decimal(18,6)
	DECLARE @LEAFACCOUNT integer
	DECLARE @ACCOUNTGROUP integer
	DECLARE @NONEXTLEVEL integer
	
	DECLARE @GROUPNAME nVARCHAR(500)

	SET @LEAFACCOUNT =2
	SET @ACCOUNTGROUP=3
	SET @NONEXTLEVEL =1
	set dateformat dmy

	CREATE TABLE #CASHGROUP
	( 
		GROUPNAME nVARCHAR(500),GROUPID NUMERIC(18,0),PARENTGROUP nVARCHAR(500)
	) 

	INSERT INTO #CASHGROUP
	SELECT GROUPNAME,GROUPID,GROUPNAME FROM ACCOUNTGROUP WHERE GROUPID in (7,18,19)-- (19,18)-- (7)--,18)

-- -- -- 	SELECT GROUPNAME,GROUPID,0 FROM ACCOUNTGROUP WHERE GROUPID in (7,19,18)

	DECLARE SCANROOTLEVEL CURSOR DYNAMIC FOR
	SELECT [GROUPID],[GROUPNAME] ,GROUPNAME FROM #CASHGROUP 

	OPEN SCANROOTLEVEL

	FETCH FROM SCANROOTLEVEL INTO @GROUPID,@GROUP,@GROUPNAME

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #CASHGROUP 
		SELECT GROUPNAME,GROUPID,@GROUPNAME FROM ACCOUNTGROUP 
		WHERE PARENTGROUP = @GROUPID
	  	FETCH NEXT FROM SCANROOTLEVEL INTO @GROUPID,@GROUP,@GROUPNAME
	END
		CLOSE SCANROOTLEVEL
		DEALLOCATE SCANROOTLEVEL

-- -- 	SELECT * FROM ACCOUNTSMASTER WHERE CAST(GROUPID) in (select groupid from #CASHGROUP)

	create table #Cash_Bank_IDS
	(
		Accountid numeric(18),
		AccountName nvarchar(500),
		Groupid		numeric(18),
		ParentGroup nvarchar(500),
		Status 	numeric(9),
		OpeningValue decimal(18,6),
		ClosingValue decimal(18,6),
	)	

	
-- -- -- 	select * from #cashgroup

	insert into #Cash_Bank_IDS
	SELECT Accountid,accountname,groupid,null,0,0,0 FROM ACCOUNTSMASTER WHERE GROUPID in (select groupid from #CASHGROUP)


	create Table #TempRegister(GroupID integer,GroupName nvarchar(255),Debit decimal(18,6),Credit 
	decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)
	Declare @OpeningBalance Decimal(18,6),@closingBalance decimal(18,6)
	Declare @accountname nvarchar(500)
	
	--to update the parent groups for the ids in #cash_bank_ids table
-- -- -- 	update a set a.parentgroup = b.groupname from #Cash_Bank_IDS a, accountgroup b
-- -- -- 	where a.groupid = b.groupid
-- -- -- 	update #Cash_Bank_IDS set status = 1 where parentgroup in
-- -- -- 	(select groupname from accountgroup where groupid in (18,19,7) )
-- -- -- 	
-- -- -- 	Declare @UpdateStatus numeric(9)
-- -- -- 	Declare @ParentGroupId  numeric(9),@parentGroupName varchar(500)
-- -- -- 	select @Updatestatus = count(1) from #cash_bank_ids where status = 0
-- -- -- 	while @Updatestatus <> 0
-- -- -- 		Begin
-- -- -- 			declare parentgroup cursor for
-- -- -- 			select a.parentgroup,b.parentgroup from #cash_bank_ids a,accountgroup b
-- -- -- 			where a.status = 0 and a.parentgroup = b.groupname
-- -- -- 			open parentgroup
-- -- -- 			fetch from parentgroup into @parentgroupname,@parentgroupid
-- -- -- 			while @@fetch_status = 0 
-- -- -- 				begin
-- -- -- 					update #Cash_Bank_IDS
-- -- -- 					set parentgroup = (select groupname from accountgroup where 
-- -- -- 					groupid = @parentgroupid) 
-- -- -- 					where parentgroup not in (select groupname from accountgroup where groupid in (18,19,7) )
-- -- -- 
-- -- -- 					fetch next from parentgroup into @parentgroupname,@parentgroupid
-- -- -- 				end
-- -- -- 				update #Cash_Bank_IDS set status = 1 where parentgroup in
-- -- -- 				(select groupname from accountgroup where groupid in (18,19,7) )
-- -- -- 			select @Updatestatus = count(1) from #cash_bank_ids where status = 0
-- -- -- 			close parentgroup
-- -- -- 			deallocate parentgroup
-- -- -- 		End
-- -- -- 
-- -- -- 	--first update from accountopeningbalance
-- -- -- 	update a set a.openingvalue = isnull(b.openingvalue,0)
-- -- -- 	from #Cash_Bank_IDS a, accountopeningbalance b
-- -- -- 	where a.accountid = b.accountid and b.openingdate = @fromdate
-- -- -- 
-- -- -- 	--if opening values is still 0 then try from accountsmaster
-- -- -- 	update a set a.openingvalue = isnull(b.OpeningBalance,0)
-- -- -- 	from #Cash_Bank_IDS a, AccountsMaster b
-- -- -- 	where a.accountid = b.accountid and a.openingvalue = 0
-- -- -- 	insert into #tempregister (Groupname,Groupid,debit,credit,Fromdate,Todate,colorinfo,Docref,Doctype)
-- -- -- 	select distinct parentgroup,-1,sum(openingvalue),null,@fromdate,@fromdate,3,-1,-1 from #Cash_Bank_IDS 
-- -- -- 	group by parentgroup
	
	Declare OpeningDetails cursor dynamic for
	Select groupid,Groupname from accountgroup where groupid in (7,18,19) order by groupid
	Open OpeningDetails
	Fetch from OpeningDetails into @Groupid,@Groupname
	While @@Fetch_status = 0
		Begin
			Set @Balance = 0
			Exec sp_acc_rpt_Cashflow_OpeningClosingBalance @Groupid,@Fromdate,@Todate,1,@Balance output
			insert into #tempregister (Groupname,Groupid,debit,credit,Fromdate,Todate,colorinfo,Docref,Doctype)
			select distinct @Groupname,-1,@Balance,null,@fromdate,@fromdate,3,-1,-1

			Fetch Next from OpeningDetails into @Groupid,@Groupname
		End
	Close OpeningDetails
	Deallocate OpeningDetails
	
	--insert total opening balance
	insert into #tempregister (Groupid , GroupName, Credit,fromdate,todate,colorinfo)
	select -1,'Total Opening Balance',sum(debit),@fromdate,@fromdate,1 from #tempregister

	insert into #tempregister (Groupid,GroupName,Fromdate,Todate)
	values (-1,null,@fromdate,@todate)
	

	set @parentgroup = 0
	
	DECLARE scanrootlevel CURSOR KEYSET FOR
	select [GroupID],[GroupName]  from [AccountGroup] where [ParentGroup]=0
	and isnull(GroupID,0)<>500

	OPEN scanrootlevel
	
	FETCH FROM scanrootlevel into @groupid,@group
	
	WHILE @@FETCH_STATUS =0
	BEGIN
	   	-- execute sp_acc_rpt_recursivebalance @groupid,@fromdate,@todate,@balance output
    	execute sp_acc_rpt_cashflowrecursivebalance @groupid,@fromdate,@todate,@balance output --,@TotalDepAmt output
		INSERT INTO #TempRegister
    	SELECT 'GroupID'= @groupid,'GroupName'=@group ,'Debit'= @balance,
		'Credit' = null,@fromdate,@todate,0,0,@ACCOUNTGROUP     
  		FETCH NEXT FROM scanrootlevel into @groupid,@group
 	END
	CLOSE scanrootlevel
	DEALLOCATE scanrootlevel
	
	select @totaldebit = SUM(ISNULL(Debit,0))from #TempRegister where groupid <> -1
	select @totalcredit = @totalDebit + SUM(ISNULL(Credit,0)) from #tempregister
	
	INSERT #TempRegister
	select Null,'Group Total',null,@totaldebit,@fromdate,@todate,0,0,@NONEXTLEVEL     

--insert null value for empty row
	insert into #tempregister (Groupname,Groupid,fromdate,todate) values 
	('',-2,@fromdate,@todate)
	

	Declare @Maxdate datetime
	Declare @GeneralJournalBal decimal(18,6)

	select @Maxdate = max(openingdate) from accountopeningbalance

	if @Todate > @Maxdate
		Begin
			set @Todate = @Maxdate
		end

-- -- -- 	declare Closingbalance cursor for
-- -- -- 	select accountid,AccountName from #Cash_Bank_IDS 
-- -- -- 
-- -- -- 	open Closingbalance
-- -- -- 
-- -- -- 	fetch from Closingbalance into @accountid , @accountname
-- -- -- 	while @@fetch_status = 0
-- -- -- 		Begin
-- -- -- 			select @openingbalance = openingvalue from accountopeningbalance where 
-- -- -- 			accountid = @accountid and OpeningDate = @todate
-- -- -- 
-- -- -- 			select @GeneralJournalBal = 
-- -- -- 			(select isnull(sum(debit) - sum(credit),0) from generaljournal where 
-- -- -- 			accountid = @accountid and status <> 192
-- -- -- 			and dbo.stripdatefromtime(transactiondate) = @todate
-- -- -- 			and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82))
-- -- -- 
-- -- -- 			set @openingbalance = @openingbalance + @GeneralJournalBal
-- -- -- 
-- -- -- 			update #cash_bank_ids set ClosingValue = @OPENINGBALANCE 
-- -- -- 			where accountid = @accountid
-- -- -- 
-- -- -- 			set @openingbalance = 0
-- -- -- 			set @GeneralJournalBal = 0 
-- -- -- 
-- -- -- 			fetch next from Closingbalance into @accountid		,@accountname	
-- -- -- 		End
-- -- -- 	close Closingbalance
-- -- -- 	Deallocate Closingbalance
-- -- -- 
-- -- -- 	insert into #tempregister (Groupname,Groupid,debit,credit,Fromdate,Todate,colorinfo,Docref,Doctype)
-- -- -- 	select distinct parentgroup , -2, sum(closingvalue),null,@fromdate,@todate,3,-2,-2 from #cash_bank_ids
-- -- -- 	group by parentgroup

	Declare ClosingDetails cursor dynamic for
	Select groupid,Groupname from accountgroup where groupid in (7,18,19) order by groupid
	Open ClosingDetails
	Fetch from ClosingDetails into @Groupid,@Groupname
	While @@Fetch_status = 0
		Begin
			Set @Balance = 0
			Exec sp_acc_rpt_Cashflow_OpeningClosingBalance @Groupid,@Fromdate,@Todate,0,@Balance output

			insert into #tempregister (Groupname,Groupid,debit,credit,Fromdate,Todate,colorinfo,Docref,Doctype)
			select distinct @Groupname,-2,@Balance,null,@fromdate,@todate,3,-2,-2

			Fetch Next from ClosingDetails into @Groupid,@Groupname
		End
	Close ClosingDetails
	Deallocate ClosingDetails

	INSERT #TempRegister
	select -2,'Total Closing Balance',null,sum(Debit),@fromdate,@todate,null,null,@NONEXTLEVEL from #tempregister where 
	Groupid = -2


	--update the grouptotal for the Cash and Bank a/cs

	create Table #MainTable
	(RowNum Integer identity(1,1),
	GroupID integer,GroupName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Debit decimal(18,6),Credit 
	decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,
	DocType integer,ColorInfo integer)

	insert into #MainTable
	select * from #tempregister where groupid = -1

	Update a
	Set a.groupid = b.groupid from
	#MainTable a , Accountgroup b 
	where a.GroupName = B.GroupName and a.groupid = -1
	and b.groupid < 20


	insert into #MainTable (Groupid, GroupName, fromdate,todate,colorinfo)
	values( -1,'Source',@fromdate,@todate,1 )
	
	insert into #MainTable
	select * from #tempregister where groupid not in (-1,-2) and Debit >= 0 and ltrim(rtrim(GroupName)) <> N'Group Total'

	insert into #MainTable (Groupid , GroupName,Debit, fromdate,todate,colorinfo)
	select -1,'Total',Abs(sum(Debit)),@Fromdate,@Todate,1 from #tempregister where groupid not in (-1,-2) and Debit >= 0 and ltrim(rtrim(GroupName)) <> N'Group Total'

	Insert into #mainTable (GroupName, colorinfo) values(Null,1)

	
	insert into #MainTable (Groupid , GroupName, fromdate,todate,colorinfo)
	values( -1,'Application',@fromdate,@todate,1 )
	
	insert into #MainTable
	select * from #tempregister where groupid not in (-1,-2) and Debit < 0 and ltrim(rtrim(GroupName)) <> N'Group Total'

	insert into #MainTable (Groupid , GroupName,Debit, fromdate,todate,colorinfo)
	select -1,'Total',Abs(sum(Debit)),@Fromdate,@Todate,1 from #tempregister 
	where groupid not in (-1,-2) and Debit < 0 and ltrim(rtrim(GroupName)) <> N'Group Total'

	Insert into #mainTable (GroupName, colorinfo) values(Null,1)

	insert into #MainTable
	select * from #tempregister where ltrim(rtrim(GroupName)) = N'Group Total'

	insert into #tempregister (Groupname,colorinfo) values (Null,1)

	insert into #MainTable
	select * from #tempregister where groupid = -2

	Update a
	Set a.groupid = b.groupid from
	#MainTable a , Accountgroup b 
	where a.GroupName = B.GroupName and a.groupid = -2
	and b.groupid < 20

	select 'Account Group'= GroupName,
	'Total'= 
		Case When isnull(Docref,0) in (-1,-2) then
				Case 
					when Debit < 0 then dbo.LookupDictionaryItem('Cr ',Default) + ltrim(rtrim(cast(Abs(Debit) as nvarchar(50)))) 
					Else dbo.LookupDictionaryItem('Dr ',Default) + ltrim(rtrim(cast(Abs(Debit) as nvarchar(50)))) 
				End
			Else ltrim(rtrim(cast(Abs(Debit) as nvarchar(50)))) 
		End,
	'Total Amount'=
	Case 
		When Credit < 0 then dbo.LookupDictionaryItem('Cr ',Default) + ltrim(rtrim(cast(Abs(Credit) as nvarchar(50))))
		Else dbo.LookupDictionaryItem('Dr ',Default) + ltrim(rtrim(cast(Abs(Credit) as nvarchar(50))))
	End,
	'', 'GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,fromdate,todate,DocRef,DocType,ColorInfo,ColorInfo 
	from #Maintable order by rownum


	Drop Table #Tempregister
	Drop Table #MainTable






















