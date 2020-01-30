CREATE Procedure sp_acc_BankReconciliationUncleared(@FromDate datetime,@ToDate datetime,@AccountID Int)
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
Declare @ActualBankDate Datetime
Declare @ChequeInfo nvarchar(255)
--
Create table #TempReport(TransactionDate datetime, OriginalID nvarchar(15),Type nVarchar(50),
AccountName nvarchar(50),Debit decimal(18,6),Credit decimal(18,6),DocRef int,DocType int,
AccountID int,BRSCheck int,TranID integer,HighLight int,ActualBankDate datetime,ChequeInfo nVarchar(255))

Declare ScanJournal Cursor Keyset For
Select TransactionID,Debit,Credit ,case when DocumentType in (26,37) then 
dbo.GetOriginalID(isnull(DocumentNumber,0),DocumentType) else dbo.GetOriginalID(DocumentReference,DocumentType) end,
dbo.GetDescription(DocumentReference,DocumentType), DocumentReference,DocumentType,BRSCheck,ActualBankDate,dbo.sp_acc_GetChequeInfo(DocumentReference,DocumentType,ReferenceNumber) from 
GeneralJournal where GeneralJournal.AccountID=@AccountID and (dbo.stripdatefromtime(TransactionDate) 
between dbo.stripdatefromtime(@FromDate) and dbo.stripdatefromtime(@ToDate)) and 
documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) and isnull(status,0) <> 128 
and isnull(status,0) <> 192 and isnull(BRSCheck,0)=0 order by TransactionDate
Open ScanJournal
Fetch From ScanJournal Into @TranID,@Debit,@Credit,@OriginalID,@Description, @RefNumber,@Doctype,@BRSCheck,@ActualBankDate,@ChequeInfo
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
			insert into #TempReport
			Select dbo.stripdatefromtime(TransactionDate),@OriginalID,@Description,
			AccountName,0,@Credit,DocumentReference,DocumentType,GeneralJournal.AccountID,@BRSCheck,
			@TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),@ActualBankDate,@ChequeInfo from GeneralJournal,AccountsMaster where 
			GeneralJournal.AccountID not in(select AccountID from generaljournal
		 	where TransactionID=@TranID and credit <> 0 and DocumentReference = @RefNumber
			and DocumentType =@DocType) and GeneralJournal.AccountID = AccountsMaster.AccountID
			and TransactionID=@TranID and Debit<>0 and DocumentType = @doctype
		End
		Else If @Count>1
		Begin
			insert into #TempReport
			Select dbo.stripdatefromtime(TransactionDate),@OriginalID,@Description,
			AccountName,Credit,Debit, DocumentReference,DocumentType,GeneralJournal.AccountID,@BRSCheck,
			@TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),@ActualBankDate,@ChequeInfo 
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
			insert into #TempReport
			Select dbo.stripdatefromtime(TransactionDate),@OriginalID,@Description,
			AccountName, @Debit,0, DocumentReference,DocumentType,GeneralJournal.AccountID,@BRSCheck,
			@TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),@ActualBankDate,@ChequeInfo from GeneralJournal,AccountsMaster
			where GeneralJournal.AccountID not in(select AccountID from generaljournal
			where TransactionID=@TranID and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) 
			and GeneralJournal.AccountID = AccountsMaster.AccountID and TransactionID=@TranID and Credit<>0
			and DocumentType = @doctype 
		End
		Else if @Count>1
		Begin
			insert into #TempReport
			Select dbo.stripdatefromtime(TransactionDate),@OriginalID,@Description,
			AccountName, Credit,Debit,DocumentReference,DocumentType, GeneralJournal.AccountID,@BRSCheck,
			@TranID,dbo.GetLedgerDynamicSetting(DocumentType,DocumentReference),@ActualBankDate,@ChequeInfo from 
			GeneralJournal,AccountsMaster where GeneralJournal.AccountID 
			not in(select AccountID from generaljournal where TransactionID=@TranID 
			and debit <> 0 and DocumentReference = @RefNumber and DocumentType =@DocType) and 
			GeneralJournal.AccountID = AccountsMaster.AccountID and 
			TransactionID=@TranID and DocumentType = @doctype and Credit<>0 --and Debit=0 			
		End
	End
	Fetch Next From scanJournal into @TranID, @Debit, @Credit,@OriginalID,@Description, @RefNumber,@Doctype,@BRSCheck,@ActualBankDate,@ChequeInfo
End
Close ScanJournal
Deallocate ScanJournal

Select 'Document Date'=dbo.stripdatefromtime(TransactionDate),'Document ID'=OriginalID,
'Description'=Type,'Particular'=AccountName,'Debit'=Debit,'Credit'=Credit,
'DocRef'= case when [DocType]=37 then TranID else  DocRef end,
'DocType'=DocType,'AccountID'=AccountID,BRSCheck,TranID,'High Light'=HighLight,ActualBankDate,'Cheque Info' = ChequeInfo from #TempReport 
Drop table #TempReport
