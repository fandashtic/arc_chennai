CREATE procedure [dbo].[spr_list_itemwise_customer](@ITEMCODE nvarchar(15),   
		 @CusType nvarchar(50),
         @FROMDATE DATETIME,  
         @TODATE DATETIME)  
AS  
Declare @OTHERCUSTOMER As NVarchar(50)

Set @OTHERCUSTOMER = dbo.LookupDictionaryItem(N'Other Customer', Default)
  
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
 + CAST(InvoiceAbstract.DocumentID AS nvarchar),   
"Doc Refence"=DocReference,  
"Invoice Date" = InvoiceDate, "CustomerID" = InvoiceAbstract.CustomerID,  
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
SELECT "InvID" = InvoiceAbstract.InvoiceID,   
"InvoiceID" = (SELECT Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE')+ CAST(InvoiceAbstract.DocumentID AS nvarchar),   
"Doc Refence"=DocReference,  
"Invoice Date" = InvoiceDate,   
"CustomerID" = (Case WHEN InvoiceAbstract.CustomerID = '0' THEN @OTHERCUSTOMER ELSE InvoiceAbstract.CustomerID END),  
"Company" = IsNull(customer.company_name,@OTHERCUSTOMER),  
"Quantity" = Sum(InvoiceDetail.Quantity),     
"Value (%c)" = sum(InvoiceDetail.Amount)  
FROM InvoiceAbstract, customer, InvoiceDetail  
WHERE InvoiceDetail.Product_Code = @ITEMCODE   
AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
AND InvoiceAbstract.InvoiceType IN (2)  
AND (InvoiceAbstract.Status & 128) = 0  
AND InvoiceAbstract.CustomerID *= Cast(customer.CustomerID As nvarchar)   
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
GROUP BY InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID,InvoiceAbstract.DocReference,   
InvoiceAbstract.InvoiceDate, InvoiceAbstract.CustomerID, customer.company_name,   
InvoiceAbstract.InvoiceType  
Order By InvoiceAbstract.CustomerID, InvoiceAbstract.InvoiceDate, InvoiceAbstract.DocumentID  
END
