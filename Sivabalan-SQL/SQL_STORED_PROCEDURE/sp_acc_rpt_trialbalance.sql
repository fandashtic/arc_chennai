CREATE procedure sp_acc_rpt_trialbalance(@fromdate datetime,@todate datetime,@TBType nvarchar(50) = null)    
 as    
 DECLARE @debit decimal(18,6),@credit decimal(18,6),@account nvarchar(30),@group nvarchar(50)    
 DECLARE @accountid integer,@groupid integer,@totaldebit decimal(18,6),@totalcredit decimal(18,6)    
 DECLARE @parentid integer,@parentgroup integer     
 DECLARE @balance decimal(18,6),@TotalDepAmt Decimal(18,6)    
 DECLARE @LEAFACCOUNT integer    
 DECLARE @ACCOUNTGROUP integer    
 DECLARE @NONEXTLEVEL integer    
     
 SET @LEAFACCOUNT =2    
 SET @ACCOUNTGROUP =3    
 SET @NONEXTLEVEL =1    
      
     
 set @parentgroup = 0    
     
 create Table #TempRegister(GroupID integer,GroupName nvarchar(255),Debit decimal(18,6),Credit     
 decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)    

 DECLARE scanrootlevel CURSOR KEYSET FOR    
 select [GroupID],[GroupName]  from [AccountGroup] where [ParentGroup]=@parentgroup    
 and isnull(GroupID,0)<>500    
    
 OPEN scanrootlevel    
     
 FETCH FROM scanrootlevel into @groupid,@group    
     
 WHILE @@FETCH_STATUS =0    
 BEGIN    
   
	execute sp_acc_rpt_trialrecursivebalance @groupid,@fromdate,@todate,@balance output,@TotalDepAmt output , @TBType  
-- -- 	if @TBType <> 1 
-- -- 		Begin
--Set @Balance=0 
-- -- 		End
-- -- 	Else if @TBType = 1
-- -- 		Begin
-- -- 		 	Set @Balance=0    
-- -- 		    execute sp_acc_rpt_trialrecursivebalance_without_op @groupid,@fromdate,@todate,@balance output,@TotalDepAmt output , @TBType  
-- -- 		End  
    If @TotalDepAmt=0
	  Begin          
	       INSERT INTO #TempRegister    
	       SELECT 'GroupID'= @groupid,'GroupName'=@group,'Debit'= CASE WHEN ((@balance)> 0) then     
	       @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP         
	  End    
	  Else    
	  Begin    
	       INSERT INTO #TempRegister    
	       SELECT 'GroupID'= @groupid,'GroupName'=@group + dbo.LookupDictionaryItem(' less depreciation value ',Default) + cast(@TotalDepAmt as nvarchar(50)),'Debit'= CASE WHEN ((@balance)> 0) then     
	       @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP         
	  End    
    

    FETCH NEXT FROM scanrootlevel into @groupid,@group    
  END    
 CLOSE scanrootlevel    
 DEALLOCATE scanrootlevel    
     
 select @totaldebit = SUM(ISNULL(Debit,0)),@totalcredit = SUM(ISNULL(Credit,0)) from #TempRegister    
     
 INSERT #TempRegister    
 select Null,'Total',@totaldebit,@totalcredit,@fromdate,@todate,0,0,@NONEXTLEVEL         
     
 select   
'Account Group'= GroupName,  
'Debit'=Debit,  
'Credit'=Credit,  
@TBType,   
'GroupID'= CASE WHEN GroupID = 0 then '' else GroupID end,  
@fromdate,  
@todate,  
DocRef,  
DocType,  
ColorInfo,  
ColorInfo from #TempRegister     
  
Drop table #TempRegister    











