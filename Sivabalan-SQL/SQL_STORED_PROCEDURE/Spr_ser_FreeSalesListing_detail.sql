CREATE PROCEDURE Spr_ser_FreeSalesListing_detail ( @PRODUCTCODE varchar(15), @FROMDATE DATETIME, @TODATE DATETIME)    
AS  
BEGIN  

CREATE TABLE #FreeSalesTemp(InvId bigint,InvoiceId bigint ,
[Doc.Reference] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
InvoiceDate datetime,
[Customer Name] nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
Quantity Decimal(18,6))

Insert into #FreeSalesTemp
  
Select Invoiceabstract.InvoiceID, Invoiceabstract.InvoiceID,
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

Insert into #FreeSalesTemp

Select serviceInvoiceabstract.serviceInvoiceID, serviceInvoiceabstract.serviceInvoiceID,
serviceInvoiceabstract.DocReference as "Doc.Reference", 
serviceInvoiceabstract.serviceInvoiceDate,  
"Customer Name" = (select Company_Name from customer where customerid = serviceinvoiceabstract.customerid),   
serviceInvoicedetail.Quantity  as "Quantity"
From serviceInvoicedetail,serviceInvoiceabstract
Where serviceInvoicedetail.serviceInvoiceID = serviceInvoiceabstract.serviceInvoiceID   
And Isnull(serviceInvoicedetail.price,0) = 0 
And Isnull(status,0) & 192 = 0 
And serviceInvoicedetail.sparecode = @PRODUCTCODE  
And serviceInvoiceAbstract.serviceinvoicedate BETWEEN @FROMDATE AND @TODATE  

SELECT * FROM  #FreeSalesTemp order by Invoicedate
DROP TABLE #FreeSalesTemp
END  

