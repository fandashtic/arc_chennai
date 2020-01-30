CREATE procedure sp_list_Customer_CreditNote_DocLU (@FromDocID int,    
          @ToDocID int,@DocumentRef nvarchar(510)=N'')    
as    
If Len(@DocumentRef)=0 
Begin
	select DocumentID, DocumentDate, Customer.CustomerID, Company_Name, NoteValue, CreditID,  
	dbo.LookupDictionaryItem(case   
	When Status & 64 <> 0 Then N'Cancelled'            
	When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then N''
	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then N'Amended'    
	when isnull(status & 128,0 ) = 128 and Balance = 0  then N'Amended'    
	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then N'Amendment'    
	Else N''    
	end, Default), DocumentReference         
	from CreditNote, Customer    
	where (dbo.GetTrueVal(DocumentID) between @FromDocID and @ToDocID 	
	OR (Case Isnumeric(DocumentReference) When 1 then Cast(DocumentReference as int)end) BETWEEN @FromDocID AND @ToDocID)  
	and Flag = 0	
	and Customer.CustomerID = CreditNote.CustomerID    
	order by Customer.Company_Name, DocumentDate
End
Else
Begin
	select DocumentID, DocumentDate, Customer.CustomerID, Company_Name, NoteValue, CreditID,  
	dbo.LookupDictionaryItem(case   
	When Status & 64 <> 0 Then N'Cancelled'            
	When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then N''
	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then N'Amended'    
	when isnull(status & 128,0 ) = 128 and Balance = 0  then N'Amended'    
	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then N'Amendment'    
	Else N''    
	end, Default), DocumentReference         
	from CreditNote, Customer    
	where DocumentReference LIKE  @DocumentRef + N'%' + N'[0-9]'
	And (CAse ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))) 
	When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End) BETWEEN @FromDocID AND @ToDocID
	and Flag = 0	
	and Customer.CustomerID = CreditNote.CustomerID    
	order by Customer.Company_Name, DocumentDate
End




