CREATE Procedure sp_acc_InsertJournalDenomination (@TranID INT, @Denomination nVarChar(100))
As
If Not Exists(Select Denominations from JournalDenominations Where TransactionID = @TranID)
 Begin
  Insert JournalDenominations (TransactionID, Denominations)
  Values (@TranID, @Denomination)
 End
Else
 Begin
  Update JournalDenominations
  Set Denominations=@Denomination
  Where TransactionID=@TranID
 End
