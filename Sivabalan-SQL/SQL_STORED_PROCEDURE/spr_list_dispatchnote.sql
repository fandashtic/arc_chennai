CREATE Procedure [dbo].[spr_list_dispatchnote](@FROMDATE datetime,  
           @TODATE datetime)  
AS  
  
DECLARE @INV AS nvarchar(50)  
DECLARE @SO AS nvarchar(50)  
DECLARE @PO AS nvarchar(50)  
declare @Status as nvarchar(255)  
declare @disp_Status as int  

Declare @OPEN As NVarchar(50)
Declare @CLOSED As NVarchar(50)
Declare @CANCELLED As NVarchar(50)
Declare @AMENDMENT As NVarchar(50)

Set @OPEN = dbo.LookupDictionaryItem(N'Open', Default)
Set @CLOSED = dbo.LookupDictionaryItem(N'Closed', Default)
Set @CANCELLED = dbo.LookupDictionaryItem(N'Cancelled', Default)
Set @AMENDMENT = dbo.LookupDictionaryItem(N'Amendment', Default)

SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'  
SELECT @PO = Prefix FROM VoucherPrefix WHERE TranID = N'PURCHASE ORDER'  
--SELECT @SO = Prefix FROM VoucherPrefix WHERE TranID = 'SALE CONFIRMATION'  
  
  
Select  @disp_Status  = Dispatchabstract.Status 
FROM DispatchAbstract
Inner Join Customer on DispatchAbstract.CustomerID = Customer.CustomerID
Inner Join VoucherPrefix on  VoucherPrefix.TranID = N'DISPATCH'
Left Outer Join ClientInformation on DispatchAbstract.ClientID = ClientInformation.ClientID
WHERE  DispatchDate BETWEEN @FROMDATE AND @TODATE 
--AND DispatchAbstract.CustomerID = Customer.CustomerID AND  
 --VoucherPrefix.TranID = N'DISPATCH' AND   
 --DispatchAbstract.ClientID *= ClientInformation.ClientID  
  
  
  
SELECT  DispatchID, "DispatchID" = VoucherPrefix.Prefix + CAST(DispatchAbstract.DocumentID AS nvarchar),   
 "Reference Number" =  
 CASE Status & 7  
 WHEN 4 THEN   
 @PO  
 Else
 N''  
 END  
 + CAST(NewRefNumber AS nvarchar), "Date" = DispatchDate,  
 "Customer" = Customer.Company_Name,   
 "Invoice Reference" = CASE ISNULL(NewInvoiceID, 0)  
 WHEN 0 THEN N'' ELSE @INV + CAST(NewInvoiceID AS nvarchar) end,   
 "Billing Address" = DispatchAbstract.BillingAddress,  
 "Shipping Address" = DispatchAbstract.ShippingAddress,   
   
 "Status" = case    
 When Isnull(Status, 0) & 192 = 192 Then @CANCELLED  
 When Isnull(Status, 0) & 128 = 128 Then @CLOSED
 When Isnull(Status, 0) & 128 <> 0 and   
 (exists (Select DispatchID from DispatchAbstract where Original_Reference in (Select Original_Reference from dispatchabstract))) Then N'Amended'    
 When Isnull(Status, 0) & 128 = 0 and Isnull(Original_Reference, 0) <> 0  Then @AMENDMENT
 Else @OPEN
 End,  
  
 "Branch" = ClientInformation.Description,  
"Remarks" = Remarks
FROM DispatchAbstract
Inner Join Customer on DispatchAbstract.CustomerID = Customer.CustomerID
Inner Join VoucherPrefix on VoucherPrefix.TranID = N'DISPATCH'
Left Outer Join ClientInformation on DispatchAbstract.ClientID = ClientInformation.ClientID 
WHERE  DispatchDate BETWEEN @FROMDATE AND @TODATE 
	--AND  DispatchAbstract.CustomerID = Customer.CustomerID AND  
 --VoucherPrefix.TranID = N'DISPATCH' AND   
 --DispatchAbstract.ClientID *= ClientInformation.ClientID
