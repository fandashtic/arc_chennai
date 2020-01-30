CREATE Procedure sp_acc_BankReconciliationShowAll(@FromDate datetime,@ToDate datetime,@AccountID Int)  
As  
Declare @TRANID INT  
Declare @AccountCode INT  
Declare @AccountName nVarchar(30)  
Declare @DEBIT decimal(18,6)  
Declare @CREDIT decimal(18,6)  
Declare @OriginalID nvarchar(15)  
Declare @Description nvarchar(50)  
Declare @ChequeInfo nVarchar(255)  
Declare @RefNumber nvarchar(50)  
Declare @DocType Int  
Declare @Count INT  
Declare @OpeningBalance Decimal(18,6)  
Declare @Balance Decimal(18,6)  
Declare @BRSCheck Int  
Declare @ActualBankDate Datetime  
--  
Declare @f1 datetime  
Declare @f2 nvarchar(15)  
declare @f3 nvarchar(50)  
Declare @f4 nvarchar(50)  
Declare @f5 decimal(18,6)  
Declare @f6 decimal(18,6)  
Declare @f7 nvarchar(50)  
Declare @f8 int  
Declare @f9 int  
Declare @f10 int  
Declare @f11 decimal(18,6)  
Declare @f12 int  
Declare @F13 int  
Declare @F14 datetime  
Declare @f15 nvarchar(255)
--  
  
Create table #TempReport(TransactionDate datetime, OriginalID nvarchar(15),Type nVarchar(50),  
AccountName nvarchar(50),Debit decimal(18,6),Credit decimal(18,6), DocRef int,DocType int,  
AccountID int,BRSCheck int,Balance nvarchar(50),TranID int,HighLight int,ActualBankDate datetime,ChequeInfo nvarchar(255))  
  
If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@fromdate and AccountID = @AccountID)  
Begin  
 Select @OpeningBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId = @AccountID and Active=1  
End  
Else  
Begin   
 set @OpeningBalance= isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@fromdate and AccountID = @AccountID),0)  
End  
  
Insert #tempreport  
Select @FromDate,N'',N'',dbo.lookupdictionaryitem('Opening Balance',Default),case when @OpeningBalance > 0 then @OpeningBalance else 0 end ,case when @OpeningBalance  < 0 then abs(@OpeningBalance) else 0 end,N'',N'',N'',N'',N'',N'',1,Null,N''  
Set @Balance=isnull(@OpeningBalance,0)  
  
