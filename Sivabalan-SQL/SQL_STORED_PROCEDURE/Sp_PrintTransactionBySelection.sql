CREATE Procedure Sp_PrintTransactionBySelection(
@FromDoc Decimal(18,6),
@ToDoc Decimal(18,6),
@Fromdate Datetime,
@Todate Datetime,
@TransType Int=0,
@Mode Int = 0,
@DocumentRef nvarchar(250)=N'')
As 


/*
Mode = 0 Prnit By FromDoc No To ToDoc Number (DocumentRefernce)
Mode = 1 Print By FromSerial To ToSerial Number (DocumentID)
*/ 
If @TransType=1 /* GRN */
Begin
	If @Mode=0
		Begin
			if Len(@DocumentRef)=0
				Select GRNID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar) 
				From GRNAbstract, VoucherPrefix Where 
				((Case Isnumeric(DocumentReference)When 1 then Cast(DocumentReference as int)end)between @FromDoc And @ToDoc)
				And GRNDate Between  @FromDate  And @todate 
				And (Isnull(GRNStatus,0) & 128) = 0
				And VoucherPrefix.TranID = N'GOODS RECEIVED NOTE'
				order by dbo.getTrueval(DocumentReference)
			Else  
				Select GRNID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar)
				From GRNAbstract,VoucherPrefix Where
				DocumentReference LIKE  @DocumentRef + N'%' + N'[0-9]'  
				And (Isnull(GRNStatus,0) & 128) = 0  
				And GRNDate Between  @FromDate  And @todate 
				And (CASE ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference)))   
				When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End)   
				Between @FromDoc and @ToDoc   
				And VoucherPrefix.TranID = N'GOODS RECEIVED NOTE'
				order by dbo.getTrueval(DocumentReference)
		End
	Else
		Select GRNID, VoucherPrefix.Prefix + Cast(Documentid as nvarchar) 
		From GRNAbstract, VoucherPrefix Where 
		DocumentID Between Cast(@FromDoc as integer)  And  Cast(@ToDoc as Integer)
		And GRNDate Between  @FromDate  And @todate 
		And (Isnull(GRNStatus,0) & 128) = 0
		And VoucherPrefix.TranID = N'GOODS RECEIVED NOTE'   
		Order By DocumentID
End /* END GRN */

Else If @TransType=2 /* BILL */
Begin
	If @Mode=0
		Begin
			if Len(@DocumentRef)=0
				Select BillID, DocumentID
				From BillAbstract Where 
				((Case Isnumeric(DocIDReference)When 1 then Cast(DocIDReference as int)end)between @FromDoc And @ToDoc)
				And BillDate Between  @FromDate  And @todate 
				And (Isnull(Status,0) & 128) = 0
				order by dbo.getTrueval(DocIDReference)
			Else  
				Select BillID, DocumentID
				From BillAbstract Where
				DocIDReference LIKE  @DocumentRef + N'%' + N'[0-9]'  
				And (Isnull(Status,0) & 128) = 0 
				And BillDate Between  @FromDate  And @todate 
				And (CASE ISnumeric(Substring(DocIDReference,Len(@DocumentRef)+1,Len(DocIDReference)))   
				When 1 then Cast(Substring(DocIDReference,Len(@DocumentRef)+1,Len(DocIDReference))as int)End)   
				Between @FromDoc and @ToDoc   
				order by dbo.getTrueval(DocIDReference)
		End
	Else
		Select BillID, Documentid
		From BillAbstract Where 
		DocumentID Between Cast(@FromDoc as integer)  And  Cast(@ToDoc as Integer)
		And BillDate Between  @FromDate  And @todate 
		And (Isnull(Status,0) & 128) = 0
		Order By DocumentID
End /* END BILL */

