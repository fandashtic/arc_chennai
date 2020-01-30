CREATE procedure sp_View_GiftVoucherDetail(@DocumentID int)
AS
declare @CLOCrId int
select @CLOCrId = Creditid from  CLOCrNote where CreditID =@DocumentID

if (isnull(@CLOCrId,0) = 0 )
begin
Select Distinct Loyalty.LoyaltyID, Loyalty.Loyaltyname, Customer.CustomerID, Customer.Company_Name, NoteValue, DocumentDate, Memo,     
DocumentID, Loyalty.LoyaltyID, GiftVoucherNo, CreditNote.SalesmanID, 
Salesman.Salesman_Name, CreditNote.AccountID,   
'AccountName' = ( Case When IsNull(CreditNote.AccountID,0) = 0 Then
		dbo.LookupDictionaryItem('Opening Balance Entry',Default)  Else dbo.getaccountname(CreditNote.AccountID) End)
, DocumentReference
, case   
	When Status & 64 <> 0 Then dbo.LookupDictionaryitem(N'Cancelled', Default)
	When Memo <> N'' and status is null and  isnull(RefDocid,0) = 0  Then LTrim(Rtrim(Memo))           
	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem(N'Amended', Default)
	when isnull(status & 128,0 ) = 128 and Balance = 0  then dbo.LookupDictionaryItem(N'Amended', Default)
	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem(N'Amendment', Default)
	Else N''    
end,
GVCollectedOn,'' as Category
from CreditNote
Inner Join  Customer On Customer.CustomerID = CreditNote.CustomerID
Inner Join  Loyalty On Loyalty.LoyaltyID = CreditNote.LoyaltyID  
Left Outer Join  Salesman    On CreditNote.SalesmanID = Salesman.SalesmanID
where CreditID = @DocumentID 
end 
else
begin
Select Distinct Loyalty.LoyaltyID, Loyalty.Loyaltyname, Customer.CustomerID, Customer.Company_Name, NoteValue, DocumentDate, Memo,     
DocumentID, Loyalty.LoyaltyID, GiftVoucherNo, CN.SalesmanID, 
Salesman.Salesman_Name, CN.AccountID,   
'AccountName' = ( Case When IsNull(CN.AccountID,0) = 0 Then
		dbo.LookupDictionaryItem('Opening Balance Entry',Default)  Else dbo.getaccountname(CN.AccountID) End)
, DocumentReference
, case   
	When Status & 64 <> 0 Then dbo.LookupDictionaryitem(N'Cancelled', Default)
	When Memo <> N'' and status is null and  isnull(RefDocid,0) = 0  Then LTrim(Rtrim(Memo))           
	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then dbo.LookupDictionaryItem(N'Amended', Default)
	when isnull(status & 128,0 ) = 128 and Balance = 0  then dbo.LookupDictionaryItem(N'Amended', Default)
	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then dbo.LookupDictionaryItem(N'Amendment', Default)
	Else N''    
end,
GVCollectedOn,CLO.Category
from CreditNote CN
Inner Join CLOCrNote CLO On CLO.CreditID = CN.CreditID 
Inner join  Customer On Customer.CustomerID = CN.CustomerID
Inner Join  Loyalty On Loyalty.LoyaltyID = CN.LoyaltyID 
Left Outer Join  Salesman    On CN.SalesmanID = Salesman.SalesmanID
where CN.CreditID = @DocumentID 
end