Declare ScanJournal Cursor Keyset For  
Select TransactionID,Debit,Credit ,case when DocumentType in (26,37) then   
dbo.GetOriginalID(isnull(DocumentNumber,0),DocumentType) else dbo.GetOriginalID(DocumentReference,DocumentType) end,  
dbo.GetDescription(DocumentReference,DocumentType), DocumentReference,DocumentType,BRSCheck,ActualBankDate,dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,ReferenceNumber) from   
GeneralJournal where GeneralJournal.AccountID=@AccountID and (dbo.stripdatefromtime(TransactionDate)   
between dbo.stripdatefromtime(@FromDate) and dbo.stripdatefromtime(@ToDate)) and   
documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128   
and isnull(status,0) <> 192 order by TransactionDate  
Open ScanJournal  
Fetch From ScanJournal Into @TranID,@Debit,@Credit,@OriginalID,@Description,@RefNumber,@Doctype,@BRSCheck,@ActualBankDate,@ChequeInfo
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
   Set @Balance=@Balance-@Credit  
   insert into #TempReport  
   Select dbo.stripdatefromtime(TransactionDate),@OriginalID,@Description,  
   AccountName,0,@Credit,DocumentReference,DocumentType,GeneralJournal.AccountID,@BRSCheck,  
   case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + dbo.lookupdictionaryitem('Cr',Default) else cast(@Balance as nvarchar(50)) + dbo.lookupdictionaryitem('Dr',Default) end,  
   @TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),ActualBankDate,@ChequeInfo from GeneralJournal,AccountsMaster where   
   GeneralJournal.AccountID not in(select AccountID from generaljournal  
   where TransactionID=@TranID and credit <> 0 and DocumentReference = @RefNumber  
   and DocumentType =@DocType) and GeneralJournal.AccountID = AccountsMaster.AccountID  
   and TransactionID=@TranID and Debit<>0 and DocumentType = @doctype  
  End  
  Else If @Count>1  
  Begin  
   Declare ScanCount Cursor Keyset For  
   Select dbo.stripdatefromtime(TransactionDate),@OriginalID,@Description,  
   AccountName,Credit,Debit, DocumentReference,DocumentType,GeneralJournal.AccountID,  
   @BRSCheck,(Credit-Debit),@TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),ActualBankDate,dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,ReferenceNumber)   
   from GeneralJournal,AccountsMaster where GeneralJournal.AccountID  
   not in(select AccountID from generaljournal where TransactionID=@TranID   
   and credit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and   
   GeneralJournal.AccountID = AccountsMaster.AccountID and   
   TransactionID=@TranID and Debit<>0 and DocumentType = @doctype  
   Open ScanCount  
   Fetch From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,@f14,@f15  
   while @@Fetch_Status=0  
   Begin  
    Set @Balance=@Balance + @f11  
    insert into #TempReport  
    Select @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + dbo.lookupdictionaryitem('Cr',Default) else cast(@Balance as nvarchar(50)) + dbo.lookupdictionaryitem('Dr',Default) end,@f12,@f13,@f14,@f15  
        
    Fetch Next From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,@f14,@f15  
   End  
   Close ScanCount  
   Deallocate ScanCount  
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
   Set @Balance=@Balance+@Debit     
   insert into #TempReport  
   Select dbo.stripdatefromtime(TransactionDate),@OriginalID,@Description,  
   AccountName, @Debit,0, DocumentReference,DocumentType,GeneralJournal.AccountID,@BRSCheck,  
   case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + dbo.lookupdictionaryitem('Cr',Default) else cast(@Balance as nvarchar(50)) + dbo.lookupdictionaryitem('Dr',Default) end,  
   @TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),ActualBankDate,@ChequeInfo from GeneralJournal,AccountsMaster  
   where GeneralJournal.AccountID not in(select AccountID from generaljournal  
   where TransactionID=@TranID and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType)   
   and GeneralJournal.AccountID = AccountsMaster.AccountID and TransactionID=@TranID and Credit<>0  
   and DocumentType = @doctype   
  End  
  Else if @Count>1  
  Begin  
   Declare ScanCount Cursor Keyset For  
   Select dbo.stripdatefromtime(TransactionDate),@OriginalID,@Description,  
   AccountName, Credit,Debit,DocumentReference,DocumentType, GeneralJournal.AccountID,  
   @BRSCheck,(Credit-Debit), @TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),ActualBankDate,dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,ReferenceNumber) from   
   GeneralJournal,AccountsMaster where GeneralJournal.AccountID   
   not in(select AccountID from generaljournal where TransactionID=@TranID   
   and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and   
   GeneralJournal.AccountID = AccountsMaster.AccountID and   
   TransactionID=@TranID and DocumentType = @doctype and Credit<>0 --and Debit=0      
   Open ScanCount  
   Fetch From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,@f14,@f15  
   while @@Fetch_Status=0  
   Begin  
    Set @Balance=@Balance + @f11  
    insert into #TempReport  
    Select @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,case when @Balance<0 then cast(abs(@Balance) as nvarchar(50)) + dbo.lookupdictionaryitem('Cr',Default) else cast(@Balance as nvarchar(50)) + dbo.lookupdictionaryitem('Dr',Default) end,@f12,@f13,@f14,@f15  
        
    Fetch Next From ScanCount Into @f1,@f2,@f3,@f4,@f5,@f6,@f7,@f8,@f9,@f10,@f11,@f12,@f13,@f14,@f15  
   End  
   Close ScanCount  
   Deallocate ScanCount  
  
  End  
 End  
 Fetch Next From scanJournal into @TranID, @Debit, @Credit,@OriginalID,@Description, @RefNumber,@Doctype,@BRSCheck,@ActualBankDate,@ChequeInfo  
End  
Close ScanJournal  
Deallocate ScanJournal  
  
Declare @ClosingBalance Decimal(18,6)  
Set @ClosingBalance=(Select sum(isnull(Debit,0)-isnull(Credit,0)) from #TempReport)  
Insert #TempReport  
Select Null ,N'',N'',dbo.lookupdictionaryitem('Total',Default),sum(Debit) ,sum(Credit),N'',N'',N'',N'',N'',N'',1,Null,N'' from #Tempreport  
  
Insert #TempReport  
Select @Todate ,N'',N'',dbo.lookupdictionaryitem('Closing Balance',Default),case when isnull(@ClosingBalance,0) > 0 then isnull(@ClosingBalance,0) else 0 end ,case when isnull(@ClosingBalance,0)  < 0 then abs(isnull(@ClosingBalance,0)) else 0 end,N'',N'',N'',N'',N'',N'',1,Null,N''  
  
Select 'Document Date'=dbo.stripdatefromtime(TransactionDate),'Document ID'=OriginalID,  
'Description'=Type,'Particular'=AccountName,'Debit'=Debit,'Credit'=Credit,  
'DocRef'= case when [DocType]=37 then TranID else  DocRef end,  
'DocType'=DocType,'AccountID'=AccountID,BRSCheck,Balance,TranID,'High Light'=HighLight,ActualBankDate,'Cheque Info' = ChequeInfo from #TempReport   
Drop table #TempReport 

