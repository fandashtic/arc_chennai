CREATE procedure sp_List_Pending_Payments(@VendorID nvarchar(15))
as
	Declare @PURCHASERETURN As NVarchar(50)
	Declare @CLAIMSNOTE As NVarchar(50)
	Declare @BILL As NVarchar(50)
	Declare @ADVANCEPAYMENT As NVarchar(50)
	Declare @DEBITNOTE As NVarchar(50)
	Declare @PAYMENTS As NVarchar(50)
	Declare @BILLAMENDMENT As NVarchar(50)
	Declare @CREDITNOTE As NVarchar(50)

	Set @PURCHASERETURN = dbo.LookupDictionaryItem(N'Purchase Return', Default)
	Set @CLAIMSNOTE = dbo.LookupDictionaryItem(N'Claims Note', Default)
	Set @BILL = dbo.LookupDictionaryItem(N'Bill', Default)
	Set @ADVANCEPAYMENT = dbo.LookupDictionaryItem(N'Advance Payment', Default)
	Set @DEBITNOTE = dbo.LookupDictionaryItem(N'Debit Note', Default)
	Set @PAYMENTS = dbo.LookupDictionaryItem(N'Payments', Default)
	Set @BILLAMENDMENT = dbo.LookupDictionaryItem(N'Bill Amendment', Default)
	Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)

	select "DocumentID" = 
	Case IsNULL(GSTFullDocID,'')
	When '' then VoucherPrefix.Prefix + cast(AdjustmentReturnAbstract.DocumentID as nvarchar)
	Else
	IsNULL(GSTFullDocID,'')
	End,
	"Document Date" = AdjustmentReturnAbstract.AdjustmentDate, 
	"Value" = IsNull(AdjustmentReturnAbstract.Total_Value, AdjustmentReturnAbstract.Value),
	AdjustmentReturnAbstract.Balance, AdjustmentID, "Type" = 1, 
	@PURCHASERETURN, Reference
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
	 Balance, ClaimID, "Type" = 6, @CLAIMSNOTE, DocumentReference  
	 From ClaimsNote, VoucherPrefix  
	 Where IsNull(Balance, 0) > 0   
	 and ClaimType = 2 and IsNull(ClaimRFA,0) = 1
	 And VendorID = @VendorID And  
	 VoucherPrefix.TranID = N'CLAIMS NOTE'  

	union


	Select "Document ID" = VoucherPrefix.Prefix + Cast(DocumentID As nvarchar),
	"Document Date" = ClaimDate, ClaimValue,
	Balance, ClaimID, "Type" = 6, @CLAIMSNOTE, DocumentReference
	From ClaimsNote, VoucherPrefix
	Where IsNull(Balance, 0) > 0 
	And IsNull(ClaimRFA,0) <> 5 and ClaimType <> 2
	And VendorID = @VendorID And
	VoucherPrefix.TranID = N'CLAIMS NOTE'

	union

	select "Document ID" = VoucherPrefix.Prefix + cast(DebitNote.DocumentID as nvarchar), 
	"Document Date" = DocumentDate, NoteValue, 
	DebitNote.Balance, DebitID, "Type" = 2,
	Case IsNULL(Flag,0)
	When 5 then
	@PURCHASERETURN
	When 6 then
	@ADVANCEPAYMENT
	Else
	@DEBITNOTE
	End, DocRef 
	from DebitNote, VoucherPrefix
	where DebitNote.Balance > 0 and 
	DebitNote.VendorID = @VendorID and 
	VoucherPrefix.TranID = N'DEBIT NOTE'

	union

	select "Document ID" = FullDocID, 
	"Document Date" = DocumentDate, Value, Balance, DocumentID, "Type" = 3, @PAYMENTS, N''
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
	case 
	when BillReference is null then
	@BILL
	else
	@BILLAMENDMENT
	end,
	BillAbstract.InvoiceReference
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
	Case IsNULL(Flag,0)
	When 7 then
	@BILL
	Else
	@CREDITNOTE
	End, DocRef
	from CreditNote, VoucherPrefix
	where VendorID = @VendorID and
	Balance > 0 and
	VoucherPrefix.TranID = N'CREDIT NOTE'

	Order by "Document Date"

