CREATE PROCEDURE sp_acc_prn_FACashflowDrilldownCount(@fromdate datetime,@todate datetime ,@parentid  integer,
@docref integer,@doctype integer,@mode integer,@Info nvarchar(500) = Null,@State Int=0,
@Hide0BalAC Int =0)
 as          
 DECLARE @debit decimal(18,6),@credit decimal(18,6),@account nvarchar(30),@group nvarchar(50)          
 DECLARE @totaldebit decimal(18,6),@totalcredit decimal(18,6)          
 DECLARE @parentgroup1 integer,@groupid integer,@parentgroup  integer          
 DECLARE @balance decimal(18,6),@TotalDepAmt Decimal(18,6)          

           
 DECLARE @LEAFACCOUNT integer          
 DECLARE @ACCOUNTGROUP integer          
 DECLARE @NEXTLEVEL integer 
         
 SET @NEXTLEVEL =0          
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
  
  create Table #TempRegister(GroupID integer,GroupName nvarchar(255),Debit decimal(18,6),Credit decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)                     
  set @parentgroup1 = @parentid          

if @mode = @accountgroup
Begin
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
	  select count(*) from #TempRegister
	End
	Else
	Begin
	  select count(*) from #TempRegister where ((Isnull(Debit,0) + Isnull(Credit,0)) > 0 or isnull(colorinfo,0) in (1,3))
	End		
	Drop table #TempRegister          
End
ELSE IF @mode=@LEAFACCOUNT 
Begin
	if @doctype = -2 and @docref = -2 
		Begin
			Create Table #LeafAccount1 
			(DocDate Datetime,TransactionID nvarchar(50),DocumentReference nvarchar(50),
			Descp nvarchar(500),AccountID Int,Fromdate Datetime,Todate Datetime,           
			DocRef nvarchar(50),DocType nvarchar(50),ColorInfoParam Int,Particular nvarchar(255),
			Debit decimal(18,6),Credit decimal(18,6),Balance nVarChar(50),DocumentBalance nVarChar(50),
			Narration nvarchar(2000),ChequeInfo nvarchar(255),HighLight Int)
			Insert into #LeafAccount1
		    exec sp_acc_rpt_account @fromdate,@todate,@parentid,@State    
			Select count(*) from #LeafAccount1
			Drop Table #LeafAccount1
		End
	Else
		Begin
			Create Table #LeafAccount2
			(DocDate datetime,TransactionID nvarchar(15),
			Descp nVarchar(50),Particular nvarchar(50),
			AccountID int,Fromdate datetime,Todate datetime,          
			DocRef Int,DocType Int,ColorInfoParam Int,Particulars nvarchar(50),          
			Debit decimal(18,6),Credit decimal(18,6),dummyField nvarchar(10),HighLight Int)
			
			Insert into #LeafAccount2
		    exec sp_acc_rpt_cashflowaccount @parentid,@fromdate,@todate,@State    
			Select count(*) from #LeafAccount2
			Drop table #LeafAccount2
		End
End
ELSE IF @mode =@NEXTLEVEL and @docref not in (-1 , -2) and @doctype not in (-1 , -2) 
Begin
	Exec sp_acc_prn_Ledger_GetdrillCount @docref,@doctype
End