Else If @TransType=3 /* SALE CONFIRMATION */
Begin
	If @Mode=0
		Begin
			if Len(@DocumentRef)=0
				Select SONumber, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar) 
				From SOAbstract, VoucherPrefix Where 
				((Case Isnumeric(DocumentReference)When 1 then Cast(DocumentReference as int)end)between @FromDoc And @ToDoc)
				And SODate Between  @FromDate  And @todate 
				And (Isnull(Status,0) & 128) = 0
				And VoucherPrefix.TranID = N'SALE CONFIRMATION'
				order by dbo.getTrueval(DocumentReference)
			Else  
				Select SONumber, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar)
				From SOAbstract,VoucherPrefix Where
				DocumentReference LIKE  @DocumentRef + N'%' + N'[0-9]'  
				And (Isnull(Status,0) & 128) = 0  
				And SODate Between  @FromDate  And @todate 
				And (CASE ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference)))   
				When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End)   
				Between @FromDoc and @ToDoc   
				And VoucherPrefix.TranID = N'SALE CONFIRMATION'
				order by dbo.getTrueval(DocumentReference)
		End
	Else
		Select SONumber, VoucherPrefix.Prefix + Cast(Documentid as nvarchar) 
		From SOAbstract, VoucherPrefix Where 
		DocumentID Between Cast(@FromDoc as integer)  And  Cast(@ToDoc as Integer)
		And SODate Between  @FromDate  And @todate 
		And (Isnull(Status,0) & 128) = 0
		And VoucherPrefix.TranID = N'SALE CONFIRMATION'   
		Order By DocumentID
End /* END SALE CONFIRMATION */

Else If @TransType=4 /* DISPATCH */
Begin
	If @Mode=0
		Begin
			if Len(@DocumentRef)=0
				Select DispatchID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar) 
				From DispatchAbstract, VoucherPrefix Where 
				((Case Isnumeric(DocRef)When 1 then Cast(DocRef as int)end)between @FromDoc And @ToDoc)
				And DispatchDate Between  @FromDate  And @todate 
				And (Isnull(Status,0) & 128) = 0
				And VoucherPrefix.TranID = N'DISPATCH'
				order by dbo.getTrueval(DocRef)
			Else  
				Select DispatchID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar)
				From DispatchAbstract,VoucherPrefix Where
				DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'  
				And (Isnull(Status,0) & 128) = 0  
				And DispatchDate Between  @FromDate  And @todate 
				And (CASE ISnumeric(Substring(DocRef,Len(@DocumentRef)+1,Len(DocRef)))   
				When 1 then Cast(Substring(DocRef,Len(@DocumentRef)+1,Len(DocRef))as int)End)   
				Between @FromDoc and @ToDoc   
				And VoucherPrefix.TranID = N'DISPATCH'
				order by dbo.getTrueval(DocRef)
		End
	Else
		Select DispatchID, VoucherPrefix.Prefix + Cast(Documentid as nvarchar) 
		From DispatchAbstract, VoucherPrefix Where 
		DocumentID Between Cast(@FromDoc as integer)  And  Cast(@ToDoc as Integer)
		And DispatchDate Between  @FromDate  And @todate 
		And (Isnull(Status,0) & 128) = 0
		And VoucherPrefix.TranID = N'DISPATCH'   
		Order By DocumentID
End /* END DISPATCH */

Else If @TransType=5 /* INVOICE */
Begin
	If @Mode=0
		Begin
			if Len(@DocumentRef)=0
				Select InvoiceID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar) 
				From InvoiceAbstract, VoucherPrefix Where 
				((Case Isnumeric(DocReference)When 1 then Cast(DocReference as int)end)between @FromDoc And @ToDoc)
				And InvoiceDate Between  @FromDate  And @todate 
				And (Isnull(Status,0) & 128) = 0
				And InvoiceType in (1, 3) 
				And VoucherPrefix.TranID = N'INVOICE'
				order by dbo.getTrueval(DocReference)
			Else  
				Select InvoiceID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar)
				From InvoiceAbstract,VoucherPrefix Where
				DocReference LIKE  @DocumentRef + N'%' + N'[0-9]'  
				And (Isnull(Status,0) & 128) = 0  
				And InvoiceDate Between  @FromDate  And @todate 
				And (CASE ISnumeric(Substring(DocReference,Len(@DocumentRef)+1,Len(DocReference)))   
				When 1 then Cast(Substring(DocReference,Len(@DocumentRef)+1,Len(DocReference))as int)End)   
				Between @FromDoc and @ToDoc   
				And InvoiceType in (1, 3) 
				And VoucherPrefix.TranID = N'INVOICE'
				order by dbo.getTrueval(DocReference)
		End
	Else
		Select InvoiceID, VoucherPrefix.Prefix + Cast(Documentid as nvarchar) 
		From InvoiceAbstract, VoucherPrefix Where 
		DocumentID Between Cast(@FromDoc as integer)  And  Cast(@ToDoc as Integer)
		And InvoiceDate Between  @FromDate  And @todate 
		And InvoiceType in (1, 3) 
		And (Isnull(Status,0) & 128) = 0
		And VoucherPrefix.TranID = N'INVOICE'   
		Order By DocumentID
