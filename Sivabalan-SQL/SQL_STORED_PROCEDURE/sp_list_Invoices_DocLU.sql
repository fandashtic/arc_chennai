CREATE PROCEDURE sp_list_Invoices_DocLU (@FromDocID int,@ToDocID int,@DocumentRef nvarchar(510)=N'')  
AS  
IF Len(@DocumentRef)=0
Begin  
	SELECT InvoiceID, InvoiceDate, Customer.Company_Name,   
		InvoiceAbstract.CustomerID, NetValue, InvoiceType, Status,  
		DocumentID, Balance,DocReference,DocSerialType,isnull(GSTFullDocID, '') as GSTFullDocID  
	FROM InvoiceAbstract, Customer  
	WHERE InvoiceAbstract.CustomerID = Customer.CustomerID  
		AND (DocumentID BETWEEN @FromDocID AND @ToDocID  
		OR (Case Isnumeric(DocReference) When 1 then Cast(DocReference as Decimal(18,6))Else N'0' end)between @FromDocID And @ToDocID)  
		And InvoiceType In (1, 3, 4)  
	ORDER BY Customer.Company_Name, InvoiceAbstract.InvoiceDate  
End  
Else  
Begin  
	SELECT InvoiceID, InvoiceDate, Customer.Company_Name,   
		InvoiceAbstract.CustomerID, NetValue, InvoiceType, Status,  
		DocumentID, Balance,DocReference,DocSerialType,isnull(GSTFullDocID, '') as GSTFullDocID  
	FROM InvoiceAbstract, Customer  
	WHERE InvoiceAbstract.CustomerID = Customer.CustomerID   
		And InvoiceType In (1, 3, 4)  
		AND (InvoiceAbstract.Status & 1024) = 0   
		AND (DocumentID BETWEEN @FromDocID AND @ToDocID  
		OR (Docreference LIKE  @DocumentRef + N'%' + N'[0-9]'  
		AND (CAse ISnumeric(Substring(Docreference,Len(@DocumentRef)+1,Len(Docreference)))   
			When 1 then Cast(Substring(DocReference,Len(@DocumentRef)+1,Len(Docreference))as Decimal(18,6))End)   
			BETWEEN @FromDocID and @ToDocID))   
	ORDER BY Customer.Company_Name, InvoiceAbstract.InvoiceDate  
End

