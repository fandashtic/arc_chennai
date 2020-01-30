
CREATE FUNCTION GetDocReferencesForSalesman_ITC(@SALESMAN int, @FROMDATE datetime, @TODATE datetime, @FROMNO nvarchar(50), @TONO nvarchar(50), @DocPrefix nVarchar(20))    
RETURNS nvarchar(4000)    
begin    
DECLARE @Invoices nvarchar(4000)    
DECLARE @INVOICEID nvarchar(50)    
    
IF @FROMNO = '%' OR @TONO = '%'    
BEGIN    
  If @DocPrefix = '%'   
 Begin  
 DECLARE GetInvoiceID CURSOR STATIC FOR      
 Select  Cast(DocSerialType As nVarChar) + Cast(' '  As nVarchar) + Cast(DocReference As nVarChar) From InvoiceAbstract      
 Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
 (InvoiceAbstract.Status & 128) = 0 And       
 InvoiceAbstract.InvoiceType in (1, 3) And      
 InvoiceAbstract.SalesmanID = @SALESMAN   
 Order BY InvoiceAbstract.DocumentID      
 End  
  Else  
    Begin  
 DECLARE GetInvoiceID CURSOR STATIC FOR      
 Select  Cast(DocSerialType As nVarChar) + Cast(' '  As nVarchar) + Cast(DocReference As nVarChar) From InvoiceAbstract      
 Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
 (InvoiceAbstract.Status & 128) = 0 And       
 InvoiceAbstract.InvoiceType in (1, 3) And      
 InvoiceAbstract.SalesmanID = @SALESMAN  And  
 DocSerialType = @DocPrefix  
 Order BY InvoiceAbstract.DocumentID      
 End  
END    
ELSE    
BEGIN  
     If @DocPrefix = '%'   
 Begin  
 DECLARE GetInvoiceID CURSOR STATIC FOR      
  Select  Cast(DocSerialType As nVarChar) + Cast(' '  As nVarchar) + Cast(DocReference As nVarChar) From InvoiceAbstract      
 Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
 (InvoiceAbstract.Status & 128) = 0 And       
 InvoiceAbstract.InvoiceType in (1, 3) And      
 InvoiceAbstract.SalesmanID = @SALESMAN And  
 dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FromNo) And dbo.GetTrueVal(@ToNo)  
 Order BY InvoiceAbstract.DocumentID      
 End  
  Else  
    Begin  
 DECLARE GetInvoiceID CURSOR STATIC FOR      
  Select  Cast(DocSerialType As nVarChar) + Cast(' '  As nVarchar) + Cast(DocReference As nVarChar) From InvoiceAbstract      
 Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
 (InvoiceAbstract.Status & 128) = 0 And       
 InvoiceAbstract.InvoiceType in (1, 3) And      
 InvoiceAbstract.SalesmanID = @SALESMAN  And  
 DocSerialType = @DocPrefix And  
 dbo.GetTrueVal(InvoiceAbstract.DocReference) Between dbo.GetTrueVal(@FromNo) And dbo.GetTrueVal(@ToNo)  
 Order BY InvoiceAbstract.DocumentID      
 End  
END    
    
Open GetInvoiceID    
Fetch From GetInvoiceID Into @INVOICEID    
While @@FETCH_STATUS = 0    
BEGIN    
 Set @Invoices = IsNull(@Invoices, '') + ',' + @INVOICEID    
 Fetch Next From GetInvoiceID Into @INVOICEID    
END    
Close GetInvoiceID    
Deallocate GetInvoiceID    
RETURN Substring(@Invoices, 2, 4000)    
End    
 

