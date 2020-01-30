CREATE Procedure Sp_PrintInvoicesBySelection(
@FromDoc Decimal(18,6),
@ToDoc Decimal(18,6),
@Fromdate Datetime,
@Todate datetime,
@UDH Integer = 0,
@Mode Integer = 0,
@DocumentRef nvarchar(250)=N'')

as 


-- when @UDH = 0 it works For General when @UDH = 1 It works For Udhiyam also, @UDH =2 Specific Old Implementation
-- @mode = 0 Prnit By FromDoc No To TODoc Number
-- @Mode = 1 Print By FromSerial To ToSerial Number
-- @Mode = 2 Print By FromSequence To To Sequence

-- This is For General and when order by DocNumber is selected
If (@UDH = 0 and @Mode = 0)
Begin
         Select InvoiceID, VoucherPrefix.Prefix + Cast(Documentid as nvarchar) 
         From InvoiceAbstract, VoucherPrefix Where 
         DocumentId Between Cast(@FromDoc as integer)  And  Cast(@ToDoc as Integer)
         And InvoiceDate Between  @FromDate  And @todate 
         And InvoiceType in (1, 3) 
         And VoucherPrefix.TranID = N'INVOICE'       
End
If @UDH = 2 and @Mode = 0 
Begin
         Select InvoiceID, VoucherPrefix.Prefix + Cast(Documentid as nvarchar) 
         From InvoiceAbstract, VoucherPrefix,Customer Where 
         DocumentId Between Cast(@FromDoc as integer)  And  Cast(@ToDoc as integer) 
         And InvoiceDate Between  @FromDate  And @todate 
         And InvoiceType in (1, 3) 
         And VoucherPrefix.TranID = N'INVOICE'            
	 And InvoiceAbstract.CustomerID=Customer.CustomerID Order by IsNull(Customer.SequenceNo,0) asc
End

-- This is For General and when order by SerialNumber is selected
if @UDH = 1 and @Mode = 1 
Begin
         Select InvoiceID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar) 
         From InvoiceAbstract, VoucherPrefix Where 
         DocumentID Between Cast(@FromDoc as integer)  And  cast(@ToDoc  as integer) 
         And InvoiceDate Between  @FromDate  And @todate 
         And InvoiceType in (1,3) 
         And VoucherPrefix.TranID = N'INVOICE'
         And InvoiceAbstract.Status & 128 = 0
         order by DocumentId
End

-- This is For Udhaiyam 
If @UDH = 1 and @Mode = 0 --Doc Reference
Begin
	if Len(@DocumentRef)=0
	Begin
		Select InvoiceID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar) 
		From InvoiceAbstract, VoucherPrefix Where 
		((Case Isnumeric(DocReference)When 1 then Cast(DocReference as int)end)between @FromDoc And @ToDoc)
		And InvoiceDate Between  @FromDate  And @todate 
		And InvoiceType in (1, 3) 
		And VoucherPrefix.TranID = N'INVOICE'
		And InvoiceAbstract.Status & 128 = 0
		order by dbo.getTrueval(DocReference)
	End
	Else  
	Begin  
		SELECT InvoiceID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar)
		FROM InvoiceAbstract,VoucherPrefix
		WHERE InvoiceType In (1,3)  
		AND Docreference LIKE  @DocumentRef + N'%' + N'[0-9]'  
		AND (InvoiceAbstract.Status & 128) = 0   
		And (CASE ISnumeric(Substring(Docreference,Len(@DocumentRef)+1,Len(Docreference)))   
		When 1 then Cast(Substring(DocReference,Len(@DocumentRef)+1,Len(Docreference))as int)End)   
		BETWEEN @FromDoc and @ToDoc   
		And VoucherPrefix.TranID = N'INVOICE'
		order by dbo.getTrueval(DocReference)
	End  
eND

-- This is For Udhiyam and When Order by SequenceNumber is Selected
If @UDH = 1 and @Mode = 2 
Begin
         Select InvoiceID, VoucherPrefix.Prefix + Cast(DocumentID as nvarchar) 
         From InvoiceAbstract, VoucherPrefix,Customer Where 
         Customer.SequenceNo Between @FromDoc And @ToDoc 
         And InvoiceDate Between @FromDate And @ToDate 
         And InvoiceType in (1, 3) 
         And VoucherPrefix.TranID = N'INVOICE'
         And InvoiceAbstract.Status & 128 = 0         
         And InvoiceAbstract.CustomerID=Customer.CustomerID 
         Order by dbo.StripDateFromTime(invoicedate) ,IsNull(Customer.SequenceNo,0) asc
End



