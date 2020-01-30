
Create Procedure dbo.sp_Load_InvoicewiseCollectionFromAutoList (@InvDrID integer,@DocTag nvarchar(1))  
As  
Begin
Create table #tmpInvoiceDebit(InvID int,DocID nvarchar(255),DocRef nvarchar(255),DocType nvarchar(20),DocDate datetime,DocValue float,DocBalance float,Discount float,DisVal float,CompName nvarchar(255),CreditLimit float,PaymentDate datetime,CustomerID nvarchar(15),FullDocID nvarchar(255),FullDocRef nvarchar(355), ChqCollDebitFlag Int, ChqAmt Decimal(18,6))                    
If @DocTag = dbo.LookUpDictionaryItem(N'I',Default)
Begin
	Insert Into #tmpInvoiceDebit
    Select InvoiceID as InvID,
    --DocumentID as DocID,
    Case IsNULL(GSTFlag ,0) When 0 then cast(DocumentID as Nvarchar) Else IsNULL(GSTFullDocID,'') End DocID,
    DocReference as DocRef,dbo.LookUpDictionaryItem(N'Invoice',Default) as DocType,  
    InvoiceDate as DocDate,NetValue as DocValue,Balance as DocBalance,AdditionalDiscount as Discount,  
    AddlDiscountValue as DisVal,Company_Name as CompName,CreditLimit,PaymentDate,  
    Customer.CustomerID,
    --VoucherPrefix.Prefix + cast(DocumentID as nvarchar) as FullDocID,  
    Case IsNULL(GSTFlag ,0) When 0 then VoucherPrefix.Prefix + cast(DocumentID as nvarchar) Else IsNULL(GSTFullDocID,'') End FullDocID,
    "FullDocRef"=case IsNull(DocSerialType,N'') when N'' then VoucherPrefix.Prefix+N'-'+DocReference else DocSerialType+N'-'+DocReference end, 0, 0   
	From InvoiceAbstract,Customer,VoucherPrefix,VoucherPrefix as InvPrefix   
    Where InvoiceID=@InvDrID And InvoiceAbstract.CustomerID=Customer.CustomerID And   
    VoucherPrefix.TranID = dbo.LookUpDictionaryItem(N'INVOICE',Default) and InvPrefix.TranID = dbo.LookUpDictionaryItem(N'INVOICE AMENDMENT',Default)  
End  
Else  
Begin  
	Insert Into #tmpInvoiceDebit
    Select DebitID as InvID,DocumentID as DocID,DocumentReference as DocRef,dbo.LookUpDictionaryItem(N'Debit Note',Default) as DocType,  
    DocumentDate as DocDate,NoteValue as DocValue,Balance as DocBalance,0 as Discount,0 as DisVal,  
    Company_Name as CompName,CreditLimit,DocumentDate as PaymentDate,Customer.CustomerID,  
    VoucherPrefix.Prefix + cast(DocumentID as nvarchar) as FullDocID,  
	"FullDocRef"=case IsNull(DocSerialType,N'') when N'' then DocumentReference else DocSerialType+N'-'+DocumentReference end, 0, 0   
	From DebitNote,Customer,VoucherPrefix   
    Where DebitID=@InvDrID And DebitNote.CustomerID=Customer.CustomerID And VoucherPrefix.TranID = dbo.LookUpDictionaryItem(N'DEBIT NOTE',Default)  
End  

-- To update the document balance from bounced cheque debit note balance
Update tmp1 Set tmp1.DocBalance = tmp1.DocBalance + tmp2.DocBalance, tmp1.ChqCollDebitFlag = 1 From #tmpInvoiceDebit tmp1, 
(Select ccd.DocumentID, DocType, Sum(dn.Balance) as DocBalance 
From DebitNote dn, ChequeCollDetails ccd, CollectionDetail cld, Collections cl, #tmpInvoiceDebit 
Where cld.DocumentID = #tmpInvoiceDebit.InvID And cld.DocumentType = (Case DocType When 'Invoice' Then 4 Else 5 End)
And cld.CollectionID = cl.DocumentID And IsNull(cl.Status, 0) & 192 = 0 And cld.CollectionID = ccd.CollectionID And 
cld.DocumentID = ccd.DocumentID And cld.DocumentType = ccd.DocumentType And ccd.DebitID = dn.DebitID And dn.Flag = 2
Group By ccd.DocumentID, DocType)tmp2
Where tmp1.InvID = tmp2.DocumentID

-- To update doctype description as 'Inv Chq Bounced' for bounced cheque of cheque invoice only
Update tmp1 Set tmp1.DocType = dbo.LookUpDictionaryItem(N'Inv Chq Bounced', Default) From #tmpInvoiceDebit tmp1, InvoiceAbstract iva
Where iva.InvoiceID = tmp1.InvID And tmp1.DocType = dbo.LookUpDictionaryItem(N'Invoice', Default) And IsNull(iva.PaymentMode, 0) = 2

-- To update the unrealised/unbounced cheque amount 
Update tmp1 Set tmp1.ChqAmt = tmp2.ChqAmt From #tmpInvoiceDebit tmp1, 
(Select InvID, DocType, (Case When isnull(Max(cl.realised),0) = 3 then dbo.mERP_fn_getCollBalance_ITC(Max(ClD.DocumentID), Max(ClD.DocumentType)) else (IsNull(Sum(cld.AdjustedAmount), 0) - IsNull(Sum(cld.DocAdjustAmount), 0)) End) as ChqAmt 
From Collections cl, CollectionDetail cld, #tmpInvoiceDebit rs
Where cld.DocumentID = rs.InvID And cld.DocumentType = (Case rs.DocType When dbo.LookUpDictionaryItem(N'Invoice', Default) Then 4 When dbo.LookUpDictionaryItem(N'Inv Chq Bounced', Default) Then 4 Else 5 End)
And cl.DocumentID = cld.CollectionID And IsNull(cl.Status, 0) & 192 = 0 And IsNull(cl.PaymentMode, 0) = 1
And IsNull(cl.Realised, 0) Not In (1, 2)
Group By InvID, DocType)tmp2 
Where tmp1.InvID = tmp2.InvID And tmp1.DocType = tmp2.DocType

Select * From #tmpInvoiceDebit

Drop Table #tmpInvoiceDebit
End  
