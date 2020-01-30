CREATE Procedure spr_list_DocSerialAudit
(@Fromdate datetime,@Todate datetime ,@TranName nvarchar(100))
As
Declare @VoucherPrefix nvarchar(20)
Declare @TranType int
Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='INVOICE'
Select @TranType=TransactionID From TransactionType Where Transactionname like @TranName

--For Invoice
If (@TranType=1)
begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='INVOICE'		
	Select Invoiceid,
	--"Serial No" = @VoucherPrefix + cast(Documentid as nvarchar),
	"Serial No" =  Case ISNULL(OuterTab.GSTFlag,0) When 0 then @VoucherPrefix + cast(Documentid as nvarchar) ELSE ISNULL(OuterTab.GSTFullDocID,'') END, 
	"DocID"=DocReference,"Document Type"=DocSerialType 
	From InvoiceAbstract OuterTab
	Where ISnull(
	(Select Count(DocReference) from InvoiceAbstract InnerTab
	Where OuterTab.DocReference=InnerTab.DocReference
	And Isnull(InnerTab.Status,0) & 192=0),0) > 1
	And InvoiceType in (1,3) And Invoicedate Between @FromDate And @Todate
	And Isnull(Status,0) & 192 = 0
	Order by OuterTab.DocReference
End
--For RetailInvoice
Else If (@TranType=2)
begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='INVOICE'		
	Select Invoiceid,
	--"Serial No" = @VoucherPrefix + cast(Documentid as nvarchar),
	"Serial No" =  Case ISNULL(OuterTab.GSTFlag,0) When 0 then @VoucherPrefix + cast(Documentid as nvarchar) ELSE ISNULL(OuterTab.GSTFullDocID,'') END, 
	"DocID"=DocReference,"Document Type"=DocSerialType 
	From InvoiceAbstract OuterTab
	Where ISnull(
	(Select Count(DocReference) from InvoiceAbstract InnerTab
	Where OuterTab.DocReference=InnerTab.DocReference
	And Isnull(InnerTab.Status,0) & 192=0),0) > 1
	And InvoiceType = (2) And Invoicedate Between @FromDate And @Todate
	And Isnull(Status,0) & 192 = 0
	Order by OuterTab.DocReference
End
--For SalesReturn
Else If (@TranType=3)
begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='INVOICE'		
	Select Invoiceid,
	--"Serial No" = @VoucherPrefix + cast(Documentid as nvarchar),
	"Serial No" =  Case ISNULL(OuterTab.GSTFlag,0) When 0 then @VoucherPrefix + cast(Documentid as nvarchar) ELSE ISNULL(OuterTab.GSTFullDocID,'') END, 
	"DocID"=DocReference,"Document Type"=DocSerialType 
	From InvoiceAbstract OuterTab
	Where ISnull(
	(Select Count(DocReference) from InvoiceAbstract InnerTab
	Where OuterTab.DocReference=InnerTab.DocReference
	And Isnull(InnerTab.Status,0) & 192=0),0) > 1
	And InvoiceType = (4) And Invoicedate Between @FromDate And @Todate
	And Isnull(Status,0) & 192 = 0
	Order by OuterTab.DocReference
End
--SalesConfirmation
Else If (@TranType=4)
begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='SALE CONFIRMATION'		
	Select SoNumber,"Serial No" = @VoucherPrefix + cast(Documentid as nvarchar),
	"DocID"=documentreference,"Document Type"=DocSerialType 
	From SoAbstract OuterTab
	Where ISnull(
	(Select Count(documentreference) from SoAbstract InnerTab
	Where OuterTab.documentreference=InnerTab.documentreference
	And Isnull(InnerTab.Status,0) & 64 = 0),0) > 1
	And SoDate Between @FromDate And @Todate
	And Isnull(Status,0) & 64 = 0
	Order by OuterTab.documentreference
End

--For Dispatch Note
Else If (@TranType=5)
begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='DISPATCH'		
	Select DispatchID,"Serial No" = @VoucherPrefix + cast(Documentid as nvarchar),
	"DocID"=DocRef,"Document Type"=DocSerialType 
	From DispatchAbstract OuterTab
	Where ISnull(
	(Select Count(DocRef) from DispatchAbstract InnerTab
	Where OuterTab.DocRef=InnerTab.DocRef
 	And Isnull(InnerTab.Status,0) & 64 = 0),0) > 1
	And DispatchDate Between @FromDate And @Todate
	And Isnull(Status,0) & 64 = 0
	Order by OuterTab.DocRef
