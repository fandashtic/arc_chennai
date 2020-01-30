CREATE procedure spr_userwise_reports_detail (@username nvarchar(50),   
      @fromDate datetime,   
      @toDate datetime)    
as    
Declare @MLSalesReturn NVarchar(50)
Declare @MLRetailSalesReturnSalable NVarchar(50)
Declare @MLRetailSalesReturnDamage NVarchar(50)
Declare @MLRetailInvoice NVarchar(50)
Declare @MLInvoice NVarchar(50)
Declare @MLInvoiceAmendment NVarchar(50)
Declare @MLNoCustomer NVarchar(50)
Set @MLSalesReturn = dbo.LookupDictionaryItem(N'Sales Return', Default)
Set @MLRetailSalesReturnSalable = dbo.LookupDictionaryItem(N'Retail SalesReturn Salable', Default)
Set @MLRetailSalesReturnDamage = dbo.LookupDictionaryItem(N'Retail SalesReturn Damage', Default)
Set @MLRetailInvoice = dbo.LookupDictionaryItem(N'Retail Invoice', Default)
Set @MLInvoice = dbo.LookupDictionaryItem(N'Invoice', Default)
Set @MLInvoiceAmendment = dbo.LookupDictionaryItem(N'Invoice Amendment', Default)
Set @MLNoCustomer = dbo.LookupDictionaryItem(N'No Customer', Default)

select  InvoiceID,   
"DocumentID" = case isnull(GSTFlag,0) when 0 then  VoucherPrefix.Prefix + cast (InvoiceAbstract.DocumentID as nvarchar) Else ISNULL(GSTFullDocID,'') End,  
"InvoiceType" = case InvoiceType  
when 1 then  
@MLInvoice  
when 2 then  
@MLRetailInvoice  
when 3 then  
@MLInvoiceAmendment  
when 4 then  
@MLSalesReturn   
when 5 then  
@MLRetailSalesReturnSalable   
when 6 then  
@MLRetailSalesReturnDamage   
else
N''
end,   
"Date" = InvoiceDate,  
"Customer Name" = ISNULL(Customer.Company_Name, @MLNoCustomer),  
"NetValue" = case    
WHEN InvoiceType>=4 and InvoiceType<=6 Then   
0 - (NetValue-isnull(Freight,0))   
Else      
NetValue-isnull(Freight,0)   
END    
FROM InvoiceAbstract
Inner Join  VoucherPrefix On VoucherPrefix.tranid = N'INVOICE' 
Left Outer Join Customer  On InvoiceAbstract.CustomerID = Customer.CustomerID 
WHERE (InvoiceAbstract.Status & 128) = 0 and   
Username = @Username and   
CreationTime Between @FromDate And @ToDate 

