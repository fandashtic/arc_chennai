CREATE Procedure sp_acc_rpt_tradingacdrilldowncount(@fromdate datetime,@todate datetime ,@parentid  integer,@docref integer,@doctype integer,@mode integer,@Info nvarchar(4000) = Null,@State Int=0,@Hide0BalAC Int =0)          
as          
DECLARE @debit decimal(18,6),@credit decimal(18,6),@account nvarchar(30),@group nvarchar(255)          
DECLARE @totaldebit decimal(18,6),@totalcredit decimal(18,6)          
DECLARE @parentgroup1 integer,@groupid integer,@parentgroup  integer          
DECLARE @balance decimal(18,6),@ConvertInfo Decimal(18,6)          
          
DECLARE @LEAFACCOUNT integer          
DECLARE @ACCOUNTGROUP integer          
DECLARE @NEXTLEVEL integer          
DECLARE @NONEXTLEVEL integer          
DECLARE @SPECIALCASE4 Integer          
        
DECLARE @ToDatePair datetime              
SET @TodatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))              
        
SET @NEXTLEVEL =0          
SET @NONEXTLEVEL =1          
SET @LEAFACCOUNT =2          
SET @ACCOUNTGROUP =3          
SET @SPECIALCASE4=100          
          
Declare @DayCount int          
Set @DayCount=DateDiff(day,@FromDate,@ToDate)+1          
          
Declare @OpenDate DateTime -- Opening date from setup          
Select @OpenDate=dbo.stripdatefromtime(OpeningDate) from setup          
          
IF @mode = @ACCOUNTGROUP           
BEGIN          
	create Table #AccountGroup 
	(GroupName nvarchar(255),Debit decimal(18,6),Credit decimal(18,6),Dummy1 Decimal(18,6),
	GroupID integer,FromDate datetime,ToDate datetime,DocRef integer,DocType integer,
	Dummy2 Int, Dummy3 Int)
	Insert into #AccountGroup 
	Exec sp_acc_rpt_tradingacdetail @fromdate ,@todate ,@parentid ,@docref ,@doctype ,@mode ,@Info ,@State ,@Hide0BalAC
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
ELSE IF @mode =@SPECIALCASE4          
BEGIN          
   	Set @ConvertInfo=Cast(@Info as Decimal(18,6))          
	Create table #NetProfitDetail
	(PartnerName nVarchar(255),ShareRatio Decimal(18,6),ShareValue Decimal(18,6),HighLight Int)	
   	exec sp_acc_rpt_netprofitdetail @ConvertInfo          
	Select count(*) from #NetProfitDetail
	Drop table #NetProfitDetail
END 



