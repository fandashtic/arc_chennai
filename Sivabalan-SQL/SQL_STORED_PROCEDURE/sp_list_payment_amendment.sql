CREATE PROCEDURE [dbo].[sp_list_payment_amendment](@VendorID nvarchar(15), @PaymentID int)      
AS      
DECLARE @DocumentID nvarchar(15)      
DECLARE @DocumentDate datetime      
DECLARE @DocumentValue Decimal(18,6)      
DECLARE @Balance Decimal(18,6)      
DECLARE @DocSerial int      
DECLARE @DocumentType int      
DECLARE @DocDesc nvarchar(50)      
DECLARE @DocReference nvarchar(50)      
DECLARE @ExtraCol Decimal(18,6)      
DECLARE @Adjustment Decimal(18,6)      
DECLARE @AdjustedAmount Decimal(18,6)      
      
create table #PendingDocs(DocumentID nvarchar(15), DocumentDate datetime,       
     DocumentValue Decimal(18,6), Balance Decimal(18,6),       
     DocSerial int, DocumentType int, DocDesc nvarchar(50),       
     DocReference nvarchar(50), ExtraCol Decimal(18,6), Adjustment Decimal(18,6), AdjustedAmount Decimal(18,6))      
create table #PaymentDocs(DocumentID nvarchar(15), DocumentDate datetime,       
     DocumentValue Decimal(18,6), Balance Decimal(18,6),       
     DocSerial int, DocumentType int, DocDesc nvarchar(50),       
     DocReference nvarchar(50), ExtraCol Decimal(18,6), Adjustment Decimal(18,6), AdjustedAmount Decimal(18,6))      
      
insert into #PendingDocs      
select 
"DocumentID" = 
	Case IsNULL(GSTFullDocID,'')
	When '' then VoucherPrefix.Prefix + cast(AdjustmentReturnAbstract.DocumentID as nvarchar)
	Else
	IsNULL(GSTFullDocID,'')
	End,
--"DocumentID" = VoucherPrefix.Prefix +cast(AdjustmentReturnAbstract.DocumentID as nvarchar),         
"Document Date" = AdjustmentReturnAbstract.AdjustmentDate,         
"Value" = AdjustmentReturnAbstract.Value,         
AdjustmentReturnAbstract.Balance, AdjustmentID, "Type" = 1,         
dbo.LookupDictionaryItem(N'Purchase Return', Default), Null, Null, Null, Null      
from AdjustmentReturnAbstract, VoucherPrefix        
where AdjustmentReturnAbstract.Balance > 0 and        
AdjustmentReturnAbstract.VendorID = @VendorID and        
(IsNull(AdjustmentReturnAbstract.Status, 0) & 192) = 0 And -- Cancelled Purchase Return        
VoucherPrefix.TranID = N'STOCK ADJUSTMENT PURCHASE RETURN'         
--Removed since the billid is now stored in the detail table         
--and AdjustmentReturnAbstract.BillID *= BillAbstract.BillID         
        
union        
        
Select "Document ID" = VoucherPrefix.Prefix + Cast(DocumentID As nvarchar),        
"Document Date" = ClaimDate, ClaimValue,        
Balance, ClaimID, "Type" = 6, dbo.LookupDictionaryItem(N'Claims Note', Default), DocumentReference, Null, Null, Null      
From ClaimsNote, VoucherPrefix        
Where IsNull(Balance, 0) > 0 And        
VendorID = @VendorID And        
VoucherPrefix.TranID = N'CLAIMS NOTE'        
        
union        
        
select "Document ID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),         
"Document Date" = DocumentDate, NoteValue,         
Balance, DebitID, "Type" = 2, 
dbo.LookupDictionaryItem(Case IsNULL(Flag,0)
When 5 then  
N'Purchase Return'  
When 6 then  
N'Advance Payment'  
Else  
N'Debit Note'  
End, Default), DocRef, Null, Null, Null      
from DebitNote, VoucherPrefix        
where Balance > 0 and         
VendorID = @VendorID and         
VoucherPrefix.TranID = N'DEBIT NOTE'        
        
union        
        
