Create Procedure spr_list_vendorwise_outstanding_detail(@vendor nvarchar(15), @fromdate datetime,@todate datetime)
as
select BillAbstract.BillID, 
"Document ID" = case when IsNull(BillAbstract.BillReference, '') = '' then BPrefix.Prefix else BAPrefix.Prefix end + cast(BillAbstract.DocumentID as nvarchar),
"Date" = BillAbstract.BillDate, 
"Amount" = BillAbstract.Value,
"Balance" = BillAbstract.Balance,
"Due Days" = datediff(dd, BillAbstract.BillDate, getdate()),
"Doc Type" = 'Purchase'
from BillAbstract, VoucherPrefix as BPrefix, VoucherPrefix as BAPrefix
where BillAbstract.VendorID = @vendor and
BillAbstract.Status & 128 = 0 and
BillAbstract.BillDate between @fromdate and @todate and
BillAbstract.Balance > 0 and
BPrefix.TranID = 'BILL' and
BAPrefix.TranID = 'BILL AMENDMENT'
union all
select AdjustmentReturnAbstract.AdjustmentID,
"Document ID" = VoucherPrefix.Prefix + cast(AdjustmentReturnAbstract.DocumentID as nvarchar),
"Date" = AdjustmentReturnAbstract.AdjustmentDate,
"Amount" = AdjustmentReturnAbstract.Value,
"Balance" = 0 - AdjustmentReturnAbstract.Balance,
"Due Days" = datediff(dd, AdjustmentReturnAbstract.AdjustmentDate, getdate()),
"Doc Type" = 'Purchase Return'
from AdjustmentReturnAbstract, VoucherPrefix
where AdjustmentReturnAbstract.VendorID = @vendor and
AdjustmentReturnAbstract.Status & 192 = 0 and
AdjustmentReturnAbstract.AdjustmentDate between @fromdate And @todate and
AdjustmentReturnAbstract.Balance > 0 and
VoucherPrefix.TranID = 'STOCK ADJUSTMENT PURCHASE RETURN'
union all
select creditnote.creditid,  
"Document Id" =  VoucherPrefix.Prefix + cast(Creditnote.DocumentID as varchar),
"Date" =  Creditnote.DocumentDate, 	
"Amount (Rs)" = Creditnote.Notevalue,  
"Balance (Rs)" =  Creditnote.Balance ,
"Due days" = datediff(dd, Creditnote.DocumentDate, getdate()),
"Doc Type" = 'Credit Note'
from Creditnote, VoucherPrefix 
where Voucherprefix.TranID = 'CREDIT NOTE' and
	Creditnote.Balance > 0  and
	Creditnote.VendorID = @vendor and 
	Creditnote.DocumentDate between @fromdate and @todate
union all
select debitnote.debitid,
"Document Id" =  VoucherPrefix.Prefix + cast(Debitnote.DocumentID as varchar), 
"Date" =  Debitnote.DocumentDate,  
"Amount (Rs)" =   Debitnote.Notevalue,  
"Balance (Rs)" = Debitnote.Balance ,
"Due days" = datediff(dd, Debitnote.DocumentDate, getdate()),
"Doc Type" = 'Debit Note'
from 	Debitnote, VoucherPrefix 
where 	Voucherprefix.TranID = 'DEBIT NOTE' and
Debitnote.Balance > 0 and
Debitnote.VendorID = @vendor and
Debitnote.DocumentDate between @fromdate and @todate 