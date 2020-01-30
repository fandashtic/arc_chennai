CREATE Procedure sp_acc_rpt_ledger_all     
(    
 @FromDate Datetime,    
 @ToDate Datetime,    
 @DayWiseBreakup Integer,    
 @State Int=0    ,
 @Summary Int = 0
)    
As    
    
Declare @Accountid Integer    
declare @AccountName nVarchar(255)    
    
Create Table #AllLedgerAccounts    
(    
 row_num int identity(1,1),    
 TransactionDate datetime,    
 OriginalID nvarchar(15),    
 DocumentReference nVarChar(255),  
 Type nVarchar(255),    
 AccountName nvarchar(255),    
 Debit decimal(18,6),    
 Credit decimal(18,6),    
 DocRef int,DocType int,    
 AccountID int,    
 Balance nvarchar(50),    
 DocumentBalance nVarChar(50),  
 Narration nvarchar(2000),    
 Cheque_Info nvarchar(255),    
 HighLight int    
)    
    
Declare AccountsMaster cursor Dynamic for    
Select AccountID,AccountName from [AccountsMaster] where     
AccountID not in (22,23,88,89,500) order by [AccountName]     
    
Open AccountsMaster    
    
Fetch from Accountsmaster into @Accountid,@Accountname    
    
While @@Fetch_status = 0    
Begin    
 /* Insert the Account Name */    
 /* Few Accounts will have Accounts already padded with it , for Eg : Discount Account,    
    In Such cases if account is Suffixed, then it will be "Discount Account Account",    
    So use Patindex , check it and Suffix it    
 */    
 If Patindex(N'% '+(dbo.LookupDictionaryItem('Account',Default)),@Accountname) = 0    
 Begin    
  Insert into #AllLedgerAccounts (Type,Highlight)    
  Values(ltrim(rtrim(@AccountName)) + N' '+(dbo.LookupDictionaryItem('Account',Default)),1)    
 End    
 Else    
 Begin    
  Insert into #AllLedgerAccounts (Type,Highlight)    
  Values(@AccountName,1)    
 End    
     
 /* Insert the Ledger Details */    
 Insert into #AllLedgerAccounts    
 exec sp_acc_rpt_ledger @Fromdate, @Todate, @Accountid, @DayWiseBreakup, @State, @Summary
    
 /* Insert a Blank Line to differentiate Accounts*/     
 Insert into #AllLedgerAccounts (Highlight)    
 Values(5)    
    
 Fetch Next from Accountsmaster into @Accountid,@Accountname    
End    
    
Close AccountsMaster    
Deallocate AccountsMaster    
    
Select 'Document Date'=dbo.stripdatefromtime(TransactionDate),'Document ID'=OriginalID,                
'Document Reference'=DocumentReference,'Description'=Type,'Particular'=AccountName,'Debit'=Debit,'Credit'=Credit,                
'DocRef'= DocRef ,'DocType'=DocType,'AccountID'=AccountID,'Balance'=Balance,'Document Balance'=DocumentBalance,    
'Narration'=Narration,'Cheque Info'=Cheque_info,'High Light'=HighLight from #AllLedgerAccounts Order By row_num                
    
Drop table #AllLedgerAccounts 

