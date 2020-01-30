CREATE Procedure sp_acc_BankReconciliationStatement(@FromDate datetime,@ToDate datetime,@AccountID Int)    
As    
Declare @TRANID INT    
Declare @AccountCode INT    
Declare @AccountName nVarchar(30)    
Declare @DEBIT decimal(18,6)    
Declare @CREDIT decimal(18,6)    
Declare @OriginalID nvarchar(15)    
Declare @Description nvarchar(50)    
Declare @RefNumber nvarchar(50)    
Declare @DocType Int    
Declare @Count INT    
Declare @OpeningBalance Decimal(18,6)    
Declare @Balance Decimal(18,6)    
Declare @BRSCheck Int    
Declare @ClosingBalance Decimal(18,6)    
Declare @ActualDate Datetime  
Declare @ChequeInfo nVarchar(255)  
Declare @ToDatePair Datetime  
  
Set @ToDate = dbo.stripdatefromtime(@ToDate)  
Set @ToDatePair=DateAdd(s,0-1,DateAdd(d,1,@ToDate))    
  
Create table #TempReport(TransactionDate datetime, OriginalID nvarchar(15),Type nVarchar(50),    
AccountName nvarchar(50),Debit decimal(18,6),Credit decimal(18,6),DocRef int,DocType int,    
AccountID int,BRSCheck int,TranID integer,HighLight int,ActualDate datetime,ChequeInfo nvarchar(255))    
    
Create table #TempReport1(TransactionDate datetime, OriginalID nvarchar(15),Type nVarchar(50),    
AccountName nvarchar(50),Debit decimal(18,6),Credit decimal(18,6),DocRef int,DocType int,    
AccountID int,BRSCheck int,TranID integer,HighLight int,ActualDate datetime,ChequeInfo nvarchar(255))    
    
Create table #TempReport2(TransactionDate datetime, OriginalID nvarchar(15),Type nVarchar(50),    
AccountName nvarchar(50),Debit decimal(18,6),Credit decimal(18,6),DocRef int,DocType int,    
AccountID int,BRSCheck int,TranID integer,HighLight int,ActualDate datetime,ChequeInfo nvarchar(255))    
    
Declare @CurDate DateTime    
--Set @CurDate=dbo.stripdatefromtime(getdate())    
    
Set @CurDate=dbo.stripdatefromtime(@ToDate)    
Set @ClosingBalance = dbo.sp_acc_getaccountBalance(@AccountID,@CurDate)    
insert into #TempReport    
Select @Todate ,N'',N'',dbo.LookupDictionaryItem('Ledger Balance:',Default),case when isnull(@ClosingBalance,0) > 0 then isnull(@ClosingBalance,0) else 0 end ,case when isnull(@ClosingBalance,0)  < 0 then abs(isnull(@ClosingBalance,0)) else 0 end,N'',N'',N'',N'',N'',1,NULL,N''    
    
