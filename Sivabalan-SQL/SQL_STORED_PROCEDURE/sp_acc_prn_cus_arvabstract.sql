CREATE procedure sp_acc_prn_cus_arvabstract(@DocumentID int)  
as  
select 
	"ARV Id" = dbo.getvoucherprefix('Accounts Receivable Voucher') + cast(ARVID as nVarchar(15)),
	"ARV Date" = ARVDate,
	"Net Amount" = Amount,
	"Status" = Status,
	"Party Account ID" = PartyAccountID,
	"Party" = dbo.getAccountName(PartyAccountID),
	"Narration" = ARVRemarks,
	"Approver ID" = ApprovedBy,
	"Approved By" = dbo.getAccountName(ApprovedBy),
	"Total Sales Tax" = TotalSalesTax,
	"Total" = Amount -  TotalSalesTax,
	"Cancellation Remarks" =
	Case 
		When Isnull(Status,0) & 192 <> 0 then dbo.LookupDictionaryItem('Cancellation Remarks :',Default) 
		Else '' 
	End,
	"Reason for Cancellation" = 
	Case 
		When Isnull(Status,0) & 192 <> 0 then CancellationRemarks
		Else '' 
	End,
	"Document Reference" = Docref,
	"Document Type" = DocSerialType
from 
	ARVAbstract 
where
	DocumentID = @DocumentID  
  





