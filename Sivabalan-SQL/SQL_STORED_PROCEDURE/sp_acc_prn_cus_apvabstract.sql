CREATE procedure sp_acc_prn_cus_apvabstract(@apvid integer)
as
declare @prefix nvarchar(10)
select @prefix =Prefix from VoucherPrefix
where TranID =N'ACCOUNTS PAYABLE VOUCHER'

select 
"APV ID" = @prefix + cast(APVID as nvarchar(10)),
"APV Date" = APVDate,
"Party Name" = dbo.getaccountname(PartyAccountID),
"Bill No " = BillNo,
"Bill Date" = BillDate,
"Bill Amount" = BillAmount,
"Amount Approved" = AmountApproved,
"Expense For" = isnull(dbo.getaccountname(isnull(Expensefor,0)),N''),
"Approved By" = dbo.getaccountname(isnull(Approvedby,0)),
"Narration" = APVRemarks,
"Discount" = othervalue,
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
"Document Reference" = DocumentReference,
"Document Type" = DocSerialType
from
APVAbstract where [APVAbstract].[DocumentID]= @apvid




