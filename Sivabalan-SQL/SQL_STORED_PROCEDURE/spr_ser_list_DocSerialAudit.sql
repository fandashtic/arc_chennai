CREATE Procedure spr_ser_list_DocSerialAudit
(@Fromdate datetime,@Todate datetime ,@TranName varchar(100))
As

Declare @VoucherPrefix nvarchar(20)
Declare @TranType int
Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='INVOICE'
Select @TranType=TransactionID From TransactionType Where Transactionname like @TranName

 --For Invoice
If (@TranType=1)
Begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='INVOICE'		
	
	Select Invoiceid,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocReference,
	"Document Type"=DocSerialType 
	From InvoiceAbstract OuterTab
	Where IsNull((Select Count(DocReference) from InvoiceAbstract InnerTab
					Where OuterTab.DocReference=InnerTab.DocReference
					And IsNull(InnerTab.Status,0) & 192=0),0) > 1
	And IsNull(Status,0) & 192 = 0
	And InvoiceType in (1,3) 
	And Invoicedate Between @FromDate And @Todate
	Order by OuterTab.DocReference
End
--For RetailInvoice
Else If (@TranType=2)
Begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='INVOICE'		
	
	Select Invoiceid,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocReference,
	"Document Type"=DocSerialType 
	From InvoiceAbstract OuterTab
	Where IsNull((Select Count(DocReference) from InvoiceAbstract InnerTab
					Where OuterTab.DocReference=InnerTab.DocReference
					And IsNull(InnerTab.Status,0) & 192=0),0) > 1
	And IsNull(Status,0) & 192 = 0
	And InvoiceType = 2 
	And Invoicedate Between @FromDate And @Todate
	Order by OuterTab.DocReference
End
--For SalesReturn
Else If (@TranType=3) 
Begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='INVOICE'		
	
	Select Invoiceid,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocReference,
	"Document Type"=DocSerialType 
	From InvoiceAbstract OuterTab
	Where IsNull((Select Count(DocReference) from InvoiceAbstract InnerTab
					Where OuterTab.DocReference=InnerTab.DocReference
					And IsNull(InnerTab.Status,0) & 192=0),0) > 1
	And IsNull(Status,0) & 192 = 0
	And InvoiceType = (4) 
	And Invoicedate Between @FromDate And @Todate
	Order by OuterTab.DocReference
End
--SalesConfirmation
Else If (@TranType=4) 
Begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='SALE CONFIRMATION'		
	
	Select SoNumber,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=documentreference,
	"Document Type"=DocSerialType 
	From SoAbstract OuterTab
	Where IsNull((Select Count(documentreference) from SoAbstract InnerTab
					Where OuterTab.documentreference=InnerTab.documentreference
					And IsNull(InnerTab.Status,0) & 64 = 0),0) > 1
	And IsNull(Status,0) & 64 = 0
	And SoDate Between @FromDate And @Todate
	Order by OuterTab.documentreference
End
--For Dispatch Note
Else If (@TranType=5) 
Begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='DISPATCH'		
	
	Select DispatchID,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocRef,
	"Document Type"=DocSerialType 
	From DispatchAbstract OuterTab
	Where IsNull((Select Count(DocRef) from DispatchAbstract InnerTab
					Where OuterTab.DocRef=InnerTab.DocRef
					And IsNull(InnerTab.Status,0) & 64 = 0),0) > 1
	And IsNull(Status,0) & 64 = 0
	And DispatchDate Between @FromDate And @Todate
	Order by OuterTab.DocRef
End
--For Purchase Return
Else If (@TranType=6) 
Begin
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='PURCHASE RETURN'		
	
	Select AdjustmentID,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=Reference,
	"Document Type"=DocSerialType 
	From AdjustmentReturnAbstract OuterTab
	Where IsNull((Select Count(Reference) from AdjustmentReturnAbstract InnerTab
					Where OuterTab.Reference=InnerTab.Reference
					And IsNull(InnerTab.Status,0) & 192 = 0),0) > 1
	And IsNull(Status,0) & 192 = 0
	And AdjustmentDate Between @FromDate And @Todate
	Order by OuterTab.Reference
