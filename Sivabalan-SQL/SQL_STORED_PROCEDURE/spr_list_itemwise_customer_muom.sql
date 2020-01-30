CREATE procedure spr_list_itemwise_customer_muom(@ITEMCODE nvarchar(15),   
												 @UOM nvarchar(100),
		    									 @CusType nvarchar(50),
										         @FROMDATE DATETIME,  
										         @TODATE DATETIME)  
AS  
If @UOM = N'Base UOM' 
	Set @UOM = N'Sales UOM'
IF @CusType = 'Trade'  
BEGIN  
SELECT
"InvID" = InvoiceAbstract.InvoiceID,   
"InvoiceID" =  Case ISNULL(InvoiceAbstract.GSTFlag,0) when 0 then 
CASE InvoiceType  
WHEN 1 THEN  
(SELECT Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE')  
ELSE  
(SELECT Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE AMENDMENT')  
END  
 + CAST(InvoiceAbstract.DocumentID AS nvarchar)
 Else ISNULL(InvoiceAbstract.GSTFullDocID,'') END,   
"Doc Reference"=DocReference,  
"Invoice Date" = InvoiceDate, "CustomerID" = InvoiceAbstract.CustomerID,  
"Company" = Customer.Company_Name,  
"Quantity" = Sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
case  When (InvoiceAbstract.Status & 32) = 0  Then   
0 - (Case @UOM When 'Sales UOM' Then InvoiceDetail.Quantity
               When 'UOM1' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM1_Conversion)
			   When 'UOM2' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM2_Conversion) End)
--InvoiceDetail.Quantity    
Else 0   
End    
Else (Case @UOM When 'Sales UOM' Then InvoiceDetail.Quantity
               When 'UOM1' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM1_Conversion)
			   When 'UOM2' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM2_Conversion) End)

End),     
"Value (%c)" = sum(Case InvoiceAbstract.InvoiceType   
When 4 Then   
case  When (InvoiceAbstract.Status & 32) = 0  Then   
0 - InvoiceDetail.Amount  
Else 0   
End    
Else InvoiceDetail.Amount  
End)     
FROM InvoiceAbstract, Customer, InvoiceDetail, Items  
WHERE InvoiceDetail.Product_Code = @ITEMCODE   
AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID
AND Items.Product_Code = InvoiceDetail.Product_Code  
AND InvoiceAbstract.InvoiceType IN (1, 3, 4)  
AND (InvoiceAbstract.Status & 128) = 0  
AND InvoiceAbstract.CustomerID = Customer.CustomerID   
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
GROUP BY InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID,InvoiceAbstract.DocReference,   
InvoiceAbstract.InvoiceDate, InvoiceAbstract.CustomerID, Customer.Company_Name,   
InvoiceAbstract.InvoiceType  ,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID
Order By InvoiceAbstract.CustomerID, InvoiceAbstract.InvoiceDate, InvoiceAbstract.DocumentID  
END  
ELSE  
BEGIN  
SELECT "InvID" = InvoiceAbstract.InvoiceID,   
"InvoiceID" = Case isnull(InvoiceAbstract.GSTFlag,0) When 0 then 
(SELECT Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE')+ CAST(InvoiceAbstract.DocumentID AS nvarchar) ELSE ISNULL(InvoiceAbstract.GSTFullDocID,'')END,   
"Doc Refence"=DocReference,  
"Invoice Date" = InvoiceDate,   
"CustomerID" = InvoiceAbstract.CustomerID,  
"Company" = Customer.Company_Name,  
"Quantity" = Sum(Case @UOM When 'Sales UOM' Then InvoiceDetail.Quantity
               When 'UOM1' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM1_Conversion)
			   When 'UOM2' Then dbo.sp_Get_ReportingQty(InvoiceDetail.Quantity, UOM2_Conversion) End),     
"Value (%c)" = sum(InvoiceDetail.Amount)  
FROM InvoiceAbstract
Inner Join InvoiceDetail On InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
Inner Join Items On Items.Product_Code = InvoiceDetail.Product_Code
Left Outer Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID    
WHERE InvoiceDetail.Product_Code = @ITEMCODE   
AND InvoiceAbstract.InvoiceType IN (2)  
AND (InvoiceAbstract.Status & 128) = 0  
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
GROUP BY InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID,InvoiceAbstract.DocReference,   
InvoiceAbstract.InvoiceDate, InvoiceAbstract.CustomerID, Customer.Company_Name,   
InvoiceAbstract.InvoiceType ,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID
Order By InvoiceAbstract.CustomerID, InvoiceAbstract.InvoiceDate, InvoiceAbstract.DocumentID  
END  