End
--For Purchase Return
Else If (@TranType=6)
begin
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='PURCHASE RETURN'		
	Select AdjustmentID,
	--"Serial No" = @VoucherPrefix + cast(Documentid as nvarchar),
	"Serial No" =  Case ISNULL(OuterTab.GSTFlag,0) When 0 then @VoucherPrefix + cast(Documentid as nvarchar) ELSE ISNULL(OuterTab.GSTFullDocID,'') END, 
	"DocID"=Reference,"Document Type"=DocSerialType 
	From AdjustmentReturnAbstract OuterTab
	Where ISnull(
	(Select Count(Reference) from AdjustmentReturnAbstract InnerTab
	Where OuterTab.Reference=InnerTab.Reference
	And Isnull(InnerTab.Status,0) & 192 = 0),0) > 1
	And AdjustmentDate Between @FromDate And @Todate
	And isnull(Status,0) & 192 = 0
	Order by OuterTab.Reference
End
--For GRN
Else If (@TranType=7)
begin
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='GOODS RECEIVED NOTE'		
	Select GRNID,"Serial No" = @VoucherPrefix + cast(Documentid as nvarchar),
	"DocID"=DocumentReference,"Document Type"=DocSerialType 
	From GRNAbstract OuterTab
	Where ISnull(
	(Select Count(DocumentReference) from GRNAbstract InnerTab
	Where OuterTab.DocumentReference=InnerTab.DocumentReference
	And Isnull(InnerTab.GRNStatus,0) & 192 = 0),0) > 1
  And OuterTab.GRNDate Between @FromDate And @Todate
	And Isnull(OuterTab.GRNStatus,0) & 192 = 0
	Order by OuterTab.DocumentReference
End
--For Bill
Else If (@TranType=8)
begin
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='BILL'		
	Select BillID,"Serial No" = @VoucherPrefix + cast(Documentid as nvarchar),
	"DocID"=DocIDReference,"Document Type"=DocSerialType 
	From BillAbstract OuterTab
	Where ISnull(
	(Select Count(DocIDReference) from BillAbstract InnerTab
	Where OuterTab.DocIDReference=InnerTab.DocIDReference
	And Isnull(InnerTab.Status,0) & 192 = 0),0) > 1
  And OuterTab.Billdate Between @FromDate And @Todate
	And Isnull(OuterTab.Status,0) & 192 = 0
	Order by OuterTab.DocIDReference
End
--For CreditNote
Else If (@TranType=9)
begin
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='CREDIT NOTE'		
	Select CreditID,"Serial No" = @VoucherPrefix + cast(Documentid as nvarchar),
	"DocID"=DocumentReference,"Document Type"=DocSerialType 
	From CreditNote OuterTab
	Where ISnull(
	(Select Count(DocumentReference) from CreditNote InnerTab
	Where OuterTab.DocumentReference=InnerTab.DocumentReference
	And Isnull(InnerTab.Status,0) & 192 = 0),0) > 1
  And OuterTab.Documentdate Between @FromDate And @Todate
	And Isnull(OuterTab.Status,0) & 192 = 0
	Order by OuterTab.DocumentReference
End
--For DebitNote
Else If (@TranType=10)
begin
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='DEBIT NOTE'		
	Select DebitID,"Serial No" = @VoucherPrefix + cast(Documentid as nvarchar),
	"DocID"=DocumentReference,"Document Type"=DocSerialType 
	From DebitNote OuterTab
	Where ISnull(
	(Select Count(DocumentReference) from DebitNote InnerTab
	Where OuterTab.DocumentReference=InnerTab.DocumentReference
	And Isnull(InnerTab.Status,0) & 192 = 0),0) > 1
  And OuterTab.Documentdate Between @FromDate And @Todate
	And Isnull(OuterTab.Status,0) & 192 = 0
	Order by OuterTab.DocumentReference
