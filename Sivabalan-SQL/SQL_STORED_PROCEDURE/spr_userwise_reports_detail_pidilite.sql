CREATE procedure [dbo].[spr_userwise_reports_detail_pidilite] (@username nvarchar(50),     
      @fromDate datetime,     
      @toDate datetime)      
as      
select  InvoiceID,     
"DocumentID" = VoucherPrefix.Prefix + cast (InvoiceAbstract.DocumentID as nvarchar),    
"InvoiceType" = case InvoiceType    
when 1 then    
N'Invoice'    
when 2 then    
N'Retail Invoice'    
when 3 then    
N'Invoice Amendment'    
when 4 then    
N'Sales Return'     
when 5 then    
N'Retail SalesReturn Salable'     
when 6 then    
N'Retail SalesReturn Damage'     
else  
N''  
end,     
"Doc Reference" = DocReference,   
"Date" = InvoiceDate,    
"Customer Name" = ISNULL(Customer.Company_Name, N'No Customer'),    
"NetValue" = case      
WHEN InvoiceType>=4 and InvoiceType<=6 Then     
0 - (NetValue-isnull(Freight,0))     
Else        
NetValue-isnull(Freight,0)     
END      
FROM InvoiceAbstract, VoucherPrefix, Customer   
WHERE (InvoiceAbstract.Status & 128) = 0 and     
Username = @Username and     
InvoiceAbstract.CustomerID *= Customer.CustomerID And    
CreationTime Between @FromDate And @ToDate and     
VoucherPrefix.tranid = N'INVOICE'
