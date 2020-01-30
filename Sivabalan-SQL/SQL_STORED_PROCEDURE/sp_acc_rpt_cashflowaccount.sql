CREATE procedure sp_acc_rpt_cashflowaccount(@parentid integer,@fromdate datetime, @todate datetime,@State Int=0)--,@balance decimal(18,6) output,@drilldown integer = 0 )--,@TotalDepAmt decimal(18,6) = 0 Output)          
as  
DECLARE @STOCKINTRADE int      
SET @STOCKINTRADE =21          
-- -- -- Set @balance=0        
-- -- Set @TotalDepAmt=0      
Set Dateformat dmy
        
DECLARE @ToDatePair datetime        ,@group nvarchar(50)
DECLARE @GROUPNAME nVARCHAR(500)
Declare @HIGHLIGHT Int          
SET @HIGHLIGHT=1   
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))        

        
Create Table #temp(GroupID int,
     Status int)          
Declare @GroupID int          
--Insert into #temp select GroupID, 0 From AccountGroup          
--Where ParentGroup = @parentid and GroupID <> @STOCKINTRADE          
Insert into #temp select GroupID, 0 From AccountGroup          
Where ParentGroup = @parentid --and isnull(Active,0)=1          
          
Declare Parent Cursor Dynamic For          
Select GroupID From #temp --Where Status = 0          
Open Parent          
Fetch From Parent Into @GroupID          
While @@Fetch_Status = 0          
Begin          
 Insert into #temp           
 Select GroupID, 0 From AccountGroup          
 Where ParentGroup = @GroupID --and isnull(Active,0)=1          
 Fetch Next From Parent Into @GroupID          
End          
Close Parent          
DeAllocate Parent          


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
		Groupid		numeric(18),
		ParentGroup nvarchar(500),
		Status 	numeric(9),
		OpeningValue decimal(18,6),
		ClosingValue decimal(18,6),
	)	

	
-- -- -- 	select * from #cashgroup

	insert into #Cash_Bank_IDS
	SELECT Accountid,accountname,groupid,null,0,0,0 FROM ACCOUNTSMASTER WHERE GROUPID in (select groupid from #CASHGROUP)

Create table #TempReport(TransactionDate datetime, OriginalID nvarchar(15),Type nVarchar(50),          
AccountName nvarchar(50),FromDate datetime,ToDate datetime,DocRef int,DocType int,ColorInfoParam int,          
Debit decimal(18,6),Credit decimal(18,6),AccountID int,Balance nvarchar(50),TranID int,HighLight int)          

--select * from #temp
Declare @TxnAmt decimal(18,6)
Declare @LastBalance decimal(18,6)          
Declare @AccountBalance decimal(18,6)          
Declare @TranID1 Int,@Debit1 Decimal(18,6),@Credit1 Decimal(18,6),@TotalDebit1 Decimal(18,6),@TotalCredit1 Decimal(18,6)          
Declare @AccountID Int,@Exists Int,@DepPercent Decimal(18,6),@DepAmount Decimal(18,6),@TotDepAmt Decimal(18,6)          
Declare @CLOSINGSTOCK Int,@DEPRECIATION Int,@FIXEDASSETS Int, @OPENINGSTOCK Int,@TAXONCLOSINGSTOCK Int,@TAXONOPENINGSTOCK Int          
Set @CLOSINGSTOCK=23          
Set @DEPRECIATION=24          
Set @FIXEDASSETS=13          
SET @OPENINGSTOCK=22          
Set @TAXONCLOSINGSTOCK=88          
Set @TAXONOPENINGSTOCK=89          
          
Declare @DepOpeningBalance Decimal(18,6),@DepOpeningBalanceAmt Decimal(18,6),@DepAPVBalanceAmt Decimal(18,6),@DepARVBalanceAmt Decimal(18,6)          
Declare @CheckDate as datetime,@StrDate as nvarchar(255),@APVBalanceAmt Decimal(18,6)          
--Select @StrDate=  '1/' + Cast(IsNull(FiscalYear,4) as varchar) + '/' + Cast(Year(OpeningDate) As Varchar(50)) From Setup          
Set @StrDate= dbo.sp_acc_getfiscalyearstart()          
Set @CheckDate =Cast(@StrDate As DateTime)          
set @CheckDate = DateAdd(m, 6, @CheckDate)          
set @CheckDate = DateAdd(s, 0-1, @CheckDate)          

