CREATE Procedure sp_acc_IsCashExistInPrevJournal(@AccountID INT,@TranID INT)
As
If Exists(Select * from GeneralJournal Where TransactionID=@TranID And AccountID=@AccountID)
 Begin
  Select 1,Debit,Credit from GeneralJournal 
  Where TransactionID=@TranID And AccountID=@AccountID 
  And DocumentType Not In (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
 End
Else
 Begin
  Select 0
 End