End
--For GRN
Else If (@TranType=7) 
Begin
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='GOODS RECEIVED NOTE'		
	
	Select GRNID,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocumentReference,
	"Document Type"=DocSerialType 
	From GRNAbstract OuterTab
	Where IsNull((Select Count(DocumentReference) from GRNAbstract InnerTab
					Where OuterTab.DocumentReference=InnerTab.DocumentReference
					And IsNull(InnerTab.GRNStatus,0) & 192 = 0),0) > 1
	And IsNull(OuterTab.GRNStatus,0) & 192 = 0
	And OuterTab.GRNDate Between @FromDate And @Todate
	Order by OuterTab.DocumentReference
End
--For Bill
Else If (@TranType=8) 
Begin
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='BILL'		
	
	Select BillID,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocIDReference,
	"Document Type"=DocSerialType 
	From BillAbstract OuterTab
	Where IsNull((Select Count(DocIDReference) from BillAbstract InnerTab
					Where OuterTab.DocIDReference=InnerTab.DocIDReference
					And IsNull(InnerTab.Status,0) & 192 = 0),0) > 1
	And IsNull(OuterTab.Status,0) & 192 = 0
	And OuterTab.Billdate Between @FromDate And @Todate
	Order by OuterTab.DocIDReference
End
--For CreditNote
Else If (@TranType=9)
Begin
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='CREDIT NOTE'		
	
	Select CreditID,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocumentReference,
	"Document Type"=DocSerialType 
	From CreditNote OuterTab
	Where IsNull((Select Count(DocumentReference) from CreditNote InnerTab
					Where OuterTab.DocumentReference=InnerTab.DocumentReference
					And IsNull(InnerTab.Status,0) & 192 = 0),0) > 1
	And IsNull(OuterTab.Status,0) & 192 = 0
	And OuterTab.Documentdate Between @FromDate And @Todate
	Order by OuterTab.DocumentReference
End
--For DebitNote
Else If (@TranType=10) 
Begin
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='DEBIT NOTE'		
	
	Select DebitID,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocumentReference,
	"Document Type"=DocSerialType 
	From DebitNote OuterTab
	Where IsNull((Select Count(DocumentReference) from DebitNote InnerTab
					Where OuterTab.DocumentReference=InnerTab.DocumentReference
					And IsNull(InnerTab.Status,0) & 192 = 0),0) > 1
	And IsNull(OuterTab.Status,0) & 192 = 0
	And OuterTab.Documentdate Between @FromDate And @Todate
	Order by OuterTab.DocumentReference
End
--For Collections
Else If (@TranType=11) 
Begin
	Select DocumentID,"Serial No" = FullDocID,
	"DocID"=DocumentReference,
	"Document Type"=DocSerialType 
	From Collections OuterTab
	Where IsNull((Select Count(DocumentReference) from Collections InnerTab
					Where OuterTab.DocumentReference=InnerTab.DocumentReference
					And IsNull(InnerTab.Status,0) & 192 = 0),0) > 1
	And IsNull(OuterTab.Status,0) & 192 = 0
	And OuterTab.Documentdate Between @FromDate And @Todate
	Order by OuterTab.DocumentReference
End
--For Payments
Else If (@TranType=12) 
Begin
	Select DocumentID,"Serial No" = FullDocID,
	"DocID"=DocumentReference,
	"Document Type"=DocSerialType 
	From Payments OuterTab
	Where IsNull((Select Count(DocumentReference) from Payments InnerTab
					Where OuterTab.DocumentReference=InnerTab.DocumentReference
					And IsNull(InnerTab.Status,0) & 192 = 0),0) > 1
	And IsNull(OuterTab.Status,0) & 192 = 0
	And OuterTab.Documentdate Between @FromDate And @Todate
	Order by OuterTab.DocumentReference
End
--For Physical Stock Reconcilation
Else If (@TranType=13) 
Begin
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='STOCK RECONCILATION'		
	
	Select ReconcileID,"Serial No" = @VoucherPrefix + Cast(ReconcileID as varchar),
	"DocID"=DocumentReference,
	"Document Type"=DocSerialType 
	From ReconcileAbstract OuterTab
	Where IsNull((Select Count(DocumentReference) from ReconcileAbstract InnerTab
					Where OuterTab.DocumentReference=InnerTab.DocumentReference),0) > 1
	And CreationDate Between @FromDate And @Todate
	Order by OuterTab.DocumentReference
