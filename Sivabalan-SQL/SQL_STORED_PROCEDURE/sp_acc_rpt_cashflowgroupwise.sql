CREATE PROCEDURE sp_acc_rpt_cashflowgroupwise(@fromdate datetime,@todate datetime ,@parentid  integer,@docref integer,@doctype integer,@mode integer,@Info nvarchar(500) = Null,@State Int=0,@Hide0BalAC Int =0)
 as          
 DECLARE @debit decimal(18,6),@credit decimal(18,6),@account nvarchar(30),@group nvarchar(50)          
 DECLARE @totaldebit decimal(18,6),@totalcredit decimal(18,6)          
 DECLARE @parentgroup1 integer,@groupid integer,@parentgroup  integer          
 DECLARE @balance decimal(18,6),@TotalDepAmt Decimal(18,6)          

           
 DECLARE @LEAFACCOUNT integer          
 DECLARE @ACCOUNTGROUP integer          
 DECLARE @NEXTLEVEL integer          
 DECLARE @NONEXTLEVEL integer          
         
 DECLARE @ToDatePair datetime        
 Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))        
        
 SET @NEXTLEVEL =0          
 SET @NONEXTLEVEL =1          
 SET @LEAFACCOUNT =2          
 SET @ACCOUNTGROUP =3          
           
 Declare @TranID1 Int,@Debit1 Decimal(18,6),@Credit1 Decimal(18,6)          
 Declare @TotalDebit1 Decimal(18,6),@TotalCredit1 Decimal(18,6)      

 DECLARE @GROUPNAME nVARCHAR(500)  
 CREATE TABLE #CASHGROUP  
 (   
  GROUPNAME nVARCHAR(500),GROUPID NUMERIC(18,0),PARENTGROUP nVARCHAR(500)  
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
  OpeningValue decimal(18,6),  
  ClosingValue decimal(18,6),  
 )   
  

 insert into #Cash_Bank_IDS  
 SELECT Accountid,accountname,groupid,null,0,0,0 FROM ACCOUNTSMASTER WHERE GROUPID in (select groupid from #CASHGROUP)  
  
--for cash closing balance drill down 
 if @mode = @accountgroup and @docref = -1 and @Doctype  = -1
	Begin
-- -- -- 		Create Table #ParentGroups
-- -- -- 		(
-- -- -- 			GroupIds numeric(18),GroupName Varchar(500)
-- -- -- 		)

-- -- -- 		Create Table #OpeningBalance
-- -- -- 		(
-- -- -- 			AccountId Numeric(9),
-- -- -- 			openingvalue	numeric(18,2),
-- -- -- 		)
-- -- -- 
-- -- -- 		Create Table #AcctGroupIds
-- -- -- 		(
-- -- -- 			Groupids Numeric(9)
-- -- -- 		)

		Declare @TempGroupId Numeric(9)
		Declare @GroupBalance decimal(18,6)

		create Table #TempRegisterOPBal 
		(GroupID integer,GroupName nvarchar(255),Debit decimal(18,6),
		Credit decimal(18,6),FromDate datetime,ToDate datetime,
		DocRef integer,DocType integer,ColorInfo integer)            

 		DECLARE ScanParent CURSOR Dynamic FOR            
		select [GroupID],[GroupName]  from Accountgroup where Parentgroup = @Parentid 
		and [GroupID] not in (55,500)  --Closing Stock,User AccountGroup Start            
		Open ScanParent

		Fetch from ScanParent into @groupid , @groupName
		While @@Fetch_status = 0
			Begin
				
				Exec sp_acc_rpt_Cashflow_OpeningClosingBalance @groupid,@Fromdate,@Todate,1,@Balance output				
				insert into #TempRegisterOPBal 
				select @groupid,@groupName,
				'Debit'= case when @Balance >= 0 then  @Balance else '0' End,
				'Credit'=case when @Balance < 0 then  abs(@Balance) else '0' End,
				@FromDate,@todate,-1,-1,@accountgroup

				Fetch Next from ScanParent into @groupid , @groupName
			End
		Close ScanParent
		Deallocate ScanParent

		--insert the accountids for the group into temp table and update the opening balance

 		DECLARE ScanAccounts CURSOR Dynamic FOR            
		select AccountID,AccountName from AccountsMaster where [GroupID]= @parentid
		and [GroupID] not in (55,500)  --Closing Stock,User AccountGroup Start            
		Open ScanAccounts

		Fetch from ScanAccounts into @groupid , @groupName
		While @@Fetch_status = 0
			Begin
			    If Not exists(Select top 1 openingvalue from AccountOpeningBalance where 
					OpeningDate=@fromdate and AccountID = @groupid)          
				    Begin          
				     	Select @Balance= isNull(Sum(OpeningBalance),0) from 
						AccountsMaster where AccountId = @groupid --and isnull(Active,0)=1          
				    End          
			    Else          
			    	Begin           
			     		set @Balance = isnull((Select Sum(OpeningValue) from 
						AccountOpeningBalance where OpeningDate=@Fromdate and
						AccountID = @groupid),0)          
			    	End          

				insert into #TempRegisterOPBal 
				select @groupid,@groupName,
				'Debit'= case when @Balance >= 0 then  @Balance else '0' End,
				'Credit'=case when @Balance < 0 then  abs(@Balance) else '0' End,
				@FromDate,@todate,-1,-1,5
				Fetch Next from ScanAccounts into @groupid , @groupName
			End
			Close ScanAccounts
			Deallocate ScanAccounts

  select @totaldebit = SUM(ISNULL(Debit,0)),@totalcredit = SUM(ISNULL(Credit,0)) from #TempRegisterOPBal              

		insert into #TempRegisterOPBal (GroupName,Debit,Credit,Colorinfo)
		select dbo.lookupdictionaryitem('Total',Default),Sum(isnull(debit,0)),Sum(isnull(credit,0)),1 from #TempRegisterOPBal 

		insert into #TempRegisterOPBal (GroupName,Debit,Credit,Colorinfo)
  Select dbo.lookupdictionaryitem('Closing Balance',Default),Case When (IsNULL(@totaldebit,0)-IsNULL(@totalcredit,0)) > 0 
  Then (IsNULL(@totaldebit,0)-IsNULL(@totalcredit,0)) Else 0 End,Case When (IsNULL(@totaldebit,0)-IsNULL(@totalcredit,0)) < 0 
  Then ABS(IsNULL(@totaldebit,0)-IsNULL(@totalcredit,0)) Else 0 End,1

 	If @Hide0BalAC = 0
 	Begin
			select 'Account/Group'= GroupName,'Debit'=isnull(Debit,0),'Credit'=isnull(Credit,0),'',
			'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,            
			@fromdate,@todate,DocRef,DocType,ColorInfo,ColorInfo from #TempRegisterOPBal --to match parameters column, extra colorinfo column added            
		End
		Else
		Begin
			select 'Account/Group'= GroupName,'Debit'=isnull(Debit,0),'Credit'=isnull(Credit,0),'',
			'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,            
			@fromdate,@todate,DocRef,DocType,ColorInfo,ColorInfo from #TempRegisterOPBal
			where ((Isnull(Debit,0) + Isnull(Credit,0)) > 0 or isnull(colorinfo,0) in (1,3))
		End
		Drop Table #TempRegisterOPBal 

	End
 IF @mode = @ACCOUNTGROUP and @docref = -2 and @doctype = -2
	Begin
		create Table #TempRegisterClBal
		(GroupName nvarchar(255),Debit decimal(18,6),Credit decimal(18,6),TBType nVarchar(10),
		GroupID integer,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,
		ColorInfo1 integer,ColorInfo2 integer)

		insert into #TempRegisterClBal
		exec sp_acc_rpt_trialbalancegroupwise @fromdate,@todate,@parentid,'0',0,0,@mode

	  	If @Hide0BalAC = 0
	  	Begin
		  	select 'Account/Group'= GroupName,'Debit'=isnull(Debit,0),'Credit'=isnull(Credit,0),'',             
		  	'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,            
		  	@fromdate,@todate,-2,-2,colorinfo1,colorinfo1
			from #TempRegisterClBal --to match parameters column, extra colorinfo column added            
		End
		Else
		Begin
		  	select 'Account/Group'= GroupName,'Debit'=isnull(Debit,0),'Credit'=isnull(Credit,0),'',             
		  	'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,            
		  	@fromdate,@todate,-2,-2,colorinfo1,colorinfo1
			from #TempRegisterClBal
			Where ((Isnull(Debit,0) + Isnull(Credit,0)) > 0 or isnull(colorinfo1,0) in (1,3))
		End		
		Drop table #TempRegisterClBal
	End

 IF @mode = @ACCOUNTGROUP and @docref not in (-1 , -2) and @doctype not in (-1 , -2) 
 BEGIN          
  create Table #TempRegister(GroupID integer,GroupName nvarchar(255),Debit decimal(18,6),Credit decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)                     
  set @parentgroup1 = @parentid          
	--Eliminate Cash and Bank A/C  for Cash flow statement
DECLARE ScanrootGroupLevel CURSOR KEYSET FOR   
select [GroupID],[GroupName]  from [AccountGroup] where [ParentGroup]= @parentgroup1 and [GroupID] not in (55,500,18,19) --Closing Stock,User AccountGroup Start            
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
	            
	  INSERT #TempRegister          
	  select '',dbo.lookupdictionaryitem('Total',Default),@totaldebit,@totalcredit,@fromdate,@todate,0,0,@NONEXTLEVEL          

	  INSERT #TempRegister              
	  Select '',dbo.lookupdictionaryitem('Closing Balance',Default),Case When (IsNULL(@totaldebit,0)-IsNULL(@totalcredit,0)) > 0 
	  Then (IsNULL(@totaldebit,0)-IsNULL(@totalcredit,0)) Else 0 End,Case When (IsNULL(@totaldebit,0)-IsNULL(@totalcredit,0)) < 0 
	  Then ABS(IsNULL(@totaldebit,0)-IsNULL(@totalcredit,0)) Else 0 End,@fromdate,@todate,0,0,@NONEXTLEVEL              
	            
	  If @Hide0BalAC = 0
	  Begin
		  select 'Account/Group'= GroupName,'Debit'=Debit,'Credit'=Credit,'',           
		  'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,          
		  @fromdate,@todate,DocRef,DocType,ColorInfo,ColorInfo from #TempRegister --to match parameters column, extra colorinfo column added          
	  End
	  Else
	  Begin
		  select 'Account/Group'= GroupName,'Debit'=Debit,'Credit'=Credit,'',
		  'AccountID/GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,
		  @fromdate,@todate,DocRef,DocType,ColorInfo,ColorInfo from #TempRegister
		  Where ((Isnull(Debit,0) + Isnull(Credit,0)) > 0 or isnull(colorinfo,0) in (1,3))
	  End
	  Drop table #TempRegister          
	 END          
 ELSE IF @mode=@LEAFACCOUNT 
	if @doctype = -2 and @docref = -2 
		Begin
			--for closing balance drill down till ledger level
		    exec sp_acc_rpt_account @fromdate,@todate,@parentid,@State    
		End
	Else
		Begin
		    exec sp_acc_rpt_cashflowaccount @parentid,@fromdate,@todate,@State    
		End
 ELSE IF @mode =@NEXTLEVEL and @docref not in (-1 , -2) and @doctype not in (-1 , -2) 
	 BEGIN          
	    exec sp_acc_rpt_accountdetail @docref,@doctype,@Info          
	 END   