End
--For Collections
Else If (@TranType=11)
begin
	Select DocumentID,"Serial No" = FullDocID,
	"DocID"=DocumentReference,"Document Type"=DocSerialType 
	From Collections OuterTab
	Where ISnull(
	(Select Count(DocumentReference) from Collections InnerTab
	Where OuterTab.DocumentReference=InnerTab.DocumentReference
	And Isnull(InnerTab.Status,0) & 192 = 0),0) > 1
  And OuterTab.Documentdate Between @FromDate And @Todate
	And Isnull(OuterTab.Status,0) & 192 = 0
	Order by OuterTab.DocumentReference
End
--For DSWiseBeatwise Collections  
Else If (@TranType=60)  
begin  
 	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='DSWISE BEATWISE COLLECTION'    
	Select DocumentID,"Serial No" = @VoucherPrefix + cast(DocumentID as nvarchar),  
	"DocID"=DocReference,"Document Type"=DocSerialType   
	From InvoicewiseCollectionAbstract OuterTab  
	Where ISnull(  
	(Select Count(DocReference) from InvoicewiseCollectionAbstract InnerTab  
	Where OuterTab.DocReference=InnerTab.DocReference  
	And Isnull(InnerTab.Status,0) & 192 = 0),0) > 1  
  And OuterTab.CollectionDate Between @FromDate And @Todate  
	And Isnull(OuterTab.Status,0) & 192 = 0  
	Order by OuterTab.DocReference  
End 
--For Payments
Else If (@TranType=12)
begin
	Select DocumentID,"Serial No" = FullDocID,
	"DocID"=DocumentReference,"Document Type"=DocSerialType 
	From Payments OuterTab
	Where ISnull(
	(Select Count(DocumentReference) from Payments InnerTab
	Where OuterTab.DocumentReference=InnerTab.DocumentReference
	And Isnull(InnerTab.Status,0) & 192 = 0),0) > 1
  And OuterTab.Documentdate Between @FromDate And @Todate
	And Isnull(OuterTab.Status,0) & 192 = 0
	Order by OuterTab.DocumentReference
End
--For Physical Stock Reconcilation
Else If (@TranType=13)
begin
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='STOCK RECONCILATION'		
	Select ReconcileID,"Serial No" = @VoucherPrefix + cast(ReconcileID as nvarchar),
	"DocID"=DocumentReference,"Document Type"=DocSerialType 
	From ReconcileAbstract OuterTab
	Where ISnull(
	(Select Count(DocumentReference) from ReconcileAbstract InnerTab
	Where OuterTab.DocumentReference=InnerTab.DocumentReference),0) > 1
	And CreationDate Between @FromDate And @Todate
	Order by OuterTab.DocumentReference
End
---For VanStockTransfer
Else If (@TranType=14)
begin
	Select Docserial,"Serial No" = DocPrefix + cast(DocumentID as nvarchar),
	"DocID"=DocumentReference,"Document Type"=DocSerialType 
	From VANTRANSFERABSTRACT OuterTab
	Where ISnull(
	(Select Count(DocumentReference) from Vantransferabstract InnerTab
	Where OuterTab.DocumentReference=InnerTab.DocumentReference),0) > 1
	And CreationDate Between @FromDate And @Todate
	Order by OuterTab.DocumentReference
End
--For Retail Sales Return
Else If (@TranType=17)
begin	
	Select @VoucherPrefix=Prefix From VoucherPrefix Where Tranid='INVOICE'		
	Select Invoiceid,
	--"Serial No" = @VoucherPrefix + cast(Documentid as nvarchar),
	"Serial No" =  Case ISNULL(OuterTab.GSTFlag,0) When 0 then @VoucherPrefix + cast(Documentid as nvarchar) ELSE ISNULL(OuterTab.GSTFullDocID,'') END, 
	"DocID"=DocReference,"Document Type"=DocSerialType 
	From InvoiceAbstract OuterTab
	Where ISnull(
	(Select Count(DocReference) from InvoiceAbstract InnerTab
	Where OuterTab.DocReference=InnerTab.DocReference
	And Isnull(InnerTab.Status,0) & 192=0),0) > 1
	And InvoiceType In (5, 6) And Invoicedate Between @FromDate And @Todate
	And Isnull(Status,0) & 192 = 0
	Order by OuterTab.DocReference
End
