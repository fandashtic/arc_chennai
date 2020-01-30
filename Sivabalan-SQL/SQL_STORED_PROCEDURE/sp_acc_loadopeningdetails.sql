CREATE Procedure sp_acc_loadopeningdetails(@AccountID Int,@Type Int)
as
Declare @CustomerID nVarchar(30)
Declare @VendorID nVarchar(30)
Declare @Prefix nvarchar(20)
Declare @OTHER_CREDITOR Int
Declare @OTHER_DEBTOR Int

Set @OTHER_CREDITOR = 48
Set @OTHER_DEBTOR = 49

Create Table #OpeningDetails(DocumentID nVarchar(20),DocumentDate DateTime,
NoteValue Decimal(18,6),DocRef nVarchar(50),Remarks nVarchar(510),TransactionID int,
DocType nVarchar(50),NoteType Int,Balance Decimal(18,6)) 
If @Type = 1  
Begin
	Select @Prefix  = Prefix 
	from VoucherPrefix where TranID = N'DEBIT NOTE'		

	select @CustomerID = CustomerID  
	from Customer where AccountID = @AccountID
	
	Insert #OpeningDetails
	Select 'DocumentID'= @Prefix + Cast(DocumentID as nvarchar(20)),
	DocumentDate,NoteValue,DocRef,Memo,DebitID,Case IsNULL(Flag,0) 
 	When 5 Then dbo.LookupDictionaryItem('Invoice',Default) Else dbo.LookupDictionaryItem('Debit Note',Default) End,1,Balance
	from DebitNote where CustomerID = @CustomerID and isnull(Status,0) <> 192
	and Isnull(AccountID,0) = 0 
		
	Select @Prefix  = Prefix 
	from VoucherPrefix where TranID = N'CREDIT NOTE'		

	Insert #OpeningDetails
	Select 'DocumentID'= @Prefix + Cast(DocumentID as nvarchar(20)),
	DocumentDate,NoteValue,DocRef,Memo,CreditID,Case IsNULL(Flag,0)
 When 7 Then dbo.LookupDictionaryItem('Sales Return',Default) When 8 Then dbo.LookupDictionaryItem('Advance Collection',Default) Else dbo.LookupDictionaryItem('Credit Note',Default) End,2,Balance
	from CreditNote	where CustomerID = @CustomerID and isnull(Status,0) <> 192
	and Isnull(AccountID,0) = 0 
End
Else If @Type = 2 
Begin
	Select @Prefix  = Prefix 
	from VoucherPrefix where TranID = N'DEBIT NOTE'

	select @vendorid = VendorID  
	from Vendors where AccountID = @accountid
	
	Insert #OpeningDetails
	Select 'DocumentID'= @Prefix + Cast(DocumentID as nvarchar(20)),
	DocumentDate,NoteValue,DocRef,Memo,DebitID,Case IsNULL(Flag,0)
	When 5 Then dbo.LookupDictionaryItem('Purchase Return',Default) When 6 Then dbo.LookupDictionaryItem('Advance Payment',Default) Else dbo.LookupDictionaryItem('Debit Note',Default) End,1,Balance
	from DebitNote where VendorID = @VendorID and isnull(Status,0) <> 192
	and Isnull(AccountID,0) = 0 
	
	Select @Prefix  = Prefix 
	from VoucherPrefix where TranID = N'CREDIT NOTE'		
	
	Insert #OpeningDetails
	Select 'DocumentID'= @Prefix + Cast(DocumentID as nvarchar(20)),
	DocumentDate,NoteValue,DocRef,Memo,CreditID,Case IsNULL(Flag,0)
 	When 7 Then dbo.LookupDictionaryItem('Bill',Default) Else dbo.LookupDictionaryItem('Credit Note',Default) End,2,Balance
	from CreditNote	where VendorID = @VendorID and isnull(Status,0) <> 192
	and Isnull(AccountID,0) = 0
End
Else If @Type = @OTHER_DEBTOR or @Type = @OTHER_CREDITOR
Begin
	Select @Prefix  = Prefix 
	from VoucherPrefix where TranID = N'DEBIT NOTE'

	Insert #OpeningDetails
	Select 'DocumentID'= @Prefix + Cast(DocumentID as nvarchar(20)),
	DocumentDate,NoteValue,DocRef,Memo,DebitID,dbo.LookupDictionaryItem('Debit Note',Default),1,Balance
	from DebitNote where IsNull(Others,0)= @AccountID and isnull(Status,0) <> 192
	and Isnull(AccountID,0) = 0 
	
	Select @Prefix  = Prefix 
	from VoucherPrefix where TranID = N'CREDIT NOTE'		
	
	Insert #OpeningDetails
	Select 'DocumentID'= @Prefix + Cast(DocumentID as nvarchar(20)),
	DocumentDate,NoteValue,DocRef,Memo,CreditID,dbo.LookupDictionaryItem('Credit Note',Default),2,Balance
	from CreditNote	where IsNull(Others,0)= @AccountID and isnull(Status,0) <> 192
	and Isnull(AccountID,0) = 0
End

Select DocumentID,DocumentDate,'NoteValue'= Case When dbo.stripdatefromtime(DocumentDate)< dbo.sp_acc_getfiscalyearstart() Then Balance Else
NoteValue End,DocRef,Remarks,TransactionID,DocType 
from #OpeningDetails order by DocumentDate
Drop Table #OpeningDetails