End /* END INVOICE */

Else If @TransType=6 /* RETAIL INVOICE */
Begin
	If @Mode=0
		Begin
			if Len(@DocumentRef)=0
				Select InvoiceID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar) 
				From InvoiceAbstract, VoucherPrefix Where 
				((Case Isnumeric(DocReference)When 1 then Cast(DocReference as int)end)between @FromDoc And @ToDoc)
				And InvoiceDate Between  @FromDate  And @todate 
				And (Isnull(Status,0) & 128) = 0
				And InvoiceType =2
				And VoucherPrefix.TranID = N'RETAIL INVOICE'
				order by dbo.getTrueval(DocReference)
			Else  
				Select InvoiceID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar)
				From InvoiceAbstract,VoucherPrefix Where
				DocReference LIKE  @DocumentRef + N'%' + N'[0-9]'  
				And (Isnull(Status,0) & 128) = 0  
				And InvoiceDate Between  @FromDate  And @todate 
				And (CASE ISnumeric(Substring(DocReference,Len(@DocumentRef)+1,Len(DocReference)))   
				When 1 then Cast(Substring(DocReference,Len(@DocumentRef)+1,Len(DocReference))as int)End)   
				Between @FromDoc and @ToDoc   
				And InvoiceType =2
				And VoucherPrefix.TranID = N'RETAIL INVOICE'
				order by dbo.getTrueval(DocReference)
		End
	Else
		Select InvoiceID, VoucherPrefix.Prefix + Cast(Documentid as nvarchar) 
		From InvoiceAbstract, VoucherPrefix Where 
		DocumentID Between Cast(@FromDoc as integer)  And  Cast(@ToDoc as Integer)
		And InvoiceDate Between  @FromDate  And @todate 
		And InvoiceType=2
		And (Isnull(Status,0) & 128) = 0
		And VoucherPrefix.TranID = N'RETAIL INVOICE'   
		Order By DocumentID
End /* END RETAIL INVOICE */

Else If @TransType=7 /* CREDIT NOTE */
Begin
	If @Mode=0
		Begin
			if Len(@DocumentRef)=0
				Select CreditID,CustomerID,VoucherPrefix.Prefix + Cast(Documentid as nvarchar)  
				From CreditNote, VoucherPrefix Where 
				((Case Isnumeric(DocumentReference)When 1 then Cast(DocumentReference as int)end)between @FromDoc And @ToDoc)
				And DocumentDate Between  @FromDate  And @todate 
				And (Isnull(Status,0) & 128) = 0
				And VoucherPrefix.TranID = N'CREDIT NOTE'
				order by dbo.getTrueval(DocumentReference)
			Else  
				Select CreditID,CustomerID,VoucherPrefix.Prefix + Cast(Documentid as nvarchar)  
				From CreditNote, VoucherPrefix Where
				DocumentReference LIKE  @DocumentRef + N'%' + N'[0-9]'  
				And (Isnull(Status,0) & 128) = 0  
				And DocumentDate Between  @FromDate  And @todate 
				And (CASE ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference)))   
				When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End)   
				Between @FromDoc and @ToDoc   
				And VoucherPrefix.TranID = N'CREDIT NOTE'
				order by dbo.getTrueval(DocumentReference)
		End
	Else
		Select CreditID,CustomerID,VoucherPrefix.Prefix + Cast(Documentid as nvarchar)  
		From CreditNote, VoucherPrefix Where 
		DocumentID Between Cast(@FromDoc as integer)  And  Cast(@ToDoc as Integer)
		And DocumentDate Between  @FromDate  And @todate 
		And (Isnull(Status,0) & 128) = 0
		And VoucherPrefix.TranID = N'CREDIT NOTE'
		Order By DocumentID
End /* END CREDIT NOTE */

