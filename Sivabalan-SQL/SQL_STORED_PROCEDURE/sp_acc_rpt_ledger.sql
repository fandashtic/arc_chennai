CREATE Procedure sp_acc_rpt_ledger(@FromDate datetime,@ToDate datetime,@AccountID Int,
@daywisedisplay int = 0,@State Int=0,@Summary Int = 0)
As
----------------------------Ledger Summary New Implementation--------------------------------
If @Summary = 1
Begin
Exec sp_acc_rpt_LedgerSummary @AccountID,@FromDate,@ToDate,@DayWiseDisplay,@State
GoTo ExitProc
End
---------------------------------------------------------------------------------------------
Declare @TRANID INT
Declare @AccountCode INT
Declare @AccountName nVarchar(30)
Declare @DEBIT decimal(18,6)
Declare @CREDIT decimal(18,6)
Declare @OriginalID nvarchar(255)
--Declare @OriginalID nvarchar(15)
Declare @Description nvarchar(50)
Declare @RefNumber nvarchar(50)
Declare @DocType Int
Declare @Narration nVarchar(2000)
Declare @Count INT
Declare @OpeningBalance Decimal(18,6)
Declare @Balance Decimal(18,6)
Declare @ChequeInfo nvarchar(4000)
Declare @DocBalance nVarChar(50)
Declare @DocReference nVarChar(255)
--
Declare @f1 datetime
Declare @f2 nvarchar(255)
--Declare @f2 nvarchar(15)
Declare @f3 nVarChar(255)
Declare @f4 nvarchar(50)
Declare @f5 nvarchar(255)
Declare @f6 decimal(18,6)
Declare @f7 decimal(18,6)
Declare @f8 nvarchar(50)
Declare @f9 int
Declare @f10 int
Declare @f11 Decimal(18,6)
Declare @f12 nVarChar(50)
Declare @f13 int
Declare @f14 nvarchar(2000)
Declare @f15 nvarchar(255)
Declare @f16 int

Declare @SumCredit Decimal(18,6),@SumAcID BigInt
Declare @SumDebit Decimal(18,6)

Declare @ToDatePair datetime
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))

Create table #TempReport(TransactionDate datetime,OriginalID nvarchar(255),DocumentReference nVarChar(255),Type nVarchar(50),AccountName nvarchar(255),Debit decimal(18,6),Credit decimal(18,6),
DocRef int,DocType int,AccountID int,Balance nvarchar(50),DocumentBalance nVarChar(50),TranID integer,Narration nVarchar(2000),ChequeInfo nVarchar(255),HighLight int)

--Create table #TempReport(TransactionDate datetime,OriginalID nvarchar(15),DocumentReference nVarChar(255),Type nVarchar(50),AccountName nvarchar(255),Debit decimal(18,6),Credit decimal(18,6),
--DocRef int,DocType int,AccountID int,Balance nvarchar(50),DocumentBalance nVarChar(50),TranID integer,Narration nVarchar(2000),ChequeInfo nVarchar(255),HighLight int)

If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@fromdate and AccountID = @AccountID)
Begin
Select @OpeningBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId = @AccountID and Active=1
End
Else
Begin
set @OpeningBalance= isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@fromdate and AccountID = @AccountID),0)
End

Insert #tempreport
Select @FromDate,'','','','Opening Balance',case when @OpeningBalance > 0 then @OpeningBalance else 0 end ,case when @OpeningBalance  < 0 then abs(@OpeningBalance) else 0 end,'','','','','','','','',1
Set @Balance=@OpeningBalance

