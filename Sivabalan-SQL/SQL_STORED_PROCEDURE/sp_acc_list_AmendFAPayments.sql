CREATE procedure sp_acc_list_AmendFAPayments(@PartyID Int, @PaymentID Int)                      
as                      
Select "Document ID" = (VoucherPrefix.Prefix + cast(DocumentID as nvarchar)),                      
"Document Date" = DocumentDate, NoteValue, Balance, CreditID, "Type" = 2 , 'Credit Note',                      
 0, DocRef,Memo from CreditNote, VoucherPrefix where Others = @PartyID and Balance > 0 and                      
VoucherPrefix.TranID = N'CREDIT NOTE' and                      
CreditID Not in (Select DocumentID From PaymentDetail                       
Where PaymentID = @PaymentID And DocumentType = 2)                     
                      
Union All                      
Select "Document ID" = FullDocID, "Document Date" = DocumentDate, Value,Balance, DocumentID,                       
"Type" = 3,'Payments', Null,DocRef,Narration from Payments where Balance > 0 and                      
Others = @PartyID and (IsNull(Status, 0) & 192) = 0  and                      
DocumentID Not in (Select DocumentID From PaymentDetail                   
Where PaymentID = @PaymentID And DocumentType = 3)And               
DocumentID Not In (@PaymentID)     
                      
Union All                      
Select "Document ID" = VoucherPrefix.Prefix + CAST(APVID as nvarchar),                       
"Document Date" = APVDate, AmountApproved,Balance, DocumentID, "Type" = 4,'APV',                      
0,"Remarks"=BillNo,APVRemarks                      
from APVAbstract, VoucherPrefix where IsNull(Status, 0) & 128 = 0 and                      
PartyAccountID = @PartyID and ISNULL(Balance, 0) > 0 and                      
VoucherPrefix.TranID = N'Accounts Payable Voucher' and                      
DocumentID Not in (Select DocumentID From PaymentDetail                       
Where PaymentID = @PaymentID And DocumentType = 4)                     
                      
Union All                      
Select "Document ID" = VoucherPrefix.Prefix + CAST(ARVID as nvarchar),                       
"Document Date" = ARVDate, Amount,Balance, DocumentID, "Type" = 6,'ARV',                      
0,"Remarks"=DocRef,ARVRemarks                     
from ARVAbstract, VoucherPrefix where IsNull(Status, 0) & 128 = 0 and                      
PartyAccountID = @PartyID and ISNULL(Balance, 0) > 0 and                      
VoucherPrefix.TranID = N'Accounts Receivable Voucher' and                      
DocumentID Not in (Select DocumentID From PaymentDetail                       
Where PaymentID = @PaymentID And DocumentType = 6)                     
                      
Union All                      
Select "Document ID" = (cast(VoucherPrefix.Prefix as nvarchar) + cast(DocumentID as nvarchar)),                       
"DocumentDate" = DocumentDate, NoteValue,                       
Balance, DebitID, "Type" = 5,                       
case Flag                      
when 0 then                      
'Debit Note'                      
when 1 then                      
'Bank Charges'                      
when 2 then                      
'Bounced'                      
end, 0, DocRef,Memo                      
from DebitNote, VoucherPrefix                      
where Balance > 0 and                       
Others = @PartyID and                       
VoucherPrefix.TranID = N'DEBIT NOTE'  and                      
DebitID Not in (Select DocumentID From PaymentDetail                       
Where PaymentID = @PaymentID And DocumentType = 5)                    
                      
Union All                      
Select "Document ID" = FullDocID, "Document Date" = DocumentDate, Value, Balance, DocumentID,                      
"Type" = 7, 'Collections',Null,DocReference,Narration from Collections where Balance > 0 and                      
Others = @PartyID and (IsNull(Status, 0) & 192) = 0 and                      
DocumentID Not in (Select DocumentID From PaymentDetail  
Where PaymentID = @PaymentID And DocumentType = 7)              
  
Union All  
Select 'DocumentID' = (VoucherPrefix.Prefix + Cast(DocumentID as nvarchar)),  
DocumentDate,Amount,Balance,NewRefID,'DocType'=Case When PrefixType=1 Then 8 Else 9 End,'Manual Journal - New Reference',  
Null,ReferenceNo,Remarks from ManualJournal,VoucherPrefix where AccountID = @PartyID And isnull(Status,0) <> 192 and isnull(Status,0) <> 128  
and isnull(Balance ,0) <> 0 And VoucherPrefix.Prefix = N'MANUAL JOURNAL' And NewRefID Not In (Select DocumentID from PaymentDetail   
Where PaymentID = @PaymentID And DocumentType In (8,9)) 
