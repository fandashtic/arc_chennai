CREATE PROCEDURE Spr_FreeSalesListing_detail ( @PRODUCTCODE nvarchar(15), @FROMDATE DATETIME, @TODATE DATETIME)      
AS    
BEGIN    
    
Select Invoiceabstract.InvoiceID,"DocumentID" = case IsNull(InvoiceAbstract.GSTFlag,0) when 0 then Convert(nVarchar,Invoiceabstract.DocumentID) Else ISNULL(InvoiceAbstract.GSTFullDocID,'')end,  
Invoiceabstract.DocReference as "Doc.Reference",   
Invoiceabstract.InvoiceDate,    
"Customer Name" = (select Company_Name from customer where customerid = invoiceabstract.customerid),     
case      
when InvoiceAbstract.InvoiceType >=4 and InvoiceAbstract.InvoiceType <=6   
 then 0 - Invoicedetail.Quantity     
else  Invoicedetail.Quantity end  as "Quantity"  
From Invoicedetail,Invoiceabstract  
Where Invoicedetail.InvoiceID = Invoiceabstract.InvoiceID     
And Invoicedetail.Saleprice = 0   
And (status & 128) = 0   
And Invoicedetail.product_code = @PRODUCTCODE    
And InvoiceAbstract.invoicedate BETWEEN @FROMDATE AND @TODATE    
   
END   
