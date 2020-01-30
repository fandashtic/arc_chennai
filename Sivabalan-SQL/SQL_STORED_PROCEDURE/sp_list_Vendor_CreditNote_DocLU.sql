CREATE procedure sp_list_Vendor_CreditNote_DocLU (@FromDocID int,  
        @ToDocID int,@DocumentRef nvarchar(510)=N'')  
as  

Declare @CANCELLED As NVarchar(50)
Declare @AMENDED As NVarchar(50)
Declare @AMENDMENT As NVarchar(50)

Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @AMENDED = dbo.LookupDictionaryItem(N'Amended', Default)
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment', Default)

If Len(@DocumentRef)=0 
Begin
	select DocumentID, DocumentDate, Vendors.VendorID, Vendors.Vendor_Name, NoteValue, CreditID ,  
	case   
	When Status & 64 <> 0 Then @CANCELLED            
	When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then N''
	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then @AMENDED    
	when isnull(status & 128,0 ) = 128 and Balance = 0  then @AMENDED    
	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then @AMENDMENT    
	Else N''    
	end,DocumentReference         
	from CreditNote, Vendors  
	where (dbo.GetTrueVal(DocumentID) between @FromDocID and @ToDocID 	
	OR (Case Isnumeric(DocumentReference) When 1 then Cast(DocumentReference as int)end) BETWEEN @FromDocID AND @ToDocID)  
	And Vendors.VendorID = CreditNote.VendorID  
	order by Vendors.Vendor_Name, DocumentDate
End
Else
Begin
	select DocumentID, DocumentDate, Vendors.VendorID, Vendors.Vendor_Name, NoteValue, CreditID ,  
	case   
	When Status & 64 <> 0 Then @CANCELLED            
	When isnull(status,0) = 0  and  isnull(RefDocid,0) = 0  Then N''
	when isnull(status & 128,0 ) = 128 and isnull(RefDocid,0) <> 0 then @AMENDED   
	when isnull(status & 128,0 ) = 128 and Balance = 0  then @AMENDED
	when isnull(status & 128,0 ) = 0 and isnull(RefDocid,0) <> 0  then @AMENDMENT   
	Else N''    
	end,DocumentReference         
	from CreditNote, Vendors  
	where DocumentReference LIKE  @DocumentRef + N'%' + N'[0-9]'
	And (CAse ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))) 
	When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End) BETWEEN @FromDocID AND @ToDocID
	And Vendors.VendorID = CreditNote.VendorID  
	order by Vendors.Vendor_Name, DocumentDate
End




