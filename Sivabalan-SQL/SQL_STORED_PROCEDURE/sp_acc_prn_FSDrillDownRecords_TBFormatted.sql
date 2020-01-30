CREATE procedure sp_acc_prn_FSDrillDownRecords_TBFormatted (@fromdate datetime,@todate datetime ,@parentid  integer,@ReportHeader nVarchar(255) = Null,@TBType nvarchar(50) = null,@Hide0BalAC Int =0)
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

if isnumeric(@TBType) = 0
begin
	set @TBType = 0
end

if cast(@TBType as numeric) = 1
	begin
		-- set @todate = dateadd(dd,-1,@todate)
		 set @todate = @todate
	end
-- -- -- -- -- else if @tbtype = 2
-- -- -- -- -- 	begin
-- -- -- -- -- 		set @fromdate = @todate
-- -- -- -- -- 	end  


 Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))        



        
 SET @NEXTLEVEL =0          
 SET @NONEXTLEVEL =1          
 SET @LEAFACCOUNT =2          
 SET @ACCOUNTGROUP =3          
           
 Declare @TranID1 Int,@Debit1 Decimal(18,6),@Credit1 Decimal(18,6)          
 Declare @TotalDebit1 Decimal(18,6),@TotalCredit1 Decimal(18,6)          


-- IF @mode = @ACCOUNTGROUP           
-- BEGIN          

  set @parentgroup1 = @parentid          
            
  create Table #TempRegister(GroupID integer,GroupName nvarchar(255),Debit decimal(18,6),Credit decimal(18,6),FromDate datetime,ToDate datetime,DocRef integer,DocType integer,ColorInfo integer)          
            
  DECLARE scanrootlevel CURSOR KEYSET FOR          
