CREATE Procedure sp_acc_gj_ser_IssueSparesCancel(@IssueID INT,@BackDate DateTime = Null)        
AS        
-------------------------Journal entry for Issue Spares Cancellation-------------------------        
DECLARE @BILLSRECEIVABLE INT        
DECLARE @SALESONDC INT        
DECLARE @ISSUETYPE INT        
        
SET @BILLSRECEIVABLE = 28         
SET @SALESONDC = 35        
SET @ISSUETYPE = 86        
        
DECLARE @IssueDate DateTime        
DECLARE @Value float        
DECLARE @TransactionID INT        
DECLARE @DocumentNumber INT        
        
Create Table #TempBackdatedAccountsIssueSpares(AccountID INT)        
        
Select @IssueDate = IssueDate from IssueAbstract where IssueID = @IssueID        
Select @Value = Sum((IsNull(IssuedQty,0)-IsNull(ReturnedQty,0))*IsNull(PurchasePrice,0)) from IssueDetail where IssueID = @IssueID        
        
If @Value <> 0        
 Begin        
  Begin Tran        
   Update DocumentNumbers SET DocumentID = DocumentID+1 where DocType = 24        
   Select @TransactionID = DocumentID-1 from DocumentNumbers where DocType = 24        
  Commit Tran        
  Begin Tran        
   Update DocumentNumbers SET DocumentID = DocumentID+1 where DocType = 51        
   Select @DocumentNumber = DocumentID-1 from DocumentNumbers where DocType = 51        
  Commit Tran        
         
  Execute sp_acc_insertGJ @TransactionID,@SALESONDC,@IssueDate,@Value,0,@IssueID,@ISSUETYPE,'Issue Spares Cancellation',@DocumentNumber        
  Insert Into #TempBackdatedAccountsIssueSpares(AccountID) Values(@SALESONDC)        
         
  Execute sp_acc_insertGJ @TransactionID,@BILLSRECEIVABLE,@IssueDate,0,@Value,@IssueID,@ISSUETYPE,'Issue Spares Cancellation',@DocumentNumber        
  Insert Into #TempBackdatedAccountsIssueSpares(AccountID) Values(@BILLSRECEIVABLE)        
 End        
        
If @BackDate Is Not Null          
Begin        
 DECLARE @TempAccountID INT        
 DECLARE ScanTempBackDatedAccountsIssue CURSOR KEYSET FOR        
 Select AccountID From #TempBackdatedAccountsIssueSpares        
 OPEN ScanTempBackDatedAccountsIssue        
 FETCH FROM ScanTempBackDatedAccountsIssue INTO @TempAccountID        
 WHILE @@FETCH_STATUS = 0        
 Begin        
  Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID        
  FETCH NEXT FROM ScanTempBackDatedAccountsIssue INTO @TempAccountID        
 End        
 CLOSE ScanTempBackDatedAccountsIssue        
 DEALLOCATE ScanTempBackDatedAccountsIssue        
End        
Drop Table #TempBackdatedAccountsIssueSpares 
