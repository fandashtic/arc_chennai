CREATE PROCEDURE sp_acc_prn_FACashflowDrilldownRecords(@fromdate datetime,@todate datetime ,@parentid  integer,@Doctype integer,@Hide0BalAC Int =0)
 as          
 DECLARE @debit decimal(18,6),@credit decimal(18,6),@account nvarchar(30),@group nvarchar(50)          
 DECLARE @totaldebit decimal(18,6),@totalcredit decimal(18,6)          
 DECLARE @parentgroup1 integer,@groupid integer,@parentgroup  integer          
 DECLARE @balance decimal(18,6),@TotalDepAmt Decimal(18,6)          

           
 DECLARE @LEAFACCOUNT integer          
 DECLARE @ACCOUNTGROUP integer          
         
 SET @LEAFACCOUNT =2          
 SET @ACCOUNTGROUP =3          

 DECLARE @ToDatePair datetime        
 Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))        
        
           
 Declare @TranID1 Int,@Debit1 Decimal(18,6),@Credit1 Decimal(18,6)          
 Declare @TotalDebit1 Decimal(18,6),@TotalCredit1 Decimal(18,6)      

 DECLARE @GROUPNAME nVARCHAR(4000)  
 CREATE TABLE #CASHGROUP  
 (   
  GROUPNAME nVARCHAR(4000),GROUPID NUMERIC(18,0),PARENTGROUP nVARCHAR(4000)  
 )   
  
 INSERT INTO #CASHGROUP  
 SELECT GROUPNAME,GROUPID,GROUPNAME FROM ACCOUNTGROUP WHERE GROUPID in (7,18,19)-- (19,18)-- (7)--,18)  
  
  
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
  
 create table #Cash_Bank_IDS  
 (  
  Accountid numeric(18),  
  AccountName nvarchar(500),  
  Groupid  numeric(18),  
  ParentGroup nvarchar(500),  
  Status  numeric(9),  
  OpeningValue numeric(18,2),  
  ClosingValue numeric(18,2),  
 )   
  

 insert into #Cash_Bank_IDS  
 SELECT Accountid,accountname,groupid,null,0,0,0 FROM ACCOUNTSMASTER WHERE GROUPID in (select groupid from #CASHGROUP)  

 if @Doctype  = -1
	Begin
		Create Table #ParentGroups
		(
			GroupIds numeric(18),GroupName nVarchar(500)
		)

		Create Table #OpeningBalance
		(
			AccountId Numeric(9),
			openingvalue	numeric(18,2),
		)

		create Table #TempRegisterOPBal 
		(GroupID integer,GroupName nvarchar(255),Debit decimal(18,6),
		Credit decimal(18,6),FromDate datetime,ToDate datetime,
		DocRef integer,DocType integer,ColorInfo integer)            

		Declare @TempGroupId Numeric(9)
		Declare @GroupBalance numeric(18,2)

		Create Table #AcctGroupIds
		(
			Groupids Numeric(9)
		)

 		DECLARE ScanParent CURSOR Dynamic FOR            
		select [GroupID],[GroupName]  from Accountgroup where Parentgroup = @Parentid 
		and [GroupID] not in (55,500)  --Closing Stock,User AccountGroup Start            
		Open ScanParent

		Fetch from ScanParent into @groupid , @groupName
		While @@Fetch_status = 0
			Begin
				Insert into #TempRegisterOPBal (Groupid,GroupName)
				VAlues(@groupid , @groupName)

				Truncate table #AcctGroupIds

				Insert into #AcctGroupIds values(@groupid)
			
				Declare ScanAccGroups Cursor Dynamic for
				Select Groupids from #acctGroupids

				Open ScanAccGroups

				Fetch from ScanAccGroups into @TempGroupId
					While @@Fetch_status = 0
						Begin
							Insert into #AcctGroupIds 
							Select Groupid from Accountgroup where parentgroup = @tempgroupid

							Fetch Next from ScanAccGroups into @TempGroupId
						End
				Close 		ScanAccGroups
				Deallocate 	ScanAccGroups
			
				Insert into #OpeningBalance (AccountId)
				Select accountid from accountsmaster where accountid in 
				(select Groupids from #AcctGroupIds )

				update a set a.openingvalue = isnull(b.openingvalue,0)
				from #OpeningBalance a, accountopeningbalance b
				where a.accountid = b.accountid and b.openingdate = @fromdate
			
				--if opening values is still 0 then try from accountsmaster
				update a set a.openingvalue = isnull(b.OpeningBalance,0)
				from #OpeningBalance a, AccountsMaster b
				where a.accountid = b.accountid and a.openingvalue = 0

				set @GroupBalance = (Select Sum(openingvalue) from #OpeningBalance)
				if @GroupBalance < 0 
					Begin
						Update #TempRegisterOPBal 
						set Credit = @groupbalance ,Docref = '-1',Doctype = '-1', Colorinfo = @accountgroup
						Where Groupid = @groupid
					End
				Else
					Begin
						Update #TempRegisterOPBal 
						set Debit = @groupbalance ,Docref = '-1',Doctype = '-1', Colorinfo = @accountgroup
						Where Groupid = @groupid
					End
			
				Fetch Next from ScanParent into @groupid , @groupName
			End
		Close ScanParent
		Deallocate ScanParent
		--insert the accountids for the group into temp table and update the opening balance

		Insert into #OpeningBalance (Accountid)
		Select Accountid from Accountsmaster where Groupid = @Parentid
		
		--update the opening balance from opening details table of accountsmaster table 
		update a set a.openingvalue = isnull(b.openingvalue,0)
		from #OpeningBalance a, accountopeningbalance b
		where a.accountid = b.accountid and b.openingdate = @fromdate
	
		--if opening values is still 0 then try from accountsmaster
		update a set a.openingvalue = isnull(b.OpeningBalance,0)
		from #OpeningBalance a, AccountsMaster b
		where a.accountid = b.accountid and a.openingvalue = 0

		insert into #TempRegisterOPBal 
		select a.Accountid,b.Accountname,
		'Debit'= case when a.Openingvalue >= 0 then  a.Openingvalue else '0' End,
		'Credit'=case when a.Openingvalue < 0 then  abs(a.Openingvalue) else '0' End,
		@FromDate,@todate,-2,-2,5 from #OpeningBalance a,Accountsmaster b
		where a.accountid = b.accountid

	  	If @Hide0BalAC = 0
	  	Begin
		  	select 'Account/Group'= GroupName,'Total'= isnull(Debit,0) - isnull(Credit,0) 
		  	from #TempRegisterOPBal
		End
		Else
		Begin
		  	select 'Account/Group'= GroupName,'Total'= isnull(Debit,0) - isnull(Credit,0) 
		  	from #TempRegisterOPBal
			where ((Isnull(Debit,0) + Isnull(Credit,0)) > 0 or isnull(colorinfo,0) in (1,3))
		End
		Drop table #TempRegisterOPBal

	End
 IF @doctype = -2
	Begin
		create Table #TempRegisterClBal
		(GroupName nvarchar(255),Debit decimal(18,6),Credit decimal(18,6),TBType nVarchar(10),
		GroupID integer,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,
		ColorInfo1 integer,ColorInfo2 integer)

		insert into #TempRegisterClBal
		exec sp_acc_rpt_trialbalancegroupwise @fromdate,@todate,@parentid,'0',0,0,3

	  	If @Hide0BalAC = 0
	  	Begin
	  		select 'Account/Group'= GroupName,'Total'= isnull(Debit,0) - isnull(Credit,0) 
	 		from #TempRegisterClBal
		End
		Else
		Begin
	  		select 'Account/Group'= GroupName,'Total'= isnull(Debit,0) - isnull(Credit,0) 
	 		from #TempRegisterClBal Where ((Isnull(Debit,0) + Isnull(Credit,0)) > 0 or isnull(colorinfo1,0) in (1,3))
		End

	  	Drop table #TempRegisterClBal

	End


if @doctype not in (-1,-2)
Begin  
	create Table #TempRegister(GroupID integer,GroupName nvarchar(255),Debit decimal(18,6),Credit decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)                     
	set @parentgroup1 = @parentid          


	DECLARE ScanrootGroupLevel CURSOR KEYSET FOR          
	select [GroupID],[GroupName]  from [AccountGroup] where [ParentGroup]= @parentgroup1 and [GroupID] not in (55,500) --Closing Stock,User AccountGroup Start            
	OPEN ScanrootGroupLevel          
            
	  FETCH FROM ScanrootGroupLevel into @groupid,@group          
	            
	  WHILE @@FETCH_STATUS =0          
		   BEGIN        
				execute sp_acc_rpt_cashflowrecursivebalance @groupid,@fromdate,@todate,@balance output
			    INSERT INTO #TempRegister          
			    SELECT 'GroupID'= @groupid,'GroupName'=@group,'Debit'= CASE WHEN ((@balance)> 0) then   
			    @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP               
		    	FETCH NEXT FROM ScanrootGroupLevel into @groupid,@group          
		   END          
	CLOSE ScanrootGroupLevel
	DEALLOCATE ScanrootGroupLevel          
           
--from accountsmaster if any
	DECLARE ScanrootAcctLevel CURSOR KEYSET FOR          
	select AccountID,AccountName  from [Accountsmaster] where [GroupID]= @parentid  and [GroupID] not in (55,500) --Closing Stock,User AccountGroup Start          
	OPEN ScanrootAcctLevel
            
	FETCH FROM ScanrootAcctLevel into @groupid,@group          
	            
	  WHILE @@FETCH_STATUS =0          
		   BEGIN        
				execute sp_acc_rpt_cashflowrecursivebalance @groupid,@fromdate,@todate,@balance output,1
			    INSERT INTO #TempRegister          
			    SELECT 'GroupID'= @groupid,'GroupName'=@group,'Debit'= CASE WHEN ((@balance)> 0) then   
			    @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@LEAFACCOUNT
		    	FETCH NEXT FROM ScanrootAcctLevel into @groupid,@group          
		   END          
	  CLOSE ScanrootAcctLevel
	  DEALLOCATE ScanrootAcctLevel
	


	  Declare @AccountID Int,@AccountName nvarchar(50),@LastBalance decimal(18,6)          
	  Declare @DepPercent Decimal(18,6), @DepAmount Decimal(18,6), @OpeningBalance Decimal(18,6)          
	          
	  select @totaldebit = SUM(ISNULL(Debit,0)),@totalcredit = SUM(ISNULL(Credit,0)) from #TempRegister          
	            
	  If @Hide0BalAC = 0
	  Begin
		  select 'Account/Group'= GroupName,'Total'= isnull(Debit,0) - isnull(Credit,0) 
		  from #TempRegister 
	  End
	  Else
	  Begin
		  select 'Account/Group'= GroupName,'Total'= isnull(Debit,0) - isnull(Credit,0) 
		  from #TempRegister Where ((Isnull(Debit,0) + Isnull(Credit,0)) > 0 or isnull(colorinfo,0) in (1,3))
	  End
	  Drop table #TempRegister          
End




