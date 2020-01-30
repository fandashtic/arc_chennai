create procedure sp_acc_getrefdetails(@NewRefID Int)
as
Select ReferenceNo,Remarks
from ManualJournal where NewRefID = @NewRefID