If @State=0
Begin
Declare ScanJournal Cursor Keyset For
Select TransactionID,Debit,Credit ,case when DocumentType in (26,37) then
dbo.GetOriginalID(isnull(DocumentNumber,0),DocumentType) else dbo.GetOriginalID(DocumentReference,DocumentType) end,
dbo.GetDescription(DocumentReference,DocumentType), DocumentReference,DocumentType,
case when DocumentType in (26,37) then Isnull(Remarks,N'') else dbo.sp_acc_GetNarration(DocumentReference,DocumentType) end, dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,ReferenceNumber),
Case When DocumentType In (26,37) Then dbo.sp_acc_rpt_GetDocBalance(TransactionID,DocumentType,ReferenceNumber) Else dbo.sp_acc_rpt_GetDocBalance(DocumentReference,DocumentType,ReferenceNumber) End,
Case When DocumentType In (26,37) Then dbo.sp_acc_GetFlexibleNumber(DocumentNumber,DocumentType) Else dbo.sp_acc_GetFlexibleNumber(DocumentReference,DocumentType) End
from GeneralJournal where GeneralJournal.AccountID=@AccountID and
TransactionDate between @FromDate and @ToDatePair and
documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128
and isnull(status,0) <> 192 order by TransactionDate
Open ScanJournal
Fetch From ScanJournal Into @TranID,@Debit,@Credit,@OriginalID,@Description, @RefNumber,@Doctype,@Narration,@ChequeInfo,@DocBalance,@DocReference
End
Else
Begin
Declare ScanJournal Cursor Keyset For
Select TransactionID,Debit,Credit ,case when DocumentType in (26,37) then
dbo.GetOriginalID(isnull(DocumentNumber,0),DocumentType) else dbo.GetOriginalID(DocumentReference,DocumentType) end,
dbo.GetDescription(DocumentReference,DocumentType), DocumentReference,DocumentType,
case when DocumentType in (26,37) then Isnull(Remarks,N'') else dbo.sp_acc_GetNarration(DocumentReference,DocumentType) end, dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,ReferenceNumber),
Case When DocumentType In (26,37) Then dbo.sp_acc_rpt_GetDocBalance(TransactionID,DocumentType,ReferenceNumber) Else dbo.sp_acc_rpt_GetDocBalance(DocumentReference,DocumentType,ReferenceNumber) End,
Case When DocumentType In (26,37) Then dbo.sp_acc_GetFlexibleNumber(DocumentNumber,DocumentType) Else dbo.sp_acc_GetFlexibleNumber(DocumentReference,DocumentType) End
from GeneralJournal where GeneralJournal.AccountID=@AccountID and
TransactionDate between @FromDate and @ToDatePair and
dbo.IsClosedDocument(DocumentReference,DocumentType)=@State and
documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128
and isnull(status,0) <> 192 order by TransactionDate
Open ScanJournal
Fetch From ScanJournal Into @TranID,@Debit,@Credit,@OriginalID,@Description, @RefNumber,@Doctype,@Narration,@ChequeInfo,@DocBalance,@DocReference
End

