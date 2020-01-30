CREATE procedure [dbo].[spr_ser_list_itemwise_customer](@ITEMCODE NVARCHAR(15),   
		 @CusType nVarchar(50),
         @FROMDATE DATETIME,  
         @TODATE DATETIME)  
AS  


IF @CusType = 'Trade'  
BEGIN  


SELECT "InvID" = InvoiceAbstract.InvoiceID,   
"InvoiceID" =  
CASE InvoiceType  
WHEN 1 THEN  
(SELECT Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE')  
ELSE  
(SELECT Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE AMENDMENT')  
END  
 + CAST(InvoiceAbstract.DocumentID AS VARCHAR),   
"Doc Refence"=DocReference,  
"Invoice Date" = InvoiceDate,
"CustomerID" = InvoiceAbstract.CustomerID,  
"Company" = Customer.Company_Name,  
"Quantity" = Sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
case  When (InvoiceAbstract.Status & 32) = 0  Then   
0 - InvoiceDetail.Quantity    
Else 0   
End    
Else InvoiceDetail.Quantity      
End),     
"Value (%c)" = sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
case  When (InvoiceAbstract.Status & 32) = 0  Then   
0 - InvoiceDetail.Amount  
Else 0   
End    
Else InvoiceDetail.Amount  
End)     
FROM InvoiceAbstract, Customer, InvoiceDetail
WHERE InvoiceDetail.Product_Code = @ITEMCODE   
AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
AND InvoiceAbstract.InvoiceType IN (1, 3, 4)  
AND (InvoiceAbstract.Status & 128) = 0  
AND InvoiceAbstract.CustomerID = Customer.CustomerID   
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
GROUP BY InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID,InvoiceAbstract.DocReference,   
InvoiceAbstract.InvoiceDate, InvoiceAbstract.CustomerID, Customer.Company_Name,   
InvoiceAbstract.InvoiceType  
Order By InvoiceAbstract.CustomerID, InvoiceAbstract.InvoiceDate, InvoiceAbstract.DocumentID  

END  
ELSE  
BEGIN 

Create Table #ItemwiseCustomer(InvID int,InvoiceID nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
DocReference nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,InvoiceDate datetime,
CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,Company nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
Quantity decimal(18,6),Value decimal(18,6))

Insert into #ItemwiseCustomer

SELECT "InvID" = InvoiceAbstract.InvoiceID,   
"InvoiceID" = (SELECT Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE')+ CAST(InvoiceAbstract.DocumentID AS VARCHAR),   
"Doc Refence"=DocReference,  
"Invoice Date" = InvoiceDate,   
"CustomerID" = (Case WHEN InvoiceAbstract.CustomerID = '0' THEN 'Other Customer' ELSE InvoiceAbstract.CustomerID END),  
"Company" = IsNull(customer.company_name,'Other Customer'),  
"Quantity" = Sum(InvoiceDetail.Quantity),     
"Value (%c)" = sum(InvoiceDetail.Amount)  
FROM InvoiceAbstract, customer, InvoiceDetail  
WHERE InvoiceDetail.Product_Code = @ITEMCODE   
AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
AND InvoiceAbstract.InvoiceType IN (2)  
AND (InvoiceAbstract.Status & 128) = 0  
AND InvoiceAbstract.CustomerID *= Cast(customer.CustomerID As nVarchar)   
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
GROUP BY InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID,InvoiceAbstract.DocReference,   
InvoiceAbstract.InvoiceDate, InvoiceAbstract.CustomerID, customer.company_name,   
InvoiceAbstract.InvoiceType  
Order By InvoiceAbstract.CustomerID, InvoiceAbstract.InvoiceDate, InvoiceAbstract.DocumentID  

Insert into #ItemwiseCustomer

SELECT "InvID" = ServiceInvoiceAbstract.ServiceInvoiceID,   
"InvoiceID" = (SELECT Prefix FROM VoucherPrefix WHERE TranID = 'SERVICEINVOICE')+ CAST(serviceInvoiceAbstract.DocumentID AS VARCHAR),   
"Doc Refence"=DocReference,  
"Invoice Date" = ServiceInvoiceDate,   
"CustomerID" = (Case WHEN ServiceInvoiceAbstract.CustomerID = '0' THEN 'Other Customer' ELSE ServiceInvoiceAbstract.CustomerID END),  
"Company" = IsNull(customer.company_name,'Other Customer'),  
"Quantity" = Sum(Isnull(serviceInvoiceDetail.Quantity,0)),     
"Value (%c)" = sum(Isnull(ServiceInvoiceDetail.NetValue,0))  
FROM ServiceInvoiceAbstract, customer,ServiceInvoiceDetail  
WHERE ServiceInvoiceDetail.SpareCode = @ITEMCODE   
AND serviceInvoiceDetail.serviceInvoiceID = serviceInvoiceAbstract.ServiceInvoiceID  
AND serviceInvoiceAbstract.serviceInvoiceType IN (1)  
AND Isnull(serviceInvoiceAbstract.Status,0) & 192 = 0  
AND serviceInvoiceAbstract.CustomerID *= Cast(customer.CustomerID As nVarchar)
AND serviceInvoiceAbstract.serviceInvoiceDate BETWEEN @FROMDATE AND @TODATE  
GROUP BY serviceInvoiceAbstract.serviceInvoiceID, serviceInvoiceAbstract.DocumentID,
serviceInvoiceAbstract.DocReference,   
serviceInvoiceAbstract.serviceInvoiceDate, serviceInvoiceAbstract.CustomerID, 
customer.company_name,   
serviceInvoiceAbstract.serviceInvoiceType  
Order By serviceInvoiceAbstract.CustomerID, serviceInvoiceAbstract.serviceInvoiceDate,
serviceInvoiceAbstract.DocumentID  


Select "InvID" = InvID,"InvoiceID" = InvoiceID,
"Doc Reference" = DocReference,
"Invoice Date" = InvoiceDate,
"CustomerID" = CustomerID,
"Company" = Company ,
"Quantity" = sum(Quantity),
"Value (%c)" = sum(Value)   
from #ItemwiseCustomer 
group by InvID,InvoiceID,DocReference,InvoiceDate,CustomerID,Company
order by CustomerID,InvoiceDate
drop table #ItemwiseCustomer 
END
