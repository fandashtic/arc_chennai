create procedure sp_acc_getnewrefdetails(@TransactionID Int,@AccountID Int)
as
Select NewRefID,ReferenceNo,Remarks
from ManualJournal where TransactionID = @TransactionID
and AccountID = @AccountID


