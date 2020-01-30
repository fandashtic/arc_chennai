CREATE procedure sp_acc_view_ARVAbstract(@DocumentID int)
as
select dbo.getvoucherprefix('Accounts Receivable Voucher') + cast(ARVID as nVarchar(15)), 
ARVDate,Amount,Status,PartyAccountID,dbo.getAccountName(PartyAccountID),ARVRemarks,ApprovedBy,
dbo.getAccountName(ApprovedBy),DocRef,TotalSalesTax,DocSerialType,CancellationRemarks,RefDocID
from ARVAbstract where DocumentID = @DocumentID
