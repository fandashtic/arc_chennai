CREATE procedure sp_View_GiftVouchers (
@CustomerID nvarchar(15),              
@FromDate datetime,              
@ToDate datetime,
@Mode int
)
As
If IsNull(@Mode,0) = 1
	select Loyalty.LoyaltyID, Loyalty.Loyaltyname, Customer.CustomerID, Company_Name, DocumentDate, GiftVoucherNo
	, NoteValue,
	dbo.LookupDictionaryItem(case           
	When Status & 64 <> 0 Then N'Closed'  
	When IsNull(NoteValue,0) <> IsNull(balance,0) then 'Closed'
	When isNull(claimRFA,0) = 1 then 'Closed'
	When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then N'Open'
	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then N'Closed'    
	when isnull(status & 128,0 ) = 128 and Balance = 0  then N'Closed'    
	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then N'Open' 
	--When IsNull(Status & 0, 0) = 0  then 'Open'
	Else N''  end, Default), 
	DocumentID, CreditID
	from CreditNote, Customer , Loyalty             
	where Customer.CustomerID like @CustomerID  and              
	DocumentDate between @FromDate  and @ToDate and              
	CreditNote.Flag = 2 and 
	Customer.CustomerID = CreditNote.CustomerID  and            
	Loyalty.LoyaltyID = CreditNote.LoyaltyID  And
	Loyalty.LoyaltyID in ('L1','L2','L3')
	order by Customer.Company_Name,  Loyalty.Loyaltyname, DocumentDate 
Else if isNull(@Mode, 0) = 2
		select Loyalty.LoyaltyID, Loyalty.Loyaltyname, Customer.CustomerID, Company_Name, DocumentDate, GiftVoucherNo
	, NoteValue,
	dbo.LookupDictionaryItem(case           
	When Status & 64 <> 0 Then N'Closed'  
	When IsNull(NoteValue,0) <> IsNull(balance,0) then 'Closed'
	When isNull(claimRFA,0) = 1 then 'Closed'
	When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then N'Open'
	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then N'Closed'    
	when isnull(status & 128,0 ) = 128 and Balance = 0  then N'Closed'    
	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then N'Open' 
	--When IsNull(Status & 0, 0) = 0  then 'Open'
	Else N''  end, Default), 	
	DocumentID, CreditID
	from CreditNote, Customer , Loyalty             
	where Customer.CustomerID like @CustomerID  and              
	DocumentDate between @FromDate  and @ToDate and              
	CreditNote.Flag in(1,2) and 
	Customer.CustomerID = CreditNote.CustomerID  and            
	Loyalty.LoyaltyID = CreditNote.LoyaltyID -- And
--	Loyalty.LoyaltyID in ('L1','L2','L3')
	order by Customer.Company_Name,  Loyalty.Loyaltyname, DocumentDate 

