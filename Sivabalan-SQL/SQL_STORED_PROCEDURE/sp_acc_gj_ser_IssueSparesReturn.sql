CREATE Procedure sp_acc_gj_ser_IssueSparesReturn(@DocumentID INT,@BackDate DateTime = Null)          
AS          
---------------------------Journal entry for Issue Spares Return-----------------------------  
DECLARE @BILLSRECEIVABLE INT          
DECLARE @SALESONDC INT          
DECLARE @ISSUETYPE INT          
          
SET @BILLSRECEIVABLE = 28           
SET @SALESONDC = 35          
SET @ISSUETYPE = 87          
          
DECLARE @IssueDate DateTime          
DECLARE @Value float          
DECLARE @TransactionID INT          
DECLARE @DocumentNumber INT          
          
Create Table #TempBackdatedAccountsIssueSpares(AccountID INT)          
        
Select @IssueDate = IssueDate from IssueAbstract,IssueDetail,SparesReturnInfo Where    
IssueAbstract.IssueID = IssueDetail.IssueID And IssueDetail.SerialNo = SparesReturnInfo.SerialNo And    
SparesReturnInfo.TransactionID = @DocumentID          
    
Select @Value = Sum(IsNull(SparesReturnInfo.Qty,0)*IsNull(IssueDetail.PurchasePrice,0)) from IssueDetail,SparesReturnInfo where     
IssueDetail.SerialNo = SparesReturnInfo.SerialNo And SparesReturnInfo.TransactionID = @DocumentID    
          
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
           
  Execute sp_acc_insertGJ @TransactionID,@SALESONDC,@IssueDate,@Value,0,@DocumentID,@ISSUETYPE,'Issue Spares Return',@DocumentNumber          
  Insert Into #TempBackdatedAccountsIssueSpares(AccountID) Values(@SALESONDC)          
           
  Execute sp_acc_insertGJ @TransactionID,@BILLSRECEIVABLE,@IssueDate,0,@Value,@DocumentID,@ISSUETYPE,'Issue Spares Return',@DocumentNumber          
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