Declare ScanJournal Cursor Keyset For    
Select TransactionID,Debit,Credit ,case when DocumentType in (26,37) then     
dbo.GetOriginalID(isnull(DocumentNumber,0),DocumentType) else dbo.GetOriginalID(DocumentReference,DocumentType) end,    
dbo.GetDescription(DocumentReference,DocumentType), DocumentReference,DocumentType,BRSCheck,ActualBankDate,dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,ReferenceNumber) from     
GeneralJournal where GeneralJournal.AccountID=@AccountID and   
(TransactionDate between @FromDate and @ToDatePair) And     
(Isnull(ActualBankDate,DateAdd(d,1,@ToDatePair)) not between @FromDate and @ToDatePair) And  
documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128     
and isnull(status,0) <> 192 order by TransactionDate    
Open ScanJournal    
Fetch From ScanJournal Into @TranID,@Debit,@Credit,@OriginalID,@Description, @RefNumber,@Doctype,@BRSCheck,@ActualDate,@ChequeInfo    
while @@Fetch_Status=0    
Begin    
 If @Debit=0    
 Begin    
  If @DocType=37    
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
   insert into #TempReport1    
   Select TransactionDate,@OriginalID,@Description,    
   AccountName,0,@Credit,DocumentReference,DocumentType,GeneralJournal.AccountID,@BRSCheck,    
   @TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),@ActualDate,@ChequeInfo from GeneralJournal,AccountsMaster where     
   GeneralJournal.AccountID not in(select AccountID from generaljournal    
   where TransactionID=@TranID and credit <> 0 and DocumentReference = @RefNumber    
   and DocumentType =@DocType) and GeneralJournal.AccountID = AccountsMaster.AccountID    
   and TransactionID=@TranID and Debit<>0 and DocumentType = @doctype    
  End    
  Else If @Count>1    
  Begin    
   insert into #TempReport1    
   Select TransactionDate,@OriginalID,@Description,    
   AccountName,Credit,Debit, DocumentReference,DocumentType,GeneralJournal.AccountID,@BRSCheck,    
   @TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),@ActualDate,@ChequeInfo    
   from GeneralJournal,AccountsMaster where GeneralJournal.AccountID    
   not in(select AccountID from generaljournal where TransactionID=@TranID     
   and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and     
   GeneralJournal.AccountID = AccountsMaster.AccountID and     
   TransactionID=@TranID and Debit<>0 and DocumentType = @doctype    
  End    
 End    
 Else if @credit=0     
 Begin    
  If @DocType=37    
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
   insert into #TempReport2    
   Select TransactionDate,@OriginalID,@Description,    
   AccountName, @Debit,0, DocumentReference,DocumentType,GeneralJournal.AccountID,@BRSCheck,    
   @TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),@ActualDate,@ChequeInfo from GeneralJournal,AccountsMaster    
   where GeneralJournal.AccountID not in(select AccountID from generaljournal    
   where TransactionID=@TranID and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)     
   and GeneralJournal.AccountID = AccountsMaster.AccountID and TransactionID=@TranID and Credit<>0    
   and DocumentType = @doctype     
  End    
  Else if @Count>1    
  Begin    
   insert into #TempReport2    
   Select TransactionDate,@OriginalID,@Description,    
   AccountName, Credit,Debit,DocumentReference,DocumentType, GeneralJournal.AccountID,@BRSCheck,    
   @TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),@ActualDate,@ChequeInfo from     
   GeneralJournal,AccountsMaster where GeneralJournal.AccountID 
 not in(select AccountID from generaljournal where TransactionID=@TranID     
   and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and     
   GeneralJournal.AccountID = AccountsMaster.AccountID and     
   TransactionID=@TranID and DocumentType = @doctype and Credit<>0 --and Debit=0        
  End    
 End    
 Fetch Next From scanJournal into @TranID, @Debit, @Credit,@OriginalID,@Description, @RefNumber,@Doctype,@BRSCheck,@ActualDate,@ChequeInfo    
End    
Close ScanJournal    
Deallocate ScanJournal    
    
insert into #TempReport    
Select Null ,N'',dbo.LookupDictionaryItem('Add:',Default),N'',Null ,Null,N'',N'',N'',N'',N'',1,Null,N''    
Insert into #TempReport    
Select TransactionDate,OriginalID,    
Type,AccountName,Credit,0,case when [DocType]=37 then TranID else  DocRef end,    
DocType,AccountID,BRSCheck,TranID,'High Light'=HighLight,ActualDate,ChequeInfo from #TempReport1     
    
insert into #TempReport    
Select Null ,N'',dbo.LookupDictionaryItem('Less:',Default),N'',Null ,Null,N'',N'',N'',N'',N'',1,Null,N''    
Insert into #TempReport    
Select TransactionDate,OriginalID,    
Type,AccountName,0,debit,case when [DocType]=37 then TranID else  DocRef end,    
DocType,AccountID,BRSCheck,TranID,'High Light'=HighLight,ActualDate,ChequeInfo from #TempReport2    
    
Declare @BankBalance Decimal(18,6)    
Set @BankBalance=(Select sum(isnull(Debit,0)-isnull(Credit,0)) from #TempReport)    
Insert #TempReport    
Select Null ,N'',N'',dbo.LookupDictionaryItem('Total:',Default),sum(Debit) ,sum(Credit),N'',N'',N'',N'',N'',1,Null,N'' from #Tempreport    
    
Insert #TempReport    
Select @Todate ,N'',N'',dbo.LookupDictionaryItem('Bank Balance:',Default),case when isnull(@BankBalance,0) > 0 then isnull(@BankBalance,0) else 0 end ,case when isnull(@BankBalance,0)  < 0 then abs(isnull(@BankBalance,0)) else 0 end,N'',N'',N'',N'',N'',1,Null,N''    
    
Select 'Document Date'=dbo.stripdatefromtime(TransactionDate),'Document ID'=OriginalID,    
'Description'=Type,'Particular'=AccountName,'Debit'=Debit,'Credit'=Credit,    
'DocRef'= case when [DocType]=37 then TranID else  DocRef end,    
'DocType'=DocType,'AccountID'=AccountID,BRSCheck,TranID,'High Light'=HighLight,ActualDate,'Cheque Info' = ChequeInfo from #TempReport     
Drop table #TempReport    
Drop table #TempReport1    
Drop table #TempReport2 
