CREATE procedure [dbo].[spr_list_itemwise_customer_pidilite](
@ITEMCODE nvarchar(15),
@UOM nvarchar(100),
@CusType nvarchar(50),
@FROMDATE DATETIME,
@TODATE DATETIME)  
AS
Declare @TotQty decimal(18,6)
Declare @TotValue Decimal (18,6)
Declare @UOM1_Conversion Decimal (18,6)
Declare @UOM2_Conversion Decimal (18,6)

Select @UOM1_Conversion = UOM1_Conversion, @UOM2_Conversion =UOM2_Conversion From Items Where Product_Code = @ITEMCODE

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
"Doc Reference"=DocReference,  
"Invoice Date" = InvoiceDate, "CustomerID" = InvoiceAbstract.CustomerID,  
"Company" = Customer.Company_Name,  
"Base Quantity" = 
(Case Max(InvoiceAbstract.InvoiceType) When 4 Then  
 Case When (Max(InvoiceAbstract.Status) & 32) = 0  Then 0 - Sum(InvoiceDetail.Quantity) Else 0 End    
 Else Sum(InvoiceDetail.Quantity) End),
"Quantity" = 
(Case Max(InvoiceAbstract.InvoiceType) When 4 Then
 Case When (Max(InvoiceAbstract.Status) & 32) = 0  Then 0 - (
 Case @UOM When 'Sales UOM' Then Sum(InvoiceDetail.Quantity)
           When 'UOM1' Then dbo.sp_Get_ReportingQty(Sum(InvoiceDetail.Quantity), Max(UOM1_Conversion))
	   When 'UOM2' Then dbo.sp_Get_ReportingQty(Sum(InvoiceDetail.Quantity), Max(UOM2_Conversion)) End)
 Else 0 End    
 Else 
(Case @UOM When 'Sales UOM' Then Sum(InvoiceDetail.Quantity)
           When 'UOM1' Then dbo.sp_Get_ReportingQty(Sum(InvoiceDetail.Quantity), Max(UOM1_Conversion))
           When 'UOM2' Then dbo.sp_Get_ReportingQty(Sum(InvoiceDetail.Quantity), Max(UOM2_Conversion)) End) End),
"Value (%c)" = sum(Case InvoiceAbstract.InvoiceType
When 4 Then   
case  When (InvoiceAbstract.Status & 32) = 0  Then   
0 - InvoiceDetail.Amount  
Else 0   
End    
Else InvoiceDetail.Amount  
End),GetDate() As CreationDate InTo #TradeTempList
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
InvoiceAbstract.InvoiceType  
Order By InvoiceAbstract.CustomerID, InvoiceAbstract.InvoiceDate, InvoiceAbstract.DocumentID  

Select @TotQty = Case @UOM when 'Sales UOM' Then sum([Base Quantity]) 
			   When 'UOM1' Then dbo.sp_Get_ReportingQty(Sum([Base Quantity]),@UOM1_Conversion)
			   When 'UOM2' Then dbo.sp_Get_ReportingQty(Sum([Base Quantity]),@UOM2_Conversion) End ,
@TotValue = Sum([Value (%c)])
From #TradeTempList

Insert Into #TradeTempList ([InvID],[InvoiceID],[Quantity],[Value (%c)],[CreationDate]) 
Values ('','Grand Total',@TotQty,@TotValue,GetDate()+1)

Select [InvID],[InvoiceID],[Doc Reference],[Invoice Date],[CustomerID],[Company],[Quantity],[Value (%c)]
from #TradeTempList 
Order by creationdate
END  
ELSE  
BEGIN  
SELECT "InvID" = InvoiceAbstract.InvoiceID,   
"InvoiceID" = (SELECT Prefix FROM VoucherPrefix WHERE TranID = 'INVOICE')+ CAST(InvoiceAbstract.DocumentID AS nvarchar),   
"Doc Refence"=DocReference,  
"Invoice Date" = InvoiceDate,   
"CustomerID" = (Case WHEN InvoiceAbstract.CustomerID = '0' THEN 'Other Customer' ELSE InvoiceAbstract.CustomerID END),  
"Company" = IsNull(Cash_Customer.CustomerName,'Other Customer'),  
"Base Quantity" = Sum(InvoiceDetail.Quantity),
"Quantity" = 
(Case @UOM When 'Sales UOM' Then Sum(InvoiceDetail.Quantity)
           When 'UOM1' Then dbo.sp_Get_ReportingQty(Sum(InvoiceDetail.Quantity), Max(UOM1_Conversion))
           When 'UOM2' Then dbo.sp_Get_ReportingQty(Sum(InvoiceDetail.Quantity), Max(UOM2_Conversion)) End),
"Value (%c)" = sum(InvoiceDetail.Amount),GetDate() As CreateDate InTo #RerailTempList
FROM InvoiceAbstract, Cash_Customer, InvoiceDetail, Items  
WHERE InvoiceDetail.Product_Code = @ITEMCODE   
AND InvoiceDetail.InvoiceID = InvoiceAbstract.InvoiceID  
AND Items.Product_Code = InvoiceDetail.Product_Code
AND InvoiceAbstract.InvoiceType IN (2)  
AND (InvoiceAbstract.Status & 128) = 0  
AND InvoiceAbstract.CustomerID *= Cast(Cash_Customer.CustomerID As nvarchar)   
AND InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
GROUP BY InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID,InvoiceAbstract.DocReference,   
InvoiceAbstract.InvoiceDate, InvoiceAbstract.CustomerID, Cash_Customer.CustomerName,   
InvoiceAbstract.InvoiceType  
Order By InvoiceAbstract.CustomerID, InvoiceAbstract.InvoiceDate, InvoiceAbstract.DocumentID  

Select @TotQty = Case @UOM when 'Sales UOM' Then sum([Base Quantity]) 
			   When 'UOM1' Then dbo.sp_Get_ReportingQty(Sum([Base Quantity]),@UOM1_Conversion)
			   When 'UOM2' Then dbo.sp_Get_ReportingQty(Sum([Base Quantity]),@UOM2_Conversion) End ,
@TotValue = Sum([Value (%c)])
From #TradeTempList

Insert Into #TradeTempList ([InvID],[InvoiceID],[Quantity],[Value (%c)],[CreationDate]) 
Values ('','Grand Total',@TotQty,@TotValue,GetDate()+1)


Select [InvID],[InvoiceID],[Doc Refence],[Invoice Date],[CustomerID],[Company],[Quantity],[Value (%c)] 
From #RerailTempList 
Order By CreateDate
END
