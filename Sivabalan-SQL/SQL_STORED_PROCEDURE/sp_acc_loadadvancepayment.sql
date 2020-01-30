CREATE procedure sp_acc_loadadvancepayment(@partyid integer)  
as  
Create table #AdvanceTable(Type nvarchar(20),FullDocID nvarchar(20),DocumentDate Datetime,  
TotalAmount Decimal(18,6),Balance Decimal(18,6),DocumentID Int,DocumentType Int,  
DocRef nvarchar(50),Remarks nvarchar(4000))   
   
Insert into #AdvanceTable   
select dbo.LookupDictionaryItem('Payments',Default),FullDocID,DocumentDate,Value,  
Balance,DocumentID,3,DocRef,Narration from Payments where Others = @partyid   
and (isnull(Status,0) & 64)= 0 and isnull(Balance,0)<> 0  
  
Insert into #AdvanceTable   
select dbo.LookupDictionaryItem('Debit Note',Default),(cast(VoucherPrefix.Prefix as nvarchar) + cast(DocumentID as nvarchar)),  
DocumentDate, NoteValue,Balance, DebitID,5,DocRef,Memo  
from DebitNote, VoucherPrefix  
where Balance > 0 and   
Others = @PartyID and   
(IsNull(Status,0) & 64) = 0 and  
VoucherPrefix.TranID = N'DEBIT NOTE'  
  
Select Type,FullDocID,DocumentDate,TotalAmount,Balance,  
DocumentID,DocumentType,DocRef,Remarks from #AdvanceTable   
order by DocumentDate  
Drop table #AdvanceTable 