CREATE TABLE #GROUPBALANCE 
(
	GROUPID		NUMERIC(9),
	TRANSACTIOID NUMERIC(9),
	ACCOUNTID	NUMERIC(9),
	DEBIT decimal(18,6),
	CREDIT decimal(18,6)
)



declare @transactioNid numeric(9),@tempaccountid numeric(9),@debit decimal(18,6),@credit Decimal(18,6)
declare @count numeric(18)

insert into #temp values(@parentid,0)          



-- -- -- if @drilldown = 0 
-- -- -- 	Begin
-- -- -- 		Declare scanrecursiveaccounts Cursor Keyset For          
-- -- -- 		Select AccountID from AccountsMaster where GroupID in (select groupid from #temp) and    
-- -- -- 		AccountID not in (@CLOSINGSTOCK,@TAXONCLOSINGSTOCK,500) 
-- -- -- 	End
-- -- -- Else if @drilldown = 1 
-- -- -- 	Begin
Declare scanrecursiveaccounts Cursor Keyset For          
Select AccountID from AccountsMaster where accountid = @parentid and    
AccountID not in (@CLOSINGSTOCK,@TAXONCLOSINGSTOCK,500) 
Open scanrecursiveaccounts          
Fetch From scanrecursiveaccounts Into @AccountID          
While @@Fetch_Status=0          
Begin   
--dbo.IsClosedDocument(DocumentReference,DocumentType)=@State  
	set @accountbalance = 0
	if @accountid = 4
		Begin
			if @state = 0
				Begin
					Declare Cursor1 cursor for
					select distinct transactionid,debit,credit from generaljournal where accountid = @AccountID
					and transactionid in (select distinct transactionid from generaljournal where 
					dbo.stripdatefromtime(transactiondate) between @fromdate and @todate)
					and accountid not in (select distinct accountid from #Cash_Bank_IDS ) 
					and isnull(status,0) <> 192 and isnull(status,0) <> 128
					and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
				End
			else
				Begin
					Declare Cursor1 cursor for
					select distinct transactionid,debit,credit from generaljournal where accountid = @AccountID
					and transactionid in (select distinct transactionid from generaljournal where 
					dbo.stripdatefromtime(transactiondate) between @fromdate and @todate)
					and accountid not in (select distinct accountid from #Cash_Bank_IDS ) 
					and dbo.IsClosedDocument(DocumentReference,DocumentType)=@State  
					and isnull(status,0) <> 192 and isnull(status,0) <> 128
					and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
				End
		End
	Else
		Begin
			if @state = 0 
				Begin
					Declare Cursor1 cursor for
					select distinct transactionid,debit,credit from generaljournal where accountid = @AccountID
					and transactionid in (select distinct transactionid from generaljournal where 
					dbo.stripdatefromtime(transactiondate) between @fromdate and @todate and accountid in (select distinct accountid from #Cash_Bank_IDS) )
					and accountid not in (select distinct accountid from #Cash_Bank_IDS ) 
					and isnull(status,0) <> 192 and isnull(status,0) <> 128
					and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
				End
			Else
				Begin
					Declare Cursor1 cursor for
					select distinct transactionid,debit,credit from generaljournal where accountid = @AccountID
					and transactionid in (select distinct transactionid from generaljournal where 
					dbo.stripdatefromtime(transactiondate) between @fromdate and @todate and accountid in (select distinct accountid from #Cash_Bank_IDS) )
					and accountid not in (select distinct accountid from #Cash_Bank_IDS ) 
					and dbo.IsClosedDocument(DocumentReference,DocumentType)=@State  
					and isnull(status,0) <> 192 and isnull(status,0) <> 128
					and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
				End
		end

	open cursor1
	Fetch from cursor1 into @transactionid,@debit,@credit

	while @@Fetch_status = 0
	Begin
		if  @debit <> 0 
		Begin
			select @count = count(1) from generaljournal where transactionid = @transactionid
			and credit <> 0 and accountid in (select distinct accountid from #Cash_Bank_IDS )
			and status <> 192 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
			if @count > 0
				Begin
					select @txnamt = sum(credit) from generaljournal where transactionid = @transactionid
					and credit <> 0 and accountid in (select distinct accountid from #Cash_Bank_IDS )
					and status <> 192 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)

					insert into #tempreport
					select TransactionDate,
					case 
						when DocumentType in (26,37) then  dbo.GetOriginalID(DocumentNumber,DocumentType) 
						else dbo.GetOriginalID(DocumentReference,DocumentType) 
					end, 
					dbo.GetDescription(DocumentReference,DocumentType),          
   					AccountName,@fromdate,@todate,DocumentReference,DocumentType,0,0,@txnamt,
   					GeneralJournal.AccountID,'',          
   					@transactionid,dbo.GetDynamicSetting(DocumentType,DocumentReference) 
					from generaljournal , AccountsMaster where GeneralJournal.AccountID = AccountsMaster.AccountID 
					and transactionid = @transactionid
					and debit <> 0 and GeneralJournal.accountid not in (select distinct accountid from #Cash_Bank_IDS )
					and status <> 192 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
				End
		End
		Else if @credit <> 0
		Begin
			(select @count = count(1) from generaljournal where transactionid = @transactionid
			and debit <> 0 and accountid in (select distinct accountid from  #Cash_Bank_IDS )
			and status <> 192 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) )
			if @count > 0
				Begin

					select @txnamt = debit from generaljournal where transactionid = @transactionid
					and debit <> 0 and accountid in (select distinct accountid from #Cash_Bank_IDS )
					and status <> 192 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
					set @accountbalance = @accountbalance + @txnamt

					insert into #tempreport
					select TransactionDate,
					case 
						when DocumentType in (26,37) then  dbo.GetOriginalID(DocumentNumber,DocumentType) 
						else dbo.GetOriginalID(DocumentReference,DocumentType) 
					end, 
					dbo.GetDescription(DocumentReference,DocumentType),          
   					AccountName,@fromdate,@todate,DocumentReference,DocumentType,0,@txnamt,0,
   					GeneralJournal.AccountID,'',          
   					@transactionid,dbo.GetDynamicSetting(DocumentType,DocumentReference) 
					from generaljournal , AccountsMaster where GeneralJournal.AccountID = AccountsMaster.AccountID
					and transactionid = @transactionid
					and credit <> 0 and GeneralJournal.accountid not in (select distinct accountid from #Cash_Bank_IDS )
					and status <> 192 and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
				End
		End
		Fetch from cursor1 into @transactionid,@debit,@credit		
	End
	close cursor1
	deallocate cursor1
   	Set @AccountBalance=isnull(@AccountBalance,0)
            
-- -- --  	set @balance=isnull(@balance,0) + isnull(@AccountBalance,0)          
 Fetch Next From scanrecursiveaccounts Into @AccountID          
End          
      
Close scanrecursiveaccounts          
DeAllocate scanrecursiveaccounts          

Insert #TempReport          
Select @ToDatePair ,'','',dbo.lookupdictionaryitem('Total',Default),'','','','','',sum(Debit) ,
sum(Credit),'','','',@HIGHLIGHT from #Tempreport          



Select 
'Date'=dbo.StripDateFromTime(TransactionDate),
'Transaction ID'=OriginalID,          
'Description'=Type,'Particular'=AccountName,
'AccountID'=AccountID,Fromdate,Todate,          
'DocRef'= 
case 	
	when [DocType]=37 or([DocType]=26 and [DocRef]= 2) then TranID 
	else DocRef 
end,
'DocType'=DocType,ColorInfoParam,'Particular'=AccountName,          
'Debit'=Debit,'Credit'=Credit,'','High Light'=HighLight from #TempReport order by TransactionDate          

Drop table #TempReport   


          
/*set @balance= isnull((select sum(isnull(debit,0) - isnull(credit,0)) from generaljournal           
where dbo.stripdatefromtime([TransactionDate]) between @fromdate and @todate and           
([AccountID] in (select [AccountID] from [AccountsMaster] where [GroupID] in (select groupid from #temp)))), 0)          
set @balance=@Balance + @LastBalance          
*/          
drop table #temp 












