CREATE procedure sp_ser_invoiceablejobcard(@JobcardID as int)
as
Declare @IssueFlag int, @ClosedTaskFlag int

Select @IssueFlag = Count(J.JobcardID)
from JobCardSpares J
Where Isnull(J.PendingQty, 0) > 0 and J.JobCardID = @JobCardID and 
	Isnull(J.SpareStatus, 0) <> 2 

Select @ClosedTaskFlag = Count(*)
From JobcardTaskAllocation Where Taskstatus not in (2, 3, 4, 5) and JobCardId = @JobCardID 

Select IsNull(@IssueFlag,0) + IsNull(@ClosedTaskFlag,0)