--  select [GroupID],[GroupName]  from [AccountGroup] where [ParentGroup]=@parentgroup1 and [GroupID]<> 21 -- stock in trade =21          
  select [GroupID],[GroupName]  from [AccountGroup] where [ParentGroup]=@parentgroup1 and [GroupID] not in (55,500) --Closing Stock,User AccountGroup Start          
            
  OPEN scanrootlevel          
            
  FETCH FROM scanrootlevel into @groupid,@group          
            
  WHILE @@FETCH_STATUS =0          
   BEGIN        

      execute sp_acc_rpt_trialrecursivebalance @groupid,@fromdate,@todate,@balance output,@TotalDepAmt output,@TBType          
      If @TotalDepAmt=0          
      begin 
		/* for TBType = 2 Drilldown is not allowed after 1 levels */            
		if @TBType <> 2
			Begin
		       INSERT INTO #TempRegister          
		       SELECT 'GroupID'= @groupid,'GroupName'=@group,'Debit'= CASE WHEN ((@balance)> 0) then           
		       @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP               
			End
		Else
			Begin
		       INSERT INTO #TempRegister          
		       SELECT 'GroupID'= @groupid,'GroupName'=@group,'Debit'= CASE WHEN ((@balance)> 0) then           
		       @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,'5'               
			End
      end           
      else          
      begin          
		if @TBType <> 2
			Begin
		       INSERT INTO #TempRegister          
		       SELECT 'GroupID'= @groupid,'GroupName'=@group + dbo.LookupDictionaryItem(' less depreciation value ',Default)  + cast(@TotalDepAmt as nvarchar(50)),'Debit'= CASE WHEN ((@balance)> 0) then           
		       @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,@ACCOUNTGROUP               
			End
		Else
			Begin
		       INSERT INTO #TempRegister          
		       SELECT 'GroupID'= @groupid,'GroupName'=@group + dbo.LookupDictionaryItem(' less depreciation value ',Default)  + cast(@TotalDepAmt as nvarchar(50)),'Debit'= CASE WHEN ((@balance)> 0) then           
		       @balance else 0 end,'Credit'= CASE WHEN ((@balance)< 0) then abs(@balance) else 0 end,@fromdate,@todate,0,0,'5'
			End
          
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
  --Select @StrDate=  '1/' + Cast(IsNull(FiscalYear,4) as varchar) + '/' + Cast(Year(OpeningDate) As Varchar(50)) From Setup          
  Set @StrDate = dbo.sp_acc_getfiscalyearstart()          
  Set @CheckDate =Cast(@StrDate As DateTime)          
  set @CheckDate = DateAdd(m, 6, @CheckDate)          
  set @CheckDate = DateAdd(s, 0-1, @CheckDate)          

          
  DECLARE scantrialbalanceaccounts CURSOR KEYSET FOR          
  select AccountID,AccountName from AccountsMaster where [GroupID]= @parentid           
  and AccountID not in (@CLOSINGSTOCK,@TAXONCLOSINGSTOCK,500)  --and isnull(Active,0)=1          
  OPEN scantrialbalanceaccounts          
  FETCH FROM scantrialbalanceaccounts into @AccountID,@AccountName          
  WHILE @@FETCH_STATUS=0          
  Begin          

   If @AccountID=@DEPRECIATION          
   Begin          
		if @TBType = 1
			Begin
				execute sp_acc_rpt_depreciationComputation_TB @fromdate,@toDate,@FIXEDASSETS,@balance output          
			End
		Else if @TBType = 2 
			Begin
		/* even if the todate is Opening Date , get the Dep Calculated coz, it is made 0 
			outside the condition
		*/
				Declare @Tempdate datetime
				Set @Tempdate = dateadd(dd,0-1,@ToDate)
			    execute sp_acc_rpt_depreciationComputation @Tempdate,@FIXEDASSETS,@balance output          	
			End
		Else
			Begin
			    execute sp_acc_rpt_depreciationComputation @ToDate,@FIXEDASSETS,@balance output          	
			End
  /* if from date and to date are same Depreciations shud not be calculated, 
	coz the carried fwd amt will have the dep value deducted 
  */
		if @fromdate = @todate and @TBType = 2
			Begin
				set @balance = 0
			End  
	
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
		if @TBType = 1
			Begin
				Set @OpeningBalance=0
			End
	    INSERT #TempRegister          
	    select 'Group ID'= @AccountID,'Group Name'= @AccountName ,          
	    'Debit'= @OpeningBalance,'Credit' = 0,          
	    @fromdate,@todate,0,0,@LEAFACCOUNT           
   End          
   Else if @AccountID=@TAXONOPENINGSTOCK          
   Begin          
	    Select @OpeningBalance=Sum(Case When (IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0)) <> 0 Then           
	    (IsNull(Opening_Value,0) * IsNull(TaxSuffered_Value,0))/100 Else 0 End) from OpeningDetails where Opening_Date=@FromDate          
	    Set @OpeningBalance=isnull(@OpeningBalance,0)          
		if @TBType = 1
			Begin
				Set @OpeningBalance = 0
			End
	    INSERT #TempRegister          
	    select 'Group ID'= @AccountID,'Group Name'= @AccountName ,          
	    'Debit'= @OpeningBalance,'Credit' = 0,          
	    @fromdate,@todate,0,0,@LEAFACCOUNT           
   End          
          
   Else          
   Begin          

    If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@todate and AccountID =@AccountID)          
    Begin          
     Select @LastBalance= isNull(Sum(OpeningBalance),0) from AccountsMaster where AccountId =@AccountID --and isnull(Active,0)=1          
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
		if @TBType = 0
			Begin 
			     Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
			     from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 and AccountID=@AccountID          
			     set @DepAmount=IsNull(@DepAPVBalanceAmt,0)          
			     Set @Balance=IsNull(@APVBalanceAmt,0)          
			
			     Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
			     from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and APVAbstract.APVDate <= @ToDatePair and IsNull(Saleable,0)=1 and AccountID=@AccountID          
			     set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)          
			     Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)          
			
			     Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
			     from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID and ARVAbstract.ARVDate > @ToDatePair and AccountID=@AccountID          
			     set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)          
			     Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)          
			
			     Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
			     from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and          
			     Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID          
			     And ((Select APVDate from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) <= @ToDatePair And ARVAbstract.ARVDate > @ToDatePair)          
			     set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)          
			     Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)          

			     Set @balance=IsNull(@balance,0) - IsNull(@DepAmount,0)          
			     INSERT #TempRegister          
			     select 'Group ID'= @AccountID,'Group Name'= @AccountName + dbo.LookupDictionaryItem(' less depreciation value ',Default)  + cast(@DepAmount as nvarchar(50)),          
			     'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,          
			     'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,          
			     @fromdate,@todate,0,0,@LEAFACCOUNT           
			End
		Else if @TBType = 1
			Begin
				 set @DepAmount = 0
				 Set @Balance = 0

			     Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
			     from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and 
				 APVAbstract.APVDate between @fromdate and @ToDatePair and IsNull(Saleable,0)=1 and AccountID=@AccountID          
				 and isnull(Batch_assets.apvid,0) <> 0

			     set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)          
			     Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)          
			
			     Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))          
			     from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and          
			     Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID          
			     And (((Select APVDate from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) between @fromdate and @ToDatePair ) And ARVAbstract.ARVDate > @ToDatePair)          
			     set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)          
			     Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)          

				 if @fromdate = @todate
					begin
						set @depamount = 0
					end  
				Set @Balance = 0

				set @balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal           
			    Where [TransactionDate] between @Fromdate and @ToDatePair and [AccountID] = @AccountID and         
			    documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128 and isnull(status,0) <> 192),0)          

			     Set @balance=IsNull(@balance,0) - IsNull(@DepAmount,0)         
 
			     INSERT #TempRegister          
			     select 'Group ID'= @AccountID,'Group Name'= @AccountName + dbo.LookupDictionaryItem(' less depreciation value ',Default)  + cast(@DepAmount as nvarchar(50)),          
			     'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,          
			     'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,          
			     @fromdate,@todate,0,0,@LEAFACCOUNT           
			End
		else if @TBType = 2
			Begin 
				if @fromdate <> @todate
					Begin
					   Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                
					   from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 
					   and AccountID=@AccountID -- and creationtime < @todate
	
					   set @DepAmount=IsNull(@DepAPVBalanceAmt,0)                
					   Set @Balance=IsNull(@APVBalanceAmt,0)                
	
					   Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                
					   from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID 
					   and APVAbstract.APVDate < @ToDate and IsNull(Saleable,0)=1 and 
					   AccountID=@AccountID -- and Batch_Assets.creationtime < @todate

					   set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)                
					   Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)                

					   Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                
					   from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And 
					   IsNull(Saleable,0)=0 and Batch_Assets.ARVID=ARVAbstract.DocumentID and 
					   ARVAbstract.ARVDate > @ToDate and AccountID=@AccountID
					   -- and Batch_Assets.creationtime < @todate
	
					   set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)                
					   Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)                

					   Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                
					   from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and                
					   Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID                
					   And ((Select APVDate from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) < @ToDate 
					   And ARVAbstract.ARVDate > @ToDate)
					   -- and Batch_Assets.creationtime < @todate
	
					   set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)                
					   Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)                
					End
				else if @fromdate = @todate
					Begin
					   Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                
					   from Batch_Assets where IsNull(APVID,0)=0 and IsNull(Saleable,0)=1 and AccountID=@AccountID                
					   set @DepAmount=IsNull(@DepAPVBalanceAmt,0)                
					   Set @Balance=IsNull(@APVBalanceAmt,0)                
					                  
					   Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(Batch_Assets.BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                
					   from Batch_Assets,APVAbstract where Batch_Assets.APVID=APVAbstract.DocumentID and 
					   APVAbstract.APVDate < @ToDate and IsNull(Saleable,0)=1 and AccountID=@AccountID                
					   set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)                
					   Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)                
					                  
					   Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))
					   from Batch_Assets,ARVAbstract where IsNull(APVID,0) = 0 And IsNull(Saleable,0)=0 and
					   Batch_Assets.ARVID=ARVAbstract.DocumentID and ARVAbstract.ARVDate > @ToDate and AccountID=@AccountID
					   set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)
					   Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)                
		
					   Select @APVBalanceAmt = Sum(IsNull(OPWDV,0)),@DepAPVBalanceAmt=Sum(IsNull(OPWDV,0)*(Case when IsNull(BillDate,0)<= @CheckDate then (@DepPercent/100) else ((@DepPercent/2)/100) End))                
					   from Batch_Assets,ARVAbstract where IsNull(APVID,0) <> 0 and IsNull(Saleable,0)=0 and                
					   Batch_Assets.ARVID=ARVAbstract.DocumentID and  AccountID=@AccountID                
					   And ((Select APVDate from APVAbstract where APVAbstract.DocumentID=Batch_Assets.APVID) < @ToDate And ARVAbstract.ARVDate > @ToDate)
					   set @DepAmount=IsNull(@DepAmount,0) +IsNull(@DepAPVBalanceAmt,0)
					   Set @Balance=IsNull(@Balance,0) + IsNull(@APVBalanceAmt,0)
					End

				 if @fromdate = @todate
					begin
						set @depamount = 0
					end
			     Set @balance=IsNull(@balance,0) - IsNull(@DepAmount,0)          
			     INSERT #TempRegister          
			     select 'Group ID'= @AccountID,'Group Name'= @AccountName + dbo.LookupDictionaryItem(' less depreciation value ',Default)  + cast(@DepAmount as nvarchar(50)),        
			     'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,          
			     'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,          
			     @fromdate,@todate,0,0,'5'
			End
    End          
    Else          
    Begin
	 If @TBType = 0  
		Begin
			 set @balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal           
		     Where [TransactionDate] between @todate and @ToDatePair and [AccountID] = @AccountID and         
		     documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128 and isnull(status,0) <> 192),0)          
		     set @balance=@balance + @LastBalance          
		     INSERT #TempRegister          
		     select 'Group ID'= @AccountID,'Group Name'= @AccountName ,          
		     'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,          
		     'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,          
		     @fromdate,@todate,0,0,@LEAFACCOUNT           
		End
	 else if @TBType = 1 
		Begin
		     set @balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal           
		     Where [TransactionDate] between @fromdate and @ToDatePair and [AccountID] = @AccountID and         
		     documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128 and isnull(status,0) <> 192),0)          
		     --set @balance=@balance + @LastBalance          
			 --select 'balance ',@Balance
		     INSERT #TempRegister          
		     select 'Group ID'= @AccountID,'Group Name'= @AccountName ,          
		     'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,          
		     'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,          
		     @fromdate,@todate,0,0,@LEAFACCOUNT           
		End
	 else if @TBType = 2
		Begin
		  	If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@todate and AccountID =@AccountID)                
		  	Begin                
			   	Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId=@AccountID --and isnull(Active,0)=1                
		  	End                
		  	Else                
		  	Begin                 
			   	set @LastBalance= isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@todate and AccountID=@AccountID),0)                
		  	End                
	     	INSERT #TempRegister          
	     	select 'Group ID'= @AccountID,'Group Name'= @AccountName ,          
	     	'Debit'= CASE WHEN (@LastBalance)> 0 THEN (@LastBalance)ELSE 0 END,          
	     	'Credit' = CASE WHEN (@LastBalance)< 0 THEN abs(@LastBalance)ELSE 0 END,          
	     	@fromdate,@todate,0,0,'5'
		End
