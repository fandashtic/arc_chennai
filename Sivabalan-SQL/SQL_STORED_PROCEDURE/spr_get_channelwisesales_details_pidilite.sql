CREATE procedure spr_get_channelwisesales_details_pidilite (      
        @channel integer,      
        @FromDate datetime,      
        @ToDate datetime)      
as  
DECLARE @Prefix nvarchar(50)  
SELECT @Prefix = Prefix From VoucherPrefix Where TranID = 'INVOICE'  
select customer.customerid, "CustomerID" = customer.customerid, "Customer Name" = customer.company_name,   
"Doc Reference" = DocReference,  
"InvoiceID" = @Prefix+cast(invoiceabstract.documentid as nvarchar), "Invoice Date" = invoiceabstract.invoicedate,      
"Total Sales (%c)" =    
case invoicetype    
when 4 then    
 0-invoiceabstract.NetValue-IsNull(invoiceabstract.freight,0)  
else    
 invoiceabstract.NetValue-IsNull(invoiceabstract.freight,0)  
END     
from customer,invoiceabstract where invoiceabstract.customerid=customer.customerid and       
IsNull(customer.channeltype, 0)= IsNull(@channel, 0) and      
invoiceabstract.invoicedate between @FromDate and @ToDate and      
invoiceabstract.InvoiceType in (1, 3,4) AND( (Status & 128) = 0)    
  

