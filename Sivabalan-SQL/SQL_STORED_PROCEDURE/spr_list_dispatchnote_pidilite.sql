CREATE procedure [dbo].[spr_list_dispatchnote_pidilite](@FROMDATE datetime,  
           @TODATE datetime)  
AS  
  
DECLARE @INV AS nvarchar(50)  
DECLARE @SO AS nvarchar(50)  
DECLARE @PO AS nvarchar(50)  
declare @Status as nvarchar(255)  
declare @disp_Status as int  
  
SELECT @INV = Prefix FROM VoucherPrefix WHERE TranID = N'INVOICE'  
SELECT @PO = Prefix FROM VoucherPrefix WHERE TranID = N'PURCHASE ORDER'  
--SELECT @SO = Prefix FROM VoucherPrefix WHERE TranID = 'SALE CONFIRMATION'  
  
  
Select  @disp_Status  = Dispatchabstract.Status FROM DispatchAbstract, Customer, VoucherPrefix, ClientInformation  
WHERE  DispatchDate BETWEEN @FROMDATE AND @TODATE AND   
 DispatchAbstract.CustomerID = Customer.CustomerID AND  
 VoucherPrefix.TranID = N'DISPATCH' AND   
 DispatchAbstract.ClientID *= ClientInformation.ClientID  
  
  
  
SELECT  DispatchID, "DispatchID" = VoucherPrefix.Prefix + CAST(DispatchAbstract.DocumentID AS nvarchar),   
 "Reference Number" =  
 CASE Status & 7  
 WHEN 4 THEN   
 @PO  
 Else
 N''  
 END  
 + CAST(NewRefNumber AS nvarchar), 
 "Doc Reference" = DocRef,
 "Date" = DispatchDate,  
 "Customer" = Customer.Company_Name,   
 "Invoice Reference" = CASE ISNULL(NewInvoiceID, 0)  
 WHEN 0 THEN N'' ELSE @INV + CAST(NewInvoiceID AS nvarchar) end,   
 "Billing Address" = DispatchAbstract.BillingAddress,  
 "Shipping Address" = DispatchAbstract.ShippingAddress,   
   
 "Status" = case    
 When Isnull(Status, 0) & 192 = 192 Then N'Cancelled'  
 When Isnull(Status, 0) & 128 = 128 Then N'Closed'  
 When Isnull(Status, 0) & 128 <> 0 and   
 (exists (Select DispatchID from DispatchAbstract where Original_Reference in (Select Original_Reference from dispatchabstract))) Then N'Amended'    
 When Isnull(Status, 0) & 128 = 0 and Isnull(Original_Reference, 0) <> 0  Then N'Amendment'  
 Else N'Open'   
 End,  
  
 "Branch" = ClientInformation.Description,  
"Remarks" = Remarks
FROM DispatchAbstract, Customer, VoucherPrefix, ClientInformation  
WHERE  DispatchDate BETWEEN @FROMDATE AND @TODATE AND   
 DispatchAbstract.CustomerID = Customer.CustomerID AND  
 VoucherPrefix.TranID = N'DISPATCH' AND   
 DispatchAbstract.ClientID *= ClientInformation.ClientID
