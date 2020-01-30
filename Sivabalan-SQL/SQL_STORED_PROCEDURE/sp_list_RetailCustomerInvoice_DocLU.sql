CREATE procedure [dbo].[sp_list_RetailCustomerInvoice_DocLU] (@FromDocID int, @ToDocID int,
						@Status int = 0,@DocumentRef nvarchar(510)=N'')
AS

If @Status = 0
Begin
	If Len(@DocumentRef)=0
	Begin
		SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID, 
		Customer.Company_Name, 
		NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType
		FROM Customer, InvoiceAbstract
		WHERE InvoiceAbstract.CustomerID = CAST(Customer.CustomerID AS NVARCHAR)
		AND (DocumentID BETWEEN @FromDocID AND @ToDocID
		OR (Case Isnumeric(DocReference) When 1 then Cast(DocReference as int)end)between @FromDocID And @ToDocID)
		AND InvoiceType = 2
		ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID
	End
	Else
	Begin
		SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID, 
		Customer.Company_Name, 
		NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType
		FROM Customer, InvoiceAbstract
		WHERE InvoiceAbstract.CustomerID = CAST(Customer.CustomerID AS NVARCHAR)		
		AND InvoiceType = 2 
		AND Docreference LIKE  @DocumentRef + N'%' + N'[0-9]'
		And (CAse ISnumeric(Substring(Docreference,Len(@DocumentRef)+1,Len(Docreference))) 
		When 1 then Cast(Substring(DocReference,Len(@DocumentRef)+1,Len(Docreference))as int)End) BETWEEN @FromDocID and @ToDocID
		ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID	
	End
End
Else
Begin
	If Len(@DocumentRef)=0
	Begin
		SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID, 
		Customer.Company_Name,  
		NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType
		FROM Customer, InvoiceAbstract
		WHERE InvoiceAbstract.CustomerID = CAST(Customer.CustomerID AS NVARCHAR)
		AND (DocumentID BETWEEN @FromDocID AND @ToDocID
		OR (Case Isnumeric(DocReference) When 1 then Cast(DocReference as int)end)between @FromDocID And @ToDocID)
		AND InvoiceType = 2
		AND Status & @Status = 0
		ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID
	End
	Else
	Begin	
		SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID, 
		Customer.Company_Name, 
		NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType
		FROM Customer, InvoiceAbstract
		WHERE InvoiceAbstract.CustomerID *= CAST(Customer.CustomerID AS NVARCHAR)
		AND Docreference like  @DocumentRef + N'%' + N'[0-9]'
		And (CAse ISnumeric(Substring(Docreference,Len(@DocumentRef)+1,Len(Docreference))) 
		When 1 then Cast(Substring(DocReference,Len(@DocumentRef)+1,Len(Docreference))as int)End) BETWEEN @FromDocID and @ToDocID
		AND InvoiceType = 2
		AND Status & @Status = 0
		ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID
	End
End