End
---For VanStockTransfer
Else If (@TranType=14)  
Begin
	Select Docserial,"Serial No" = DocPrefix + Cast(DocumentID as varchar),
	"DocID"=DocumentReference,
	"Document Type"=DocSerialType 
	From VANTRANSFERABSTRACT OuterTab
	Where IsNull((Select Count(DocumentReference) from Vantransferabstract InnerTab
					Where OuterTab.DocumentReference=InnerTab.DocumentReference),0) > 1
	And CreationDate Between @FromDate And @Todate
	Order by OuterTab.DocumentReference
End
--For Retail Sales Return
Else If (@TranType=17) 
Begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='INVOICE'		
	
	Select Invoiceid,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocReference,
	"Document Type"=DocSerialType 
	From InvoiceAbstract OuterTab
	Where IsNull((Select Count(DocReference) from InvoiceAbstract InnerTab
					Where OuterTab.DocReference=InnerTab.DocReference
					And IsNull(InnerTab.Status,0) & 192=0),0) > 1
	And IsNull(Status,0) & 192 = 0
	And InvoiceType In (5, 6) 
	And Invoicedate Between @FromDate And @Todate
	Order by OuterTab.DocReference
End
--- For Job Estimation 
Else If (@TranType=100) 
Begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='JOBESTIMATION'		
	
	Select Estimationid,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocRef,
	"Document Type"=DocSerialType
	From EstimationAbstract OuterTab
	Where IsNull((Select Count(DocRef) from EstimationAbstract InnerTab
					Where OuterTab.DocRef=InnerTab.DocRef
					And IsNull(InnerTab.Status,0) & 192=0),0) > 1
	AND IsNull(OuterTab.Status,0) & 192 = 0
	And OuterTab.EstimationDate Between @FromDate And @Todate
	Order by OuterTab.DocRef
End
--- For Job Card
Else If (@TranType=101) 
Begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='JOBCARD'		
	
	Select JobCardID,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocRef,
	"Document Type"=DocSerialType 
	From JobCardAbstract OuterTab
	Where IsNull((Select Count(DocRef) from JobCardAbstract InnerTab
					Where OuterTab.DocRef=InnerTab.DocRef
					And IsNull(InnerTab.Status,0) & 192=0),0) > 1
	And IsNull(OuterTab.Status,0) & 192 = 0
	And OuterTab.JobCardDate Between @FromDate And @Todate
	Order by OuterTab.DocRef
End
--- For Issue Spares
Else If (@TranType=102)
Begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='ISSUESPARES'		
	
	Select IssueID,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocRef,
	"Document Type"=DocSerialType 
	From IssueAbstract OuterTab
	Where IsNull((Select Count(DocRef) from IssueAbstract InnerTab
					Where OuterTab.DocRef=InnerTab.DocRef
					And IsNull(InnerTab.Status,0) & 192=0),0) > 1
	And IsNull(OuterTab.Status,0) & 192 = 0	
	And OuterTab.IssueDate Between @FromDate And @Todate
	Order by OuterTab.DocRef
End
--- For Service Invoice	
Else If (@TranType=103) 
Begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='SERVICEINVOICE'
	
	Select ServiceInvoiceID,"Serial No" = @VoucherPrefix + Cast(Documentid as varchar),
	"DocID"=DocReference,
	"Document Type"=DocSerialType 
	From ServiceInvoiceAbstract OuterTab
	Where IsNull((Select Count(DocReference) from ServiceInvoiceAbstract InnerTab
				Where OuterTab.DocReference=InnerTab.DocReference
				And IsNull(InnerTab.Status,0) & 192=0),0) > 1
	And IsNull(OuterTab.ServiceInvoiceType,0) = 1 
	And IsNull(OuterTab.Status,0) & 192 = 0	
	And OuterTab.ServiceInvoiceDate Between @FromDate And @Todate
	Order by OuterTab.DocReference
End
