CREATE procedure sp_acc_pendingtransactions(@DocID int, @DocType Int)
as 
DECLARE @invoiceprefix nvarchar(10)
DECLARE @billprefix nvarchar(10)
DECLARE @BILL integer
DECLARE @INVOICE integer
DECLARE @transactionmode integer
DECLARE @vendorid nvarchar(15),@vendorcount integer,@customercount integer 
DECLARE @customerid nvarchar(15)
DECLARE @debitnoteprefix nvarchar(10)
DECLARE @creditnoteprefix nvarchar(10)
DECLARE @purchasereturnprefix nvarchar(10)
DECLARE @totaldebit decimal(18,6)
DECLARE @totalcredit decimal(18,6)
DECLARE @debitcount integer
DECLARE @creditcount integer
DECLARE @apvprefix nvarchar(10)
DECLARE @arvprefix nvarchar(10)
DECLARE @otherpaymentprefix nvarchar(10)
DECLARE @otherreceiptprefix nvarchar(10)

DECLARE @COLLECTIONS integer
DECLARE @DEBITNOTE integer
DECLARE @CREDITNOTE integer
DECLARE @SALESRETURN integer
DECLARE @PURCHASERETURN integer
DECLARE @PAYMENTS integer

DECLARE @APV integer
DECLARE @ARV integer
DECLARE @OTHERPAYMENTS integer
DECLARE @OTHERRECEIPTS integer
DECLARE @OTHERDEBITNOTE integer
DECLARE @OTHERCREDITNOTE integer
DECLARE @MANUALJOURNALNEWREFERENCE integer
DECLARE @CLAIMSNOTE integer

DECLARE @COLLECTIONDESC nvarchar(30)
DECLARE @INVOICEDESC nvarchar(30)
DECLARE @DEBITNOTEDESC nvarchar(30)
DECLARE @CREDITNOTEDESC nvarchar(30)
DECLARE @SALESRETURNDESC nvarchar(30)
DECLARE @BILLDESC nvarchar(30)
DECLARE @PURCHASERETURNDESC nvarchar(30) 
DECLARE @PAYMENTSDESC nvarchar(30)

DECLARE @APVDESC nvarchar(30)
DECLARE @ARVDESC nvarchar(30)
DECLARE @OTHERPAYMENTSDESC nvarchar(30)
DECLARE @OTHERRECEIPTSDESC nvarchar(30)
DECLARE @MANUALJOURNALNEWREFERENCEDESC nvarchar(30)
DECLARE @CLAIMSNOTEDESC nvarchar(30)


SET @COLLECTIONS =32
SET @INVOICE =28
SET @DEBITNOTE =34
SET @CREDITNOTE =35 
SET @SALESRETURN =29
SET @BILL =30
SET @PURCHASERETURN =31
SET @PAYMENTS=33

Set @APV = 60
Set @ARV  = 61
Set @OTHERPAYMENTS = 62
Set @OTHERRECEIPTS = 63
Set @OTHERDEBITNOTE = 79
Set @OTHERCREDITNOTE = 80
Set @MANUALJOURNALNEWREFERENCE = 81
Set @CLAIMSNOTE = 82


If @DocType = @COLLECTIONS 
Begin 
	Select IsNull(Balance,0) from collections
	where DocumentID = @DocID   
End
else If @DocType = @INVOICE
Begin 
	Select IsNull(Balance,0) from InvoiceAbstract
	where InvoiceID = @DocID   
End
else If @DocType = @DEBITNOTE
Begin 
	Select IsNull(Balance,0)
	from DebitNote where DebitID = @DocID
End
else If @DocType = @CREDITNOTE
Begin 
	Select IsNull(Balance,0)
	from CreditNote where CreditID = @DocID
End
else If @DocType = @SALESRETURN
Begin 
	Select IsNull(Balance,0)from InvoiceAbstract
	where InvoiceID = @DocID 
End
else If @DocType = @BILL
Begin 
	Select IsNull(Balance,0) from BillAbstract
	where BillID = @DocID 
End
else If @DocType = @PURCHASERETURN
Begin 
	Select IsNull(Balance,0) from AdjustmentReturnabstract 
	where AdjustmentID = @DocID
End
else If @DocType = @PAYMENTS
Begin 
	Select IsNull(Balance,0) from Payments
	where DocumentID = @DocID
End
else If @DocType = @APV
Begin 
	Select IsNull(Balance,0) from APVAbstract
	where DocumentID = @DocID 
End
else If @DocType = @ARV
Begin 
	Select IsNull(Balance,0) from ARVAbstract
	where DocumentID = @DocID
End
else If @DocType = @OTHERPAYMENTS
Begin 
	Select IsNull(Balance,0) from Payments
	where DocumentID = @DocID 
End
else If @DocType = @OTHERRECEIPTS
Begin 
	Select IsNull(Balance,0) from Collections
	where DocumentID = @DocID 
End
else If @DocType = @OTHERDEBITNOTE
Begin 
	Select IsNull(Balance,0)
	from DebitNote where DebitID = @DocID
End
else If @DocType = @OTHERCREDITNOTE
Begin 
	Select IsNull(Balance,0)
	from CreditNote where CreditID = @DocID
End
else If @DocType = @MANUALJOURNALNEWREFERENCE
Begin 
	Select IsNull(Balance,0)
	from ManualJournal
	where NewRefID = @DocID
End
else If @DocType = @CLAIMSNOTE
Begin 
	Select IsNull(Balance,0)
	from ClaimsNote
	where ClaimID = @DocID
End