select "Document ID" = FullDocID,         
"Document Date" = DocumentDate, Value, Balance, DocumentID, 
"Type" = 3, dbo.LookupDictionaryItem(N'Payments', Default), N'', Null, Null, Null      
from Payments        
where Balance > 0        
and VendorID = @VendorID         
And (IsNull(Status, 0) & 192) = 0 --Cancelled Payments        
        
union        
        
select "Document ID" = case         
when BillReference is null then        
VoucherPrefix.Prefix         
else        
BAPrefix.Prefix        
end        
+ cast(DocumentID as nvarchar), "Document Date" = BillDate,         
Value + TaxAmount + AdjustmentAmount, Balance, BillID, "Type" = 4,         
dbo.LookupDictionaryItem(case         
when BillReference is null then        
N'Bill'        
else        
N'Bill Amendment'        
end, Default),        
BillAbstract.InvoiceReference, Null, Null, Null      
from BillAbstract, VoucherPrefix, VoucherPrefix BAPrefix        
where Balance > 0 and        
VendorID = @VendorID and         
IsNull(Status, 0) & 128 = 0 and        
VoucherPrefix.TranID = N'BILL' and        
BAPrefix.TranID = N'BILL AMENDMENT'        
        
union        
        
select "Document ID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),         
"Document Date" = DocumentDate, NoteValue,      
Balance, CreditID, "Type" = 5, 
dbo.LookupDictionaryItem(Case IsNULL(Flag,0)  
When 7 then  
N'Bill'  
Else  
N'Credit Note'  
End, Default), DocRef, Null, Null, Null      
from CreditNote, VoucherPrefix        
where VendorID = @VendorID and        
Balance > 0 and        
VoucherPrefix.TranID = N'CREDIT NOTE'        
        
Order by "Document Date"        
      
insert into #PaymentDocs      
select OriginalID, DocumentDate, DocumentValue, AdjustedAmount, DocumentID, DocumentType,       
dbo.LookupDictionaryItem(Case isnull(DocumentType,0) When 5 Then N'Credit Note'      
    when 0 then N'Bill Amendment'    
    When 4 Then N'Bill'      
    When 3 Then N'Payments'      
    When 1 Then N'Purchase Return'      
    When 6 Then N'Claims'      
    When 2 Then N'Debit Note' end, Default), DocumentReference, ExtraCol, Adjustment, AdjustedAmount      
from PaymentDetail      
where PaymentID = @PaymentID      
      
DECLARE ScanPayments CURSOR FOR      
Select  DocumentID, DocumentDate, DocumentValue, Balance, DocSerial, DocumentType,       
 DocDesc, DocReference, ExtraCol, Adjustment, AdjustedAmount      
From #PaymentDocs      
      
Open ScanPayments      
Fetch From ScanPayments Into @DocumentID, @DocumentDate, @DocumentValue, @Balance, @DocSerial,       
        @DocumentType, @DocDesc, @DocReference, @ExtraCol, @Adjustment, @AdjustedAmount      
While @@Fetch_Status = 0      
Begin      
 IF (Select Count(DocSerial) From #PendingDocs Where DocSerial = @DocSerial And DocumentType = @DocumentType) > 0      
 Begin      
  Update #PendingDocs Set Balance = IsNull(Balance,0) + @Balance, AdjustedAmount = IsNull(AdjustedAmount, 0) + @AdjustedAmount      
  Where DocSerial = @DocSerial And DocumentType = @DocumentType      
 End      
 Else      
 Begin      
  Insert into #PendingDocs Values(@DocumentID, @DocumentDate, @DocumentValue,       
   @Balance, @DocSerial, @DocumentType, @DocDesc, @DocReference, @ExtraCol, @Adjustment, @AdjustedAmount)      
 End      
 Fetch Next From ScanPayments Into @DocumentID, @DocumentDate, @DocumentValue,       
   @Balance, @DocSerial, @DocumentType, @DocDesc, @DocReference, @ExtraCol, @Adjustment, @AdjustedAmount      
End      
Select * From #PendingDocs      
Drop Table #PendingDocs      
Drop Table #PaymentDocs   

