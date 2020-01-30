CREATE Procedure spr_list_Vendor_OutStanding_Detail(@Vendor nvarchar(50),
							@FromDate datetime,
							@ToDate datetime)
As
Begin
Select BillAbstract.BillID, 
"Document ID" = 
Case 
When IsNull(BillAbstract.BillReference, N'') = N'' then
BPrefix.Prefix
Else
BAPrefix.Prefix
End + Cast(BillAbstract.DocumentID as nvarchar),
"Date" = BillAbstract.BillDate, 
"Document Reference"=Cast(Billabstract.invoiceReference as nvarchar),
"Amount" = (BillAbstract.Value + BillAbstract.Taxamount + BillAbstract.AdjustmentAmount),
"Balance" = BillAbstract.Balance--,
--"Due Days" = DateDiff(dd, BillAbstract.BillDate, GetDate())
From BillAbstract, VoucherPrefix as BPrefix, VoucherPrefix as BAPrefix
Where BillAbstract.VendorID = @Vendor And
BillAbstract.Status & 128 = 0 And
BillAbstract.BillDate Between @FromDate And @ToDate And
BillAbstract.Balance > 0 And
BPrefix.TranID = N'BILL' And
BAPrefix.TranID = N'BILL AMENDMENT'

Union All

Select CreditNote.CreditID, 
VoucherPrefix.Prefix + Cast(CreditNote.DocumentID as nvarchar),
CreditNote.DocumentDate,Docref,
CreditNote.NoteValue,
CreditNote.Balance--,
--DateDiff(dd, CreditNote.DocumentDate, GetDate())
From CreditNote, VoucherPrefix
Where CreditNote.VendorID = @Vendor And
CreditNote.DocumentDate Between @FromDate And @ToDate And
CreditNote.Balance > 0 And
VoucherPrefix.TranID = N'CREDIT NOTE'

Union All

Select DocumentID, FullDocID,
DocumentDate,Docref,Value, 0-IsNull(Balance, 0)--,
--DateDiff(dd, DocumentDate, GetDate())
From Payments
Where 	Payments.VendorID = @Vendor And
	DocumentDate Between @FromDate And @ToDate And
	IsNull(Balance, 0) > 0 And IsNull(Status, 0) & 64 = 0

Union All

Select AdjustmentReturnAbstract.AdjustmentID,
--VoucherPrefix.Prefix + Cast(AdjustmentReturnAbstract.DocumentID as nvarchar),
Case ISNULL(GSTFlag,0) When 0 then VoucherPrefix.Prefix + Cast(AdjustmentReturnAbstract.DocumentID as nvarchar) ELSE ISNULL(GSTFullDocID,'') END ,
AdjustmentReturnAbstract.AdjustmentDate,
Reference,AdjustmentReturnAbstract.Value,
0 - AdjustmentReturnAbstract.Balance--,
--DateDiff(dd, AdjustmentReturnAbstract.AdjustmentDate, GetDate())
From AdjustmentReturnAbstract, VoucherPrefix
Where AdjustmentReturnAbstract.VendorID = @Vendor And
AdjustmentReturnAbstract.AdjustmentDate Between @FromDate And @ToDate And
AdjustmentReturnAbstract.Balance > 0 And
VoucherPrefix.TranID = N'STOCK ADJUSTMENT PURCHASE RETURN' And (IsNull(Status,0) & 64) = 0

Union All

Select DebitNote.DebitID,
VoucherPrefix.Prefix + Cast(DebitNote.DocumentID as nvarchar),
DebitNote.DocumentDate,
Docref,DebitNote.NoteValue,
0-DebitNote.Balance--,
--DateDiff(dd, DebitNote.DocumentDate, GetDate())
From DebitNote, VoucherPrefix
Where DebitNote.VendorID = @Vendor And
DebitNote.DocumentDate Between @FromDate And @ToDate And
DebitNote.Balance > 0 And
VoucherPrefix.TranID = N'DEBIT NOTE'

Union All

Select ClaimsNote.ClaimID,
VoucherPrefix.Prefix + Cast(ClaimsNote.DocumentID As nvarchar),
ClaimsNote.ClaimDate,
DocumentReference,
ClaimsNote.ClaimValue,
0 - IsNull(ClaimsNote.Balance, 0)
From ClaimsNote, VoucherPrefix
Where ClaimsNote.VendorID = @Vendor And
ClaimsNote.ClaimDate Between @FromDate And @ToDate And
IsNull(ClaimsNote.Balance, 0) > 0 And
VoucherPrefix.TranID = N'CLAIMS NOTE'
End
