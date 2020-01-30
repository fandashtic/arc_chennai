CREATE PROCEDURE spr_list_open_dispatchnote_pidilite   
    
AS    
    
DECLARE @PO AS nvarchar(50)    
DECLARE @SO AS nvarchar(50)    
    
SELECT @PO = Prefix FROM VoucherPrefix WHERE TranID = 'PURCHASE ORDER'    
SELECT @SO = Prefix FROM VoucherPrefix WHERE TranID = 'SALE ORDER'    
    
SELECT  DispatchID, "DispatchID" = VoucherPrefix.Prefix + CAST(DocumentID AS nvarchar),     
 "Date" = DispatchDate, "Customer" = Customer.Company_Name,     
 "Doc Reference" = DocRef,  
 "Reference Number" = NewRefNumber,    
 "Billing Address" = DispatchAbstract.BillingAddress,    
 "Shipping Address" = DispatchAbstract.ShippingAddress    
FROM DispatchAbstract, Customer, VoucherPrefix    
WHERE DispatchAbstract.CustomerID = Customer.CustomerID AND     
 (Status & 128) = 0 AND    
--commented to include Dispatch Amendment  
-- Isnull(Original_Reference, 0) = 0 and   
 VoucherPrefix.TranID = 'DISPATCH'   
    
  
  
  

