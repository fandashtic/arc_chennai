CREATE procedure sp_acc_prn_arvabstract(@DocumentID int)
as
select dbo.getvoucherprefix('Accounts Receivable Voucher') + cast(ARVID as nVarchar(15)), ARVDate,Amount,Status,PartyAccountID,
dbo.getAccountName(PartyAccountID),ARVRemarks,ApprovedBy,dbo.getAccountName(ApprovedBy),TotalSalesTax 
from ARVAbstract where DocumentID = @DocumentID

