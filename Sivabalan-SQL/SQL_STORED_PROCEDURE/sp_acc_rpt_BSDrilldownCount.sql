CREATE Procedure sp_acc_rpt_BSDrilldownCount(@fromdate datetime,@todate datetime ,@parentid  integer,@docref integer,@doctype integer,@mode integer,@Info nvarchar(4000) = Null,@State Int=0,@Hide0BalAC Int =0)
as          
DECLARE @debit decimal(18,6),@credit decimal(18,6),@account nvarchar(30),@group nvarchar(255)          
DECLARE @totaldebit decimal(18,6),@totalcredit decimal(18,6)          
DECLARE @parentgroup1 integer,@groupid integer,@parentgroup  integer          
DECLARE @balance decimal(18,6),@LastBalance Decimal(18,6),@TotalDepAmt Decimal(18,6)          
DECLARE @stockvalue decimal(18,6)          
Declare @ConvertInfo decimal(18,6)          
DECLARE @CURRENTASSET int          
DECLARE @SPECIALCASE2 int          
DECLARE @SPECIALCASE3 int          
DECLARE @SPECIALCASE4 int          
DECLARE @LEAFACCOUNT integer          
DECLARE @ACCOUNTGROUP integer          
DECLARE @NEXTLEVEL integer          
DECLARE @NONEXTLEVEL integer          
          
DECLARE @ToDatePair datetime          
Set @TodatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))          
        
SET @NEXTLEVEL =0          
SET @NONEXTLEVEL =1          
SET @LEAFACCOUNT =2          
SET @ACCOUNTGROUP =3          
          
SET @CURRENTASSET =17 -- groupid of current asset          
SET @SPECIALCASE2 =5 -- to restrict the link report for the stockvalue          
SET @SPECIALCASE3 =6 --Link to the Trading and P & L A/C          
SET @SPECIALCASE4 =7 --Link to the Share details of partners          
          
Declare @OPENINGSTOCK Int          
Declare @CLOSINGSTOCK Int          
Declare @DEPRECIATION Int          
Declare @FIXEDASSETS Int          
Declare @TAXONCLOSINGSTOCK Int          
Declare @TAXONOPENINGSTOCK Int          
Set @FIXEDASSETS=13          
SET @OPENINGSTOCK=22          
SET @CLOSINGSTOCK = 23          
Set @DEPRECIATION=24          
Set @TAXONCLOSINGSTOCK=88          
Set @TAXONOPENINGSTOCK=89          
          
DECLARE @OPENINGSTOCKGROUP INT,@CLOSINGSTOCKGROUP Int          
SET @OPENINGSTOCKGROUP=54          
Set @CLOSINGSTOCKGROUP=55          
          
Declare @TranID1 Int, @Debit1 Decimal(18,6), @Credit1 Decimal(18,6), @TotalDebit1 Decimal(18,6), @TotalCredit1 Decimal(18,6)          
if @parentid = @OPENINGSTOCKGROUP and @mode = @ACCOUNTGROUP        
Begin        
  exec sp_acc_rpt_tradingacdrilldowncount @Fromdate,@Todate, @parentid, @docref, @doctype, @mode, @Info, @State        
  goto Quit        
End        
  
IF @mode = @ACCOUNTGROUP or (@Mode = @SPECIALCASE3 and @parentid<>0)          
BEGIN          
	create Table #AccountGroup
	(GroupName nvarchar(255),
	Debit decimal(18,6),Credit decimal(18,6),Dummy1 int,GroupID integer,
	FromDate datetime,ToDate datetime,DocRef integer,DocType integer,
	Dummy2 Int,Dummy3 Int)
	Insert into #AccountGroup
	Exec sp_acc_rpt_balancesheetdetail @fromdate ,@todate  ,@parentid  ,@docref ,@doctype ,@mode ,@Info ,@State ,@Hide0BalAC
	Select count(*) from #AccountGroup
	Drop Table #AccountGroup
END          
ELSE IF @mode=@LEAFACCOUNT           
BEGIN          
	Create table #LEAFACCOUNT
	(TransactionDate datetime, OriginalID nvarchar(15), DocumentReference nVarChar(255), Type nVarchar(50),
	AccountID int,FromDate datetime,ToDate datetime,DocRef int,DocType int,ColorInfoParam int,
	AccountName nvarchar(255),Debit decimal(18,6),Credit decimal(18,6),Balance nvarchar(50), DocumentBalance nVarChar(50), 
	Narration nvarchar(2000),ChequeInfo nvarchar(255),HighLight int)              
	Insert into #LEAFACCOUNT
   	exec sp_acc_rpt_account @fromdate,@todate,@parentid,@State          
	Select count(*) from #LEAFACCOUNT
	Drop Table #LEAFACCOUNT
END          
ELSE IF @mode =@NEXTLEVEL  
BEGIN          
   exec sp_acc_prn_Ledger_GetdrillCount @docref,@doctype,@Info
END          
ELSE IF @Mode = @SPECIALCASE3 and @parentid=0          
BEGIN          
	Create table #TempTradingCount(AccountName nvarchar(25),Debit Decimal(18,6),Credit Decimal(18,6),
	Dummy1 int,AccountID Int,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,
	HighLight Int,Dummy2 Decimal(18,6),Dummy3 Int)
	Insert into #TempTradingCount
 	exec sp_acc_rpt_tradingac @fromdate,@todate,3          
	Select count(*) from #TempTradingCount
	Drop Table #TempTradingCount
END          
ELSE IF @Mode = @SPECIALCASE4 and @parentid=0          
BEGIN          
 	Set @ConvertInfo=Cast(@Info as Decimal(18,6))        
	Create table #NetProfitDetail
	(PartnerName nVarchar(255),ShareRatio Decimal(18,6),ShareValue Decimal(18,6),HighLight Int)	
 	exec sp_acc_rpt_netprofitdetail @ConvertInfo          
	Select count(*) from #NetProfitDetail
	Drop table #NetProfitDetail
END   
  
Quit: 



