CREATE PROCEDURE spr_list_tradingmargins_Customer_Detail(@CustomerID nvarchar(255),    
                 @FROMDATE DATETIME,     
        @TODATE DATETIME)    
AS    
Declare @INVOICE As NVarchar(50)  
Declare @RETAILINVOICE As NVarchar(50)  
    
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice',Default)  
Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice',Default)  
  
Declare @Pos integer    
Declare @InvoiceType nvarchar(50)    
Declare @Voucher as varchar(100)              
Select @Voucher = Prefix From VoucherPrefix Where TranID = 'INVOICE'   
Set @Pos = charindex(':', @CustomerID)        
Set @InvoiceType = (Case substring(@CustomerID, @Pos+1, 1) When 1 Then @INVOICE Else @RETAILINVOICE End)    
Set @CustomerID = substring(@CustomerID, 1, @Pos-1)         
If @InvoiceType = @INVOICE  
Begin    
Select  DocumentId, "InvoiceID" = Case IsNull(InvoiceAbstract.GSTFlag,0) when 0 then @Voucher + Cast(DocumentID as varchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'') END, "Invoice Type" = @INVOICE , "Document Type" = DocSerialType, "Document Number" = DocReference, "Invoice Amount" = Sum(a.Amount), "Invoice Date" = InvoiceAbstract.InvoiceDate,     
"SalesMargin" = (ISNULL(Sum(a.Amount),0) - Sum(ISNULL(a.PurchasePrice, 0))      
- ABS(ISNULL(Sum(a.STPayable), 0))       
- ABS(ISNULL(Sum(a.CSTPayable), 0))      
- ISNULL(SUM(a.PurchasePrice * a.TaxSuffered / 100), 0))       
    
From InvoiceAbstract , InvoiceDetail a, Customer    
Where InvoiceAbstract.InvoiceID = a.InvoiceID    
and InvoiceAbstract.CustomerID = Customer.CustomerID     
and InvoiceAbstract.CustomerID = @CustomerID    
AND InvoiceAbstract.Status & 128 = 0      
AND InvoiceAbstract.InvoiceType in (1,3)     
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE    
Group by DocumentID, DocSerialType, DocReference, InvoiceAbstract.InvoiceDate, Customer.CustomerID,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID     
ENd     
Else If @InvoiceType = @RETAILINVOICE  
Begin    
Select  DocumentId, "InvoiceID" =  Case IsNull(InvoiceAbstract.GSTFlag,0) when 0 then @Voucher + Cast(DocumentID as varchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'') END, "Invoice Type" = @RETAILINVOICE, "Document Type" = DocSerialType, "Document Number" = DocReference, "Invoice Amount" = Sum(a.Amount), "Invoice Date" = InvoiceAbstract.InvoiceDate, 
    
"SalesMargin" = (ISNULL(Sum(a.Amount),0) - Sum(ISNULL(a.PurchasePrice, 0))      
- ABS(ISNULL(Sum(a.STPayable), 0))       
- ABS(ISNULL(Sum(a.CSTPayable), 0))      
- ISNULL(SUM(a.PurchasePrice * a.TaxSuffered / 100), 0))       
    
From InvoiceAbstract 
Inner Join InvoiceDetail a on InvoiceAbstract.InvoiceID = a.InvoiceID  
Left Outer Join Customer on InvoiceAbstract.CustomerID = Customer.CustomerID
Where 
--InvoiceAbstract.InvoiceID = a.InvoiceID    
--and InvoiceAbstract.CustomerID *= Customer.CustomerID And    
InvoiceAbstract.CustomerID = @CustomerID    
AND InvoiceAbstract.Status & 128 = 0      
AND InvoiceAbstract.InvoiceType in (2)     
AND Quantity > 0    
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE    
Group by DocumentID, DocSerialType, DocReference, InvoiceAbstract.InvoiceDate, Customer.CustomerID  ,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID  
End  

