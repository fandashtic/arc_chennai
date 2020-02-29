--select * FROM dbo.fn_ARC_CustomerOutstandingDetails('ARCBAK101',0,0, '2020-02-20 23:59:59') Where (Isnull(Balance, 0) > 0 OR ISNULL(ChequeOnHand, 0) > 0)
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'fn_ARC_CustomerOutstandingDetails')
BEGIN
    DROP FUNCTION fn_ARC_CustomerOutstandingDetails
END
GO
Create Function fn_ARC_CustomerOutstandingDetails(@CustomerID nvarchar(15), @SalesmanID int, @BeatID int, @ToDate DateTime)  
Returns  
	@tempCollection Table (SalesManId Int, BeatId Int, CustomerId Nvarchar(255), [Document ID] nvarchar(255),[DocumentDate] datetime,Netvalue decimal(18,6), Balance decimal(18,6),InvoiceID int,Type int,[Desc] nvarchar(500),AdditionalDiscount decimal(18,6),DocSerialType nvarchar(500),DisableEdit int,
	ChequeNumber NVARCHAR(255) NULL, ChequeDate DATETIME NULL, ChequeOnHand decimal(18,6))
AS  
BEGIN     
	Declare @DrID as int  
	Declare @InvID as int 

	Declare @TSalesman AS Table (SalesmanID int)  
	Declare @TBeat AS Table (BeatID int)  
	Declare @tempDebitID AS Table (debitid int)              
  
	If @SalesmanID=0  
	Begin  
	 Insert Into @TSalesman Values (0)  
	 Insert Into @TSalesman Select SalesmanID FROM Salesman WITH (NOLOCK)  
	End  
	Else  
	 Insert Into @TSalesman Select SalesmanID FROM Salesman WITH (NOLOCK) Where SalesmanID=@SalesmanID  
    
	If @BeatID=0  
	Begin  
	 Insert Into @TBeat Values (0)  
	 Insert Into @TBeat Select BeatID FROM Beat WITH (NOLOCK)  
	End  
	Else  
	 Insert Into @TBeat Select BeatID FROM Beat WITH (NOLOCK) Where BeatID=@BeatID  
	
	
	Insert into @tempCollection(SalesManId, BeatId, CustomerId, [Document ID],[DocumentDate],Netvalue,
	Balance,InvoiceID,Type,[Desc],AdditionalDiscount,DocSerialType,ChequeNumber, ChequeDate, ChequeonHand)    
	 (       

	select
	invoiceabstract.SalesmanID, invoiceabstract.BeatID, invoiceabstract.CustomerID,
	"DocumentID" =   
	Case IsNULL(GSTFlag ,0)  
	When 0 then VoucherPrefix.Prefix + CAST(DocumentID as nvarchar)
	Else  
	 IsNULL(GSTFullDocID,'')  
	End,  
	
	"DocumentDate" = InvoiceDate, NetValue, Balance,     
	InvoiceID, 
	"Type" = case InvoiceType when 4 then 1 when 5 then 7 when 6 then 7 end,    
	"Desc" = 'Sales Return',     
	AdditionalDiscount, DocSerialType,Null, NULL,0
	FROM invoiceabstract WITH (NOLOCK), VoucherPrefix WITH (NOLOCK)
	where  
	dbo.StripDateFromTime(invoiceabstract.InvoiceDate) <= @ToDate AND
	ISNULL(Balance, 0) > 0 and   
	InvoiceType in(4,5,6) and 
	IsNull(Status, 0) & 128 = 0 and
	invoiceabstract.InvoiceID Not In ( Select InvoiceID  FROM tbl_merp_DSOStransfer WITH (NOLOCK) ) and     
	CustomerID = @CustomerID and IsNull(SalesmanID,0) In (Select SalesmanID FROM @TSalesman) and   
	IsNull(BeatID,0) In (Select BeatID FROM @TBeat) and     
	VoucherPrefix.TranID = 'SALES RETURN'
    
	Union    
    
	select 
	invoiceabstract.SalesmanID, invoiceabstract.BeatID, invoiceabstract.CustomerID,
	"DocumentID" =   
	Case IsNULL(GSTFlag ,0)  
	When 0 then VoucherPrefix.Prefix + CAST(DocumentID as nvarchar)
	Else  
	 IsNULL(GSTFullDocID,'')  
	End,  
  
	"DocumentDate" = InvoiceDate, 
	 NetValue, Balance,     
	 InvoiceAbstract.InvoiceID, 
	"Type" = case InvoiceType when 4 then 1 when 5 then 7 when 6 then 7 end,    
	"Desc" = 'Sales Return',     
	AdditionalDiscount, DocSerialType,Null, NULL,0
	FROM invoiceabstract WITH (NOLOCK), VoucherPrefix WITH (NOLOCK), tbl_mERP_DSOSTransfer DSOSTrfr WITH (NOLOCK)
	where 
	dbo.StripDateFromTime(invoiceabstract.InvoiceDate) <= @ToDate AND
	ISNULL(Balance, 0) > 0  and  
	InvoiceType in(4,5,6)      
	and InvoiceAbstract.InvoiceID = DSOSTrfr.InvoiceID    
	and IsNull(Status, 0) & 128 = 0 and
	CustomerID = @CustomerID and IsNull(DSOSTrfr.MappedSalesmanID,0) In (Select SalesmanID FROM @TSalesman) and   
	IsNull(DSOSTrfr.MappedBeatID,0) In (Select BeatID FROM @TBeat) and 
	VoucherPrefix.TranID = 'SALES RETURN'
    
     
	union

	select 
	0,0,@CustomerID,
	"DocumentID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar), 
	"DocumentDate" = DocumentDate, 
	NoteValue, Balance, CreditID, "Type" = 2,  
	"Desc" =Case IsNULL(Flag,0)  
	When 7 then  
	'Sales Return'  
	When 8 then  
	'Advance Collection'  
	Else  
	'Credit Note'  
	end, 0, DocRef,Null, NULL,0
	FROM CreditNote WITH (NOLOCK), VoucherPrefix WITH (NOLOCK)
	where 
	dbo.StripDateFromTime(CreditNote.DocumentDate) <= @ToDate AND
	Balance > 0 and
	CustomerID = @CustomerID and
	VoucherPrefix.TranID = 'CREDIT NOTE'       
	and CreditNote.Flag In (0,1)    
	and creditid not in (select isnull(creditID,0) FROM CLOCrnote WITH (NOLOCK) where isnull(isgenerated,0)=1)  

	/* CLO Changes*/  
	union
	select 
	0,0,@CustomerID,
	"DocumentID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar), 
	"DocumentDate" = DocumentDate, 
	NoteValue, Balance, CreditID, "Type" = 2,  
	"Desc" =Case IsNULL(Flag,0)  
	When 7 then  
	'Sales Return'  
	When 8 then  
	'Advance Collection'  
	Else  
	'Credit Note'  
	end, 0, DocRef,Null, NULL,0
	FROM CreditNote WITH (NOLOCK), VoucherPrefix WITH (NOLOCK)
	where 
	dbo.StripDateFromTime(CreditNote.DocumentDate) <= @ToDate AND
	Balance > 0 and
	CustomerID = @CustomerID and
	VoucherPrefix.TranID = 'GIFT VOUCHER'   
	and CreditNote.Flag =1   
	and creditid in (select isnull(creditID,0) FROM CLOCrnote WITH (NOLOCK) where isnull(isgenerated,0)=1)  
  
	union

	select 
	Collections.SalesmanID, Collections.BeatID, Collections.CustomerID,
	"DocumentID" = FullDocID, 
	"DocumentDate" = DocumentDate, Value, 
	Balance, DocumentID, "Type" = 3, "Desc" = 'Collections', 0, Null,Null, NULL,0
	FROM Collections WITH (NOLOCK), VoucherPrefix WITH (NOLOCK)
	where 
	dbo.StripDateFromTime(Collections.DocumentDate) <= @ToDate AND
	Balance > 0 and
	CustomerID = @CustomerID and IsNull(SalesmanID,0) In (Select SalesmanID FROM @TSalesman) and     
	IsNull(BeatID,0) In (Select BeatID FROM @TBeat) and   
	(IsNull(Status, 0) & 192) = 0 And -- Cancelled collections
	VoucherPrefix.TranID = 'COLLECTIONS'

	union

	select 
	invoiceabstract.SalesmanID, invoiceabstract.BeatID, invoiceabstract.CustomerID,
	"DocumentID" =      
	Case IsNULL(GSTFlag ,0)  
	When 0 then   
	 case InvoiceType
	 when 1 then
	  VoucherPrefix.Prefix 
	 When 2 then  
	  RPrefix.Prefix  
	 when 3 then
	  InvPrefix.Prefix       
	 end       
	 + CAST(DocumentID as nvarchar)   
	Else  
	 IsNULL(GSTFullDocID,'')  
	End,     
	"DocumentDate" = InvoiceDate, NetValue, 
	Balance, InvoiceID,     
	"Type" = case InvoiceType       
	 when 1 then   4
	 when 2 then   6
	 when 3 then   4 end,
	"Desc" =case InvoiceType
	when 1 then
	  'Invoice'
	when 2 then
	  'Retail Invoice'
	when 3 then
	  'Invoice Amd'
	end,  
	AdditionalDiscount, DocSerialType,

	(Select TOP 1 C.ChequeNumber FROM Collections C WITH (NOLOCK), CollectionDetail CD WITH (NOLOCK)
	Where 
	dbo.StripDateFromTime(C.DocumentDate) <= @ToDate AND
	CD.DocumentID = InvoiceAbstract.InvoiceID And C.customerID = @CustomerID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1 
	and IsNull(c.Realised, 0) Not In (1, 2)) , 
	(Select TOP 1 C.ChequeDate FROM Collections C WITH (NOLOCK), CollectionDetail CD WITH (NOLOCK)
	Where dbo.StripDateFromTime(C.DocumentDate) <= @ToDate AND CD.DocumentID = InvoiceAbstract.InvoiceID And C.customerID = @CustomerID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1 
	and IsNull(c.Realised, 0) Not In (1, 2)) ,

	(Select Case When MAx(isnull(C.Realised,0)) =3 Then     
	(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))     
	Else     
	(isnull(sum(AdjustedAmount),0)-isnull(sum(DocAdjustAmount),0))end     
	FROM Collections C WITH (NOLOCK), CollectionDetail CD WITH (NOLOCK)
	Where dbo.StripDateFromTime(C.DocumentDate) <= @ToDate AND  CD.DocumentID = InvoiceAbstract.InvoiceID And C.customerID = @CustomerID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1 
	and IsNull(c.Realised, 0) Not In (1, 2)) 
	
	FROM InvoiceAbstract WITH (NOLOCK), VoucherPrefix WITH (NOLOCK), VoucherPrefix as InvPrefix WITH (NOLOCK), VoucherPrefix as RPrefix WITH (NOLOCK)
	where 
	dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) <= @ToDate AND 
	ISNULL(InvoiceAbstract.Balance, 0) >= 0 And       
	IsNull(Status, 0) & 128 = 0 and    
	InvoiceType in (1, 3, 2) and
	InvoiceAbstract.InvoiceID Not In ( Select InvoiceID FROM tbl_merp_DSOStransfer WITH (NOLOCK)) and     
	CustomerID = @CustomerID and IsNull(SalesmanID,0) In (Select SalesmanID FROM @TSalesman) and   
	IsNull(BeatID,0) In (Select BeatID FROM @TBeat) and     
	VoucherPrefix.TranID = 'INVOICE' and
	InvPrefix.TranID = 'INVOICE AMENDMENT' And  
	RPrefix.TranID = 'RETAIL INVOICE'  
    
	Union  
    
	select     
	invoiceabstract.SalesmanID, invoiceabstract.BeatID, invoiceabstract.CustomerID,
	"DocumentID" =     
	Case IsNULL(GSTFlag ,0)  
	When 0 then       
	 case InvoiceType
	 when 1 then
	  VoucherPrefix.Prefix 
	 When 2 then  
	  RPrefix.Prefix  
	 when 3 then
	  InvPrefix.Prefix       
	 end
	 + CAST(DocumentID as nvarchar)   
	Else  
	 IsNULL(GSTFullDocID,'')  
	End,    
	"DocumentDate" = InvoiceDate, NetValue, 
	Balance, InvoiceAbstract.InvoiceID, "Type" = case InvoiceType       
	 when 1 then   4
	 when 2 then   6
	 when 3 then   4 end,
	"Desc" =case InvoiceType
	when 1 then
	  'Invoice'
	when 2 then
	  'Retail Invoice'
	when 3 then
	  'Invoice Amd'
	end,  
	AdditionalDiscount, DocSerialType,
	(Select TOP 1 C.ChequeNumber FROM Collections C WITH (NOLOCK), CollectionDetail CD WITH (NOLOCK)
	Where dbo.StripDateFromTime(C.DocumentDate) <= @ToDate AND  CD.DocumentID = InvoiceAbstract.InvoiceID And C.customerID = @CustomerID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1 
	and IsNull(c.Realised, 0) Not In (1, 2)) , 
	(Select TOP 1 C.ChequeDate FROM Collections C WITH (NOLOCK), CollectionDetail CD WITH (NOLOCK)
	Where dbo.StripDateFromTime(C.DocumentDate) <= @ToDate AND  CD.DocumentID = InvoiceAbstract.InvoiceID And C.customerID = @CustomerID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1 
	and IsNull(c.Realised, 0) Not In (1, 2)) ,
	(Select Case When MAx(isnull(C.Realised,0)) =3 Then     
	(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))     
	Else     
	(isnull(sum(AdjustedAmount),0)-isnull(sum(DocAdjustAmount),0))end     
	FROM Collections C WITH (NOLOCK), CollectionDetail CD WITH (NOLOCK)
	Where CD.DocumentID = InvoiceAbstract.InvoiceID And C.customerID = @CustomerID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1 
	and IsNull(c.Realised, 0) Not In (1, 2))    
  
	FROM InvoiceAbstract WITH (NOLOCK), VoucherPrefix WITH (NOLOCK), VoucherPrefix as InvPrefix WITH (NOLOCK), VoucherPrefix as RPrefix WITH (NOLOCK)
	, tbl_mERP_DSOSTransfer DSOSTrfr WITH (NOLOCK)
	where   
	dbo.StripDateFromTime(InvoiceAbstract.InvoiceDate) <= @ToDate AND 
	ISNULL(InvoiceAbstract.Balance, 0) >= 0 And    
	InvoiceAbstract.InvoiceID = DSOSTrfr.InvoiceID and    
	InvoiceType in (1, 3, 2) and
	IsNull(Status, 0) & 128 = 0 and
	CustomerID = @CustomerID and IsNull(DSOSTrfr.MappedSalesmanID,0) In (Select SalesmanID FROM @TSalesman) and   
	IsNull(DSOSTrfr.MappedBeatID,0) In (Select BeatID FROM @TBeat) and     
	VoucherPrefix.TranID = 'INVOICE' and
	InvPrefix.TranID = 'INVOICE AMENDMENT' And  
	RPrefix.TranID = 'RETAIL INVOICE'  
    
    
	union 

	select 
	0,0,@CustomerID,
	"DocumentID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar), 
	"DocumentDate" = DocumentDate, NoteValue, Balance, DebitID, "Type" = 5, 
	"Desc" = case Flag
	when 0 then
	'Debit Note'
	when 1 then
	'Bank Charges'
	when 2 then
	'Bounced'
	When 4 then  
	'Debit Note'  
	When 5 then  
	'Invoice'  
	end, 0, DocRef, 
	
	(Select C.ChequeNumber FROM Collections C WITH (NOLOCK), CollectionDetail CD WITH (NOLOCK)
	Where dbo.StripDateFromTime(C.DocumentDate) <= @ToDate AND  CD.DocumentID = DebitNote.debitID And C.customerID = @CustomerID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1 
	and IsNull(c.Realised, 0) Not In (1, 2)),

	(Select C.ChequeDate FROM Collections C WITH (NOLOCK), CollectionDetail CD WITH (NOLOCK)
	Where dbo.StripDateFromTime(C.DocumentDate) <= @ToDate AND  CD.DocumentID = DebitNote.debitID And C.customerID = @CustomerID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1 
	and IsNull(c.Realised, 0) Not In (1, 2)),

	(Select Case When MAx(isnull(C.Realised,0)) =3 Then     
	(dbo.mERP_fn_getCollBalance_ITC(MAx(CD.DocumentID), MAx(CD.DocumentType)))     
	Else     
	(isnull(sum(AdjustedAmount),0)-isnull(sum(DocAdjustAmount),0))end     
	FROM Collections C WITH (NOLOCK), CollectionDetail CD WITH (NOLOCK)
	Where dbo.StripDateFromTime(C.DocumentDate) <= @ToDate AND  CD.DocumentID = DebitNote.debitID And C.customerID = @CustomerID And C.documentID = CD.CollectionID And isnull(C.status,0) & 192 = 0 and isnull(C.Paymentmode,0)=1 
	and IsNull(c.Realised, 0) Not In (1, 2))  
	
	FROM DebitNote WITH (NOLOCK), VoucherPrefix WITH (NOLOCK)
	where 
	 dbo.StripDateFromTime(DebitNote.DocumentDate) <= @ToDate AND 
	Balance >= 0 and 
	Isnull(DebitNote.Status ,0) <> 192 And  
	CustomerID = @CustomerID and 
	VoucherPrefix.TranID = 'DEBIT NOTE')
            
	 Declare getAllID Cursor For Select Distinct T.InvoiceID FROM @tempCollection T,ChequeCollDetails CD
	 Where T.Type in(4) And T.invoiceID = CD.DocumentID and CD.DocumentType in(4) And isnull(CD.debitID,0)<> 0              
	Open getAllID 
	Fetch FROM getAllID into @InvID
	While @@fetch_status = 0 
	 BEGIN 
	  Insert into @tempdebitID
	  Select isnull(CD.DebitID,0) FROM ChequeCollDetails CD WITH (NOLOCK), collections C WITH (NOLOCK) Where dbo.StripDateFromTime(C.DocumentDate) <= @ToDate AND  C.CustomerID = @CustomerID And CD.DocumentID=@InvID  
	  And C.DocumentID = CD.CollectionID and CD.DocumentType in (4) And isnull(C.Status,0) & 192 = 0              
	  Update @tempCollection Set Balance = Balance + IsNull((Select sum(Balance) FROM debitnote WITH (NOLOCK) Where dbo.StripDateFromTime(debitnote.DocumentDate) <= @ToDate AND  debitid in(select DebitID FROM @tempDebitID)),0), DisableEdit=1 Where InvoiceID = @InvID 
            
	  If (Select isnull(PaymentDetails,0) FROM invoiceabstract WITH (NOLOCK) where dbo.StripDateFromTime(invoiceabstract.InvoiceDate) <= @ToDate AND Invoiceid = @InvID and isnull(PaymentMode,0) = 2 ) <> 0            
	  Update @tempCollection Set [Desc]='Inv cheque Bounced' Where Invoiceid = @InvID and [Type] = 4            
            
	  Delete FROM @tempCollection Where InvoiceID in(Select debitid FROM @tempdebitID)              
	  Fetch Next FROM getAllID into @InvID
	  Delete @tempdebitID              
	 END 
 
	Close getAllID 
	Deallocate getAllID 
         
             
	 Declare getAllDebitID Cursor For Select  Distinct T.InvoiceID FROM @tempCollection T,ChequeCollDetails CD WITH (NOLOCK)
	 Where T.Type in(5) And T.invoiceID = CD.DocumentID and CD.DocumentType in(5) And isnull(CD.debitID,0)<> 0              
	Open getAllDebitID 
	Fetch FROM getAllDebitID into @InvID
	While @@fetch_status = 0 
	 BEGIN 
	  Insert into @tempdebitID
	  Select isnull(CD.DebitID,0) FROM ChequeCollDetails CD WITH (NOLOCK), collections C WITH (NOLOCK) Where C.CustomerID = @CustomerID And CD.DocumentID=@InvID  
	  And C.DocumentID = CD.CollectionID and CD.DocumentType in (5) And isnull(C.Status,0) & 192 = 0              
              
	  Update @tempCollection Set Balance = Balance + IsNull((Select sum(Balance) FROM debitnote WITH (NOLOCK) Where debitid in(select DebitID FROM @tempDebitID)),0), DisableEdit = 1 Where InvoiceID = @InvID 
	  Delete FROM @tempCollection Where InvoiceID in(Select debitid FROM @tempdebitID)              
              
	  Fetch Next FROM getAllDebitID into @InvID
	  Delete @tempdebitID              
	 END 
 
	Close getAllDebitID 
	Deallocate getAllDebitID 

	--Delete FROM @tempCollection where Balance > 0
	Delete @TSalesman  
	Delete @TBeat  
	Delete @tempdebitID  
	return;
END
GO