Else If @TransType=8 /* DEBIT NOTE */
Begin
	If @Mode=0
		Begin
			if Len(@DocumentRef)=0
				Select DebitID,CustomerID,VoucherPrefix.Prefix + Cast(Documentid as nvarchar)  
				From DebitNote, VoucherPrefix Where 
				((Case Isnumeric(DocumentReference)When 1 then Cast(DocumentReference as int)end)between @FromDoc And @ToDoc)
				And DocumentDate Between  @FromDate  And @todate 
				And (Isnull(Status,0) & 128) = 0
				And VoucherPrefix.TranID = N'DEBIT NOTE'
				order by dbo.getTrueval(DocumentReference)
			Else  
				Select DebitID,CustomerID,VoucherPrefix.Prefix + Cast(Documentid as nvarchar)  
				From DebitNote, VoucherPrefix Where
				DocumentReference LIKE  @DocumentRef + N'%' + N'[0-9]'  
				And (Isnull(Status,0) & 128) = 0  
				And DocumentDate Between  @FromDate  And @todate 
				And (CASE ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference)))   
				When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End)   
				Between @FromDoc and @ToDoc   
				And VoucherPrefix.TranID = N'DEBIT NOTE'
				order by dbo.getTrueval(DocumentReference)
		End
	Else
		Select DebitID,CustomerID,VoucherPrefix.Prefix + Cast(Documentid as nvarchar)  
		From DebitNote, VoucherPrefix Where 
		DocumentID Between Cast(@FromDoc as integer)  And  Cast(@ToDoc as Integer)
		And DocumentDate Between  @FromDate  And @todate 
		And (Isnull(Status,0) & 128) = 0
		And VoucherPrefix.TranID = N'DEBIT NOTE'
		Order By DocumentID
End /* END DEBIT NOTE */

Else If @TransType=9 /* COLLECTION */
Begin
	If @Mode=0
		Begin
			if Len(@DocumentRef)=0
				Select DocumentID,FullDocID	From Collections Where 
				((Case Isnumeric(DocumentReference)When 1 then Cast(DocumentReference as int)end)between @FromDoc And @ToDoc)
				And DocumentDate Between  @FromDate  And @todate 
				And (Isnull(Status,0) & 128) = 0
				order by dbo.getTrueval(DocumentReference)
			Else  
				Select DocumentID,FullDocID	From Collections Where 
				DocumentReference LIKE  @DocumentRef + N'%' + N'[0-9]'  
				And (Isnull(Status,0) & 128) = 0  
				And DocumentDate Between  @FromDate  And @todate 
				And (CASE ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference)))   
				When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End)   
				Between @FromDoc and @ToDoc   
				order by dbo.getTrueval(DocumentReference)
		End
	Else
		Select DocumentID,FullDocID	From Collections Where 
		dbo.GetTrueVal(FullDocID) Between Cast(@FromDoc as integer)  And  Cast(@ToDoc as Integer)
		And DocumentDate Between  @FromDate  And @todate 
		And (Isnull(Status,0) & 128) = 0
		Order By dbo.GetTrueVal(FullDocID)
End /* END COLLECTION */


Else If @TransType=10 /* PAYMENT */
Begin
	If @Mode=0
		Begin
			if Len(@DocumentRef)=0
				Select DocumentID,FullDocID	From Payments Where 
				((Case Isnumeric(DocumentReference)When 1 then Cast(DocumentReference as int)end)between @FromDoc And @ToDoc)
				And DocumentDate Between  @FromDate  And @todate 
				And (Isnull(Status,0) & 128) = 0
				order by dbo.getTrueval(DocumentReference)
			Else  
				Select DocumentID,FullDocID	From Payments Where 
				DocumentReference LIKE  @DocumentRef + N'%' + N'[0-9]'  
				And (Isnull(Status,0) & 128) = 0  
				And DocumentDate Between  @FromDate  And @todate 
				And (CASE ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference)))   
				When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End)   
				Between @FromDoc and @ToDoc   
				order by dbo.getTrueval(DocumentReference)
		End
	Else
		Select DocumentID,FullDocID	From Payments Where 
		dbo.GetTrueVal(FullDocID) Between Cast(@FromDoc as integer)  And  Cast(@ToDoc as Integer)
		And DocumentDate Between  @FromDate  And @todate 
		And (Isnull(Status,0) & 128) = 0
		Order By dbo.GetTrueVal(FullDocID)
End /* END PAYMENT */