-- -- -- 		Begin
-- -- -- 		     set @balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal           
-- -- -- 		     Where TransactionDate  = dbo.sp_acc_StripDateFromTime(@todate)  and [AccountID] = @AccountID and         
-- -- -- 		     documenttype not in (27,28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128 and isnull(status,0) <> 192),0)          
-- -- -- 		     --set @balance=@balance + @LastBalance          
-- -- -- 			 --select 'balance ',@Balance
-- -- -- 		     INSERT #TempRegister          
-- -- -- 		     select 'Group ID'= @AccountID,'Group Name'= @AccountName ,          
-- -- -- 		     'Debit'= CASE WHEN (@balance)> 0 THEN (@balance)ELSE 0 END,          
-- -- -- 		     'Credit' = CASE WHEN (@balance)< 0 THEN abs(@balance)ELSE 0 END,          
-- -- -- 		     @fromdate,@todate,0,0,@LEAFACCOUNT           
-- -- -- 		End
    End          
   End          
   FETCH NEXT FROM scantrialbalanceaccounts into @AccountID,@AccountName          
  End          
  CLOSE scantrialbalanceaccounts          
  DEALLOCATE scantrialbalanceaccounts 
            
  	If @Hide0BalAC = 0
  	Begin
		select GroupName,IsNull(Debit,0) - IsNull(Credit,0) from #TempRegister 
	End
	Else
	Begin
		select GroupName,IsNull(Debit,0) - IsNull(Credit,0) from #TempRegister 
	  	Where ((Isnull(Debit,0) + Isnull(Credit,0)) > 0 or isnull(colorinfo,0) in (1,3))
	End	
Drop table #TempRegister





