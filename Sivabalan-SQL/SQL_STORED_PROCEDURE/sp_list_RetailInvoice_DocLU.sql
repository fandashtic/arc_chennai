CREATE PROCEDURE sp_list_RetailInvoice_DocLU (@FromDocID int, @ToDocID int,    
      @Status int = 0,@DocumentRef nvarchar(510)=N'')    
AS    
    
Declare @NOCUSTOMER As NVarchar(50)  
Set @NOCUSTOMER = dbo.LookupDictionaryItem(N'No Customer', Default)  
  
If @Status = 0    
Begin    
If Len(@DocumentRef)=0    
 Begin    
  SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID,     
  CASE ISNULL(Customer.Company_Name,N'')     
  WHEN N'' THEN     
  @NOCUSTOMER  
  ELSE     
  Customer.Company_Name    
  END,     
  NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType,Balance,isnull(GSTFullDocID,'') as GSTFullDocID    
  FROM Customer
  Right Outer Join InvoiceAbstract On  InvoiceAbstract.CustomerID = CAST(Customer.CustomerID AS NVARCHAR)       
  WHERE (DocumentID BETWEEN @FromDocID AND @ToDocID    
  OR (Case Isnumeric(DocReference) When 1 then Cast(DocReference as int)end)between @FromDocID And @ToDocID)    
  AND InvoiceType In (2,5,6)    
  ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID    
 End    
 Else    
 Begin    
  SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID,     
  CASE ISNULL(Customer.Company_Name,N'')     
  WHEN N'' THEN     
  @NOCUSTOMER  
  ELSE     
  Customer.Company_Name    
  END,     
  NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType,Balance,isnull(GSTFullDocID,'') as GSTFullDocID    
  FROM Customer
  Right Outer Join InvoiceAbstract  On InvoiceAbstract.CustomerID = CAST(Customer.CustomerID AS NVARCHAR)        
  WHERE InvoiceType In (2,5,6)   
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
  CASE ISNULL(Customer.Company_Name,N'')     
  WHEN N'' THEN     
  @NOCUSTOMER  
  ELSE     
  Customer.Company_Name    
  END,     
  NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType,Balance,isnull(GSTFullDocID,'') as GSTFullDocID  
  FROM Customer
  Right Outer Join InvoiceAbstract On InvoiceAbstract.CustomerID = CAST(Customer.CustomerID AS NVARCHAR)       
  WHERE (DocumentID BETWEEN @FromDocID AND @ToDocID    
  OR (Case Isnumeric(DocReference) When 1 then Cast(DocReference as int)end)between @FromDocID And @ToDocID)    
  AND InvoiceType In (2,5,6)   
  AND Status & @Status = 0    
  ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID    
 End    
 Else    
 Begin     
  SELECT InvoiceID, InvoiceDate, InvoiceAbstract.CustomerID,     
  CASE ISNULL(Customer.Company_Name,N'')     
  WHEN N'' THEN     
  @NOCUSTOMER  
  ELSE     
  Customer.Company_Name    
  END,     
  NetValue, DocumentID, Status, InvoiceReference,DocReference,DocSerialType,Balance,isnull(GSTFullDocID,'') as GSTFullDocID  
  FROM Customer
  Right Outer Join  InvoiceAbstract On InvoiceAbstract.CustomerID = CAST(Customer.CustomerID AS NVARCHAR)       
  WHERE Docreference like  @DocumentRef + N'%' + N'[0-9]'    
  And (CAse ISnumeric(Substring(Docreference,Len(@DocumentRef)+1,Len(Docreference)))     
  When 1 then Cast(Substring(DocReference,Len(@DocumentRef)+1,Len(Docreference))as int)End) BETWEEN @FromDocID and @ToDocID    
  AND InvoiceType In (2,5,6)    
  AND Status & @Status = 0    
  ORDER BY InvoiceAbstract.CustomerID, InvoiceDate, InvoiceID    
 End    
End        
  
