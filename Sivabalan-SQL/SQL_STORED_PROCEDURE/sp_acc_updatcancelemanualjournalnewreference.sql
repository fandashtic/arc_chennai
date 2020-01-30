create procedure sp_acc_updatcancelemanualjournalnewreference(@NewRefID Int,
@AmountAdjusted Decimal(18,6))
as
Update ManualJournal
Set Balance = Balance + @AmountAdjusted
Where NewRefID = @NewRefID
 