while @@Fetch_Status=0
Begin
If @Debit=0
Begin
If @DocType=37 or @DocType=26
Begin
Select @Count=Count(*) from GeneralJournal where GeneralJournal.AccountID not in(select AccountID from generaljournal where TransactionID=@TranID and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and



TransactionID=@TranID and DocumentType =@DocType and Debit<>0
End
Else
Begin
Select @Count=Count(*) from GeneralJournal where GeneralJournal.AccountID not in(select AccountID from generaljournal where TransactionID=@TranID and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and


TransactionID=@TranID and DocumentReference = @RefNumber and DocumentType =@DocType and Debit<>0
End
if @Count=1
Begin
Set @Balance=@Balance-@Credit
insert into #TempReport
Select TransactionDate,@OriginalID,@DocReference,@Description,
AccountName,0,@Credit,DocumentReference,DocumentType,GeneralJournal.AccountID,
case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + dbo.LookupDictionaryItem('Cr',Default) else cast(@Balance as nvarchar(50)) + dbo.LookupDictionaryItem('Dr',Default) end,@DocBalance,
@TranID,@Narration,@ChequeInfo,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference)from GeneralJournal,AccountsMaster where
GeneralJournal.AccountID not in(select AccountID from generaljournal
where TransactionID=@TranID and credit <> 0 and DocumentReference = @RefNumber
and DocumentType =@DocType) and GeneralJournal.AccountID = AccountsMaster.AccountID
and TransactionID=@TranID and Debit<>0 and DocumentType = @doctype order by TransactionDate
End
Else If @Count>1
Begin
If @summary = 0
Begin
Declare ScanCount Cursor Keyset For
Select TransactionDate,@OriginalID,@DocReference,@Description,
AccountName,Credit,Debit,DocumentReference,DocumentType,GeneralJournal.AccountID,(Credit-Debit),@DocBalance,
@TranID,@Narration,@ChequeInfo,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference)
from GeneralJournal,AccountsMaster where GeneralJournal.AccountID
not in(select AccountID from generaljournal where TransactionID=@TranID
and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and
GeneralJournal.AccountID = AccountsMaster.AccountID and
TransactionID=@TranID and Debit<>0 and DocumentType = @doctype order by TransactionDate
End
Else
Begin
If @DocType in(1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,10 ,11 ,12 ,40 ,41 ,42 ,54 ,55 ,66 ,67 ,68 ,69 ,70 ,72 ,73 ,88 ,89)
Begin
set @SumDebit = 0
Set @SumAcID = 0

Select @SumDebit = sum(Debit) ,
@SumAcID = dbo.Sp_Acc_Get_SummaryAC(documentreference,Documenttype)
from
GeneralJournal,AccountsMaster where GeneralJournal.AccountID
not in(select AccountID from generaljournal where TransactionID=@TranID
and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and
GeneralJournal.AccountID = AccountsMaster.AccountID and
TransactionID=@TranID and DocumentType = @DocType and Debit<>0
group by documentreference,documenttype,transactiondate
order by TransactionDate--and Debit=0


Declare ScanCount Cursor Keyset For
Select TransactionDate,@OriginalID,@DocReference,@Description,
dbo.getaccountname(@SumAcID),Credit,@SumDebit,DocumentReference,DocumentType,
GeneralJournal.AccountID,(Credit-@SumDebit),@DocBalance,
@TranID,@Narration,@ChequeInfo,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference)
from GeneralJournal,AccountsMaster where GeneralJournal.AccountID = @SumAcID
and generalJournal.AccountID = AccountsMaster.AccountID and
TransactionID=@TranID and Debit<>0 and DocumentType = @doctype order by TransactionDate
End
Else
Begin
Declare ScanCount Cursor Keyset For
Select TransactionDate,@OriginalID,@DocReference,@Description,
AccountName,Credit,Debit,DocumentReference,DocumentType,GeneralJournal.AccountID,(Credit-Debit),@DocBalance,
@TranID,@Narration,@ChequeInfo,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference)
from GeneralJournal,AccountsMaster where GeneralJournal.AccountID
not in(select AccountID from generaljournal where TransactionID=@TranID
and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and
GeneralJournal.AccountID = AccountsMaster.AccountID and
TransactionID=@TranID and Debit<>0 and DocumentType = @doctype order by TransactionDate
End
End
Open ScanCount
Fetch From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,@f14,@f15,@f16
while @@Fetch_Status=0
Begin
Set @Balance=@Balance + @f11
insert into #TempReport
Select @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + dbo.LookupDictionaryItem('Cr',Default) else cast(@Balance as nvarchar(50)) + dbo.LookupDictionaryItem('Dr',Default) end,@f12,@f13,@f14,@f15,@f16
Fetch Next From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,@f14,@f15,@f16
End
Close ScanCount
Deallocate ScanCount
/*insert into #TempReport
Select dbo.stripdatefromtime(TransactionDate),@OriginalID,@Description,
AccountName,Credit,Debit, DocumentReference,DocumentType,GeneralJournal.AccountID,
@TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference)
from GeneralJournal,AccountsMaster where GeneralJournal.AccountID
not in(select AccountID from generaljournal where TransactionID=@TranID
and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and
GeneralJournal.AccountID = AccountsMaster.AccountID and
TransactionID=@TranID and Debit<>0 and DocumentType = @doctype
*/
End
End
Else if @credit=0
Begin
If @DocType=37 or @DocType=26
Begin
Select @Count=Count(*) from GeneralJournal where GeneralJournal.AccountID not in
(select AccountID from generaljournal where TransactionID=@TranID and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)
and TransactionID=@TranID and DocumentType =@DocType and credit<>0
End
Else
Begin
Select @Count=Count(*) from GeneralJournal where GeneralJournal.AccountID not in
(select AccountID from generaljournal where TransactionID=@TranID and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)
and TransactionID=@TranID and DocumentReference = @RefNumber and DocumentType =@DocType and credit<>0
End
If @Count=1
Begin
Set @Balance=@Balance+@Debit
insert into #TempReport
Select TransactionDate,@OriginalID,@DocReference,@Description,
AccountName, @Debit,0, DocumentReference,DocumentType,GeneralJournal.AccountID,
case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + dbo.LookupDictionaryItem('Cr',Default) else cast(@Balance as nvarchar(50)) + dbo.LookupDictionaryItem('Dr',Default) end,@DocBalance,
@TranID,@Narration,@ChequeInfo,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference) from GeneralJournal,AccountsMaster
where GeneralJournal.AccountID not in(select AccountID from generaljournal
where TransactionID=@TranID and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)
and GeneralJournal.AccountID = AccountsMaster.AccountID and TransactionID=@TranID and Credit<>0
and DocumentType = @doctype order by TransactionDate
End
Else if @Count>1
Begin
If @Summary = 0
Begin
Declare ScanCount Cursor Keyset For
Select TransactionDate,@OriginalID,@DocReference,@Description,
AccountName, Credit,Debit,DocumentReference,DocumentType, GeneralJournal.AccountID,(Credit-Debit),@DocBalance,
@TranID,@Narration,@ChequeInfo,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference) from
GeneralJournal,AccountsMaster where GeneralJournal.AccountID
not in(select AccountID from generaljournal where TransactionID=@TranID
and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and
GeneralJournal.AccountID = AccountsMaster.AccountID and
TransactionID=@TranID and DocumentType = @doctype and Credit<>0 order by TransactionDate--and Debit=0
End
Else
Begin
If @DocType in(1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,10 ,11 ,12 ,40 ,41 ,42 ,54 ,55 ,66 ,67 ,68 ,69 ,70 ,72 ,73 ,88 ,89)
Begin
set @SumCredit = 0
Set @SumAcID = 0

Select @SumCredit = sum(credit) ,
@SumAcID =dbo.Sp_Acc_Get_SummaryAC(documentreference,Documenttype)
from
GeneralJournal,AccountsMaster where GeneralJournal.AccountID
not in(select AccountID from generaljournal where TransactionID=@TranID
and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and
GeneralJournal.AccountID = AccountsMaster.AccountID and
TransactionID=@TranID and DocumentType = @DocType and Credit<>0
group by documentreference,documenttype,transactiondate
order by TransactionDate--and Debit=0

Declare ScanCount Cursor Keyset For
Select TransactionDate,@OriginalID,@DocReference,@Description,
dbo.getaccountname(@SumAcID), @SumCredit,Debit,DocumentReference,DocumentType, @SumAcID,
(@SumCredit-Debit),@DocBalance,
@TranID,@Narration,@ChequeInfo,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference) from
GeneralJournal,AccountsMaster where GeneralJournal.AccountID  = @SumAcID and
GeneralJournal.AccountID = AccountsMaster.AccountID and
TransactionID=@TranID and DocumentType = @doctype and Credit<>0 order by TransactionDate--and Debit=0
End
Else
Begin
Declare ScanCount Cursor Keyset For
Select TransactionDate,@OriginalID,@DocReference,@Description,
AccountName, Credit,Debit,DocumentReference,DocumentType, GeneralJournal.AccountID,(Credit-Debit),@DocBalance,
@TranID,@Narration,@ChequeInfo,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference) from
GeneralJournal,AccountsMaster where GeneralJournal.AccountID
not in(select AccountID from generaljournal where TransactionID=@TranID
and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and
GeneralJournal.AccountID = AccountsMaster.AccountID and
TransactionID=@TranID and DocumentType = @doctype and Credit<>0 order by TransactionDate--and Debit=0
End
End
Open ScanCount
Fetch From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,@f14,@f15,@f16
while @@Fetch_Status=0
Begin
Set @Balance=@Balance + @f11
/*insert into #TempReport
Select dbo.stripdatefromtime(TransactionDate),@OriginalID,@Description,
AccountName, Credit,Debit,DocumentReference,DocumentType, GeneralJournal.AccountID,@Balance,
@TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference) from
GeneralJournal,AccountsMaster where GeneralJournal.AccountID
not in(select AccountID from generaljournal where TransactionID=@TranID
and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and
GeneralJournal.AccountID = AccountsMaster.AccountID and
TransactionID=@TranID and DocumentType = @doctype and Credit<>0 --and Debit=0
Fetch Next From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@Balance,@f11,@f12
*/
insert into #TempReport
Select @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + dbo.LookupDictionaryItem('Cr',Default) else cast(@Balance as nvarchar(50)) + dbo.LookupDictionaryItem('Dr',Default) end,@f12,@f13,@f14,@f15,@f16

Fetch Next From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,@f14,@f15,@f16
End
Close ScanCount
Deallocate ScanCount
End
End
Fetch Next From scanJournal into @TranID, @Debit, @Credit,@OriginalID,@Description, @RefNumber,@Doctype,@Narration,@ChequeInfo,@DocBalance,@DocReference
End
Close ScanJournal
Deallocate ScanJournal
Declare @ClosingBalance Decimal(18,6)
Set @ClosingBalance=(Select sum(isnull(Debit,0)-isnull(Credit,0)) from #TempReport)

Insert #TempReport
Select @ToDatePair ,'','','','Total',sum(Debit) ,sum(Credit),'','','','','','','','',1 from #Tempreport

Insert #TempReport
Select @ToDatePair ,'','','','Closing Balance',case when isnull(@ClosingBalance,0) > 0 then isnull(@ClosingBalance,0) else 0 end ,case when isnull(@ClosingBalance,0)< 0 then abs(isnull(@ClosingBalance,0)) else 0 end,'','','','','','','','',1






/* IF @DAYWISEDISPLAY  = 0 THEN RUN THE BELOW QUERY ELSE GO TO NEXT IF CONDITION */
if @daywisedisplay = 0
begin
Select 'Document Date'=dbo.stripdatefromtime(TransactionDate),'Document ID'=OriginalID,
'Document Reference' = DocumentReference, 'Description'=Type,'Particular'=AccountName,'Debit'=Debit,'Credit'=Credit,
'DocRef'= case when [DocType]=37 or ([DocType]=26 and [DocRef]= 2)then TranID else  DocRef end,
'DocType'=DocType,'AccountID'=AccountID,'Balance'=Balance,'Document Balance'=DocumentBalance,'Narration' = Narration,'Cheque Info' = ChequeInfo,'High Light'=HighLight from #TempReport Order By TransactionDate
--  Drop table #TempReport
end
/* if @DAYWISEDISPLAY = 1 THEN THE BREAK UP HAS TO BE SHOWN DAY WISE
LOGIC FOLLOWED
THE RECORDS ARE FIRST PUT INTO TEMP TABLE (#TEMPREPORT) IN THE ABOVE STEPS -> NO CHANGE
THEN CREATE ANOTHER TABLE (#DATES) TO STORE THE DATE BETWEEN THE FROM AND TO DATE
THEN RUN A LOOP AND FIND IF THERE R ANR RECRODS FOR THE DATES(IN #DATES) IN THE #TEMPREPORT..
IF S GET THE DETAILS AND PUT IN ANOTHER TEMPTABLE #TEMPREPORT1 AND ALSO THE TOTAL DETAILS
IF NO THEN JUS GET THE PREVIOS DATES CLOSING BALANCE AND FIND THE TOATL ETC......
THEN DISPKAY THE RECORDS FROM #TEMPREPORT1 (SINCE @DAYWISEDISPLAY = 1)
AND NOT FROM #TEMPREPORT(@DAYWISEDISPLAY = 0)
*/
if @daywisedisplay = 1
begin
declare @transactiondate datetime
declare @txncount integer
declare @CREDITBALANCE Decimal(18,6)
declare @DEBITBALANCE Decimal(18,6)
declare @CURR_TRANSACTIONDATE datetime

create table #dates
(
transactiondate datetime,
txncount numeric(9)
)

Create table #TempReport1
(
row_num int identity(1,1),
TransactionDate datetime,
OriginalID nvarchar(255),
-- OriginalID nvarchar(15),
DocumentReference nVarChar(255),
Type nVarchar(50),
AccountName nvarchar(255),
Debit decimal(18,6),
Credit decimal(18,6),
DocRef int,DocType int,
AccountID int,
Balance nvarchar(50),
DocumentBalance nVarChar(50),
TranID integer,
Narration nvarchar(2000),
ChequeInfo nvarchar(255),
HighLight int
)
/* insert all the dates between from date and to date */
while datediff(dd,dbo.stripdatefromtime(@fromdate),dbo.stripdatefromtime(@todate))>=0
begin
insert into #dates(transactiondate)
values(dbo.stripdatefromtime(@fromdate))
set @fromdate = dateadd(dd,1,dbo.stripdatefromtime(@fromdate))
print @fromdate
end
/*open a cursor */
declare dates cursor for
select distinct transactiondate from #dates order by transactiondate
open dates

fetch dates into @transactiondate
while @@fetch_status = 0
begin
set @txncount = 0
select @txncount = count(1) from #tempreport
where dbo.stripdatefromtime(transactiondate) = @transactiondate

if @txncount > 0
begin
insert into #tempreport1(TransactionDate ,OriginalID ,DocumentReference ,Type ,AccountName ,Debit ,Credit ,DocRef ,DocType ,
AccountID ,Balance ,DocumentBalance ,TranID ,Narration,ChequeInfo,HighLight)
select TransactionDate ,OriginalID ,DocumentReference ,Type ,AccountName ,Debit ,Credit ,DocRef ,DocType ,
AccountID ,Balance ,DocumentBalance ,TranID ,Narration ,ChequeInfo ,HighLight from #tempreport where
dbo.stripdatefromtime(transactiondate) = @transactiondate
AND LTRIM(RTRIM(ACCOUNTNAME)) NOT IN (N'Total',N'Closing Balance')
order by transactiondate

SET @CREDITBALANCE = 0
SET @DEBITBALANCE = 0
SELECT @CURR_TRANSACTIONDATE = (SELECT MAX(TRANSACTIONDATE) FROM #TEMPREPORT1)
select @DEBITBALANCE = sum(ISNULL(DEBIT,0)),@CREDITBALANCE = sum(ISNULL(CREDIT,0)) FROM
#TEMPREPORT1 WHERE dbo.stripdatefromtime(TRANSACTIONDATE) = dbo.stripdatefromtime(@CURR_TRANSACTIONDATE)

IF @CREDITBALANCE > @DEBITBALANCE
BEGIN
insert into #tempreport1 (type,DEBIT,HIGHLIGHT)
values('Closing Balance',@CREDITBALANCE-@DEBITBALANCE,1)

/* INSERT OVER ALL TOTAL */
INSERT INTO #TEMPREPORT1 (type,DEBIT,CREDIT,HIGHLIGHT)
values( 'Total', @CREDITBALANCE ,@CREDITBALANCE,1)

if dbo.stripdatefromtime(@todate) <> @transactiondate
begin
insert into #tempreport1 (transactiondate,type,credit,HIGHLIGHT)
values(DATEADD(DD,1,@CURR_TRANSACTIONDATE),
'Opening Balance',@CREDITBALANCE-@DEBITBALANCE,1)
end
END
ELSE IF @CREDITBALANCE < @DEBITBALANCE
BEGIN
insert into #tempreport1 (type,CREDIT,HIGHLIGHT)
values('Closing Balance',@DEBITBALANCE-@CREDITBALANCE,1)

/* INSERT OVER ALL TOTAL */
INSERT INTO #TEMPREPORT1 (type,DEBIT,CREDIT,HIGHLIGHT)
values('Total', @DEBITBALANCE ,@DEBITBALANCE,1)

if dbo.stripdatefromtime(@todate) <> @transactiondate
begin
insert into #tempreport1 (transactiondate,type,DEBIT,HIGHLIGHT)
values(DATEADD(DD,1,@CURR_TRANSACTIONDATE),
'Opening Balance',@DEBITBALANCE-@CREDITBALANCE,1)
end
END
ELSE
BEGIN
insert into #tempreport1 (type,CREDIT,HIGHLIGHT)
values('Closing Balance',0,1)

/* INSERT OVER ALL TOTAL */
INSERT INTO #TEMPREPORT1 (type,DEBIT,CREDIT,HIGHLIGHT)
values('Total', 0 ,0,1)

if dbo.stripdatefromtime(@todate) <> @transactiondate
begin
insert into #tempreport1 (transactiondate,type,DEBIT,HIGHLIGHT)
values(DATEADD(DD,1,@CURR_TRANSACTIONDATE),
'Opening Balance',0,1)
end
END

end
else
begin
SET @CREDITBALANCE = 0
SET @DEBITBALANCE = 0
SELECT @CURR_TRANSACTIONDATE = (SELECT MAX(TRANSACTIONDATE) FROM #TEMPREPORT1)
select @DEBITBALANCE = sum(ISNULL(DEBIT,0)),@CREDITBALANCE = sum(ISNULL(CREDIT,0)) FROM
#TEMPREPORT1 WHERE dbo.stripdatefromtime(TRANSACTIONDATE) = dbo.stripdatefromtime(@CURR_TRANSACTIONDATE)

IF @CREDITBALANCE > @DEBITBALANCE
BEGIN
insert into #tempreport1 (type,DEBIT,HIGHLIGHT)
values('Closing Balance',@CREDITBALANCE-@DEBITBALANCE,1)

/* INSERT OVER ALL TOTAL */
INSERT INTO #TEMPREPORT1 (type,DEBIT,CREDIT,HIGHLIGHT)
values('Total', @CREDITBALANCE ,@CREDITBALANCE,1)

if dbo.stripdatefromtime(@todate) <> @transactiondate
begin
insert into #tempreport1 (transactiondate,type,credit,HIGHLIGHT)
values(DATEADD(DD,1,@CURR_TRANSACTIONDATE),
'Opening Balance',@CREDITBALANCE-@DEBITBALANCE,1)
end
END
ELSE IF @CREDITBALANCE < @DEBITBALANCE
BEGIN
insert into #tempreport1 (type,CREDIT,HIGHLIGHT)
values('Closing Balance',@DEBITBALANCE-@CREDITBALANCE,1)

/* INSERT OVER ALL TOTAL */
INSERT INTO #TEMPREPORT1 (type,DEBIT,CREDIT,HIGHLIGHT)
values('Total', @DEBITBALANCE ,@DEBITBALANCE,1)

if dbo.stripdatefromtime(@todate) <> @transactiondate
begin
insert into #tempreport1 (transactiondate,type,DEBIT,HIGHLIGHT)
values(DATEADD(DD,1,@CURR_TRANSACTIONDATE),
'Opening Balance',@DEBITBALANCE-@CREDITBALANCE,1)
end
END
ELSE
BEGIN
insert into #tempreport1 (type,CREDIT,HIGHLIGHT)
values('Closing Balance',0,1)

/* INSERT OVER ALL TOTAL */
INSERT INTO #TEMPREPORT1 (type,DEBIT,CREDIT,HIGHLIGHT)
values('Total', 0 ,0,1)

if dbo.stripdatefromtime(@todate) <> @transactiondate
begin
insert into #tempreport1 (transactiondate,type,DEBIT,HIGHLIGHT)
values(DATEADD(DD,1,@CURR_TRANSACTIONDATE),
'Opening Balance',0,1)
end
END
end
fetch next from dates into @transactiondate
end
update #tempreport1 set transactiondate = null
where ltrim(rtrim(isnull(OriginalID,N''))) <> N''

update #tempreport1 set type = accountname,accountname = null
where row_num = 1


Select 'Document Date'=dbo.stripdatefromtime(TransactionDate),'Document ID'=OriginalID,
'Document Reference'=DocumentReference,'Description'=Type,'Particular'=AccountName,'Debit'=Debit,'Credit'=Credit,
'DocRef'= case when [DocType]=37 or ([DocType]=26 and [DocRef]= 2)then TranID else  DocRef end,
'DocType'=DocType,'AccountID'=AccountID,'Balance'=Balance,'Document Balance'=DocumentBalance,'Narration'=Narration,'Cheque Info' = ChequeInfo, 'High Light'=HighLight from #TempReport1 Order By row_num

DROP TABLE #TEMPREPORT1
DROP TABLE #DATES
close dates
deallocate dates
end
DROP TABLE #TEMPREPORT
ExitProc:

