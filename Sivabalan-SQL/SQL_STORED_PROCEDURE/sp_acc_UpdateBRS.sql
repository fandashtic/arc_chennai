CREATE Procedure sp_acc_UpdateBRS(@TranID Int,@BRSCheck Int,@actualbankdate datetime)
As
Update GeneralJournal
Set BRSCheck=@BRSCheck,
ActualBankDate= @actualbankdate 
Where TransactionID=@TranID


