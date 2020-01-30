CREATE procedure [dbo].[sp_view_RetailAbstract](@INVOICEID INT)    
AS    
SELECT InvoiceDate, Cash_Customer.Address, Cash_Customer.DOB,    
InvoiceAbstract.CustomerID, Cash_Customer.CustomerName,     
InvoiceAbstract.GrossValue, InvoiceAbstract.DiscountPercentage,     
InvoiceAbstract.DiscountValue, InvoiceAbstract.NetValue, DocumentID,    
InvoiceAbstract.Status, InvoiceAbstract.InvoiceReference, InvoiceAbstract.ShippingAddress,    
InvoiceAbstract.NewInvoiceReference, Doctor.Name, PaymentMode, PaymentDetails,    
IsNull(MembershipCode,N''), IsNull(Telephone,N''), 
IsNull((Select CustomerCategory.CategoryName From CustomerCategory    
Where CustomerCategory.CategoryID = Cash_Customer.CategoryID), N''),    
InvoiceAbstract.SalesmanID, salesman.Salesman_name, InvoiceAbstract.RoundOffAmount,ServiceCharge as Service,
isNull(InvoiceAbstract.TaxOnMrp,0) as TaxOnMrp,
InvoiceAbstract.DocReference,InvoiceAbstract.DocSerialType,
SchemeID, SchemeDiscountPercentage, SchemeDiscountAmount, Status    
FROM InvoiceAbstract, Cash_Customer, Doctor, salesman
WHERE InvoiceAbstract.InvoiceID = @INVOICEID    
AND InvoiceAbstract.CustomerID *= CAST(Cash_Customer.CustomerID AS nvarchar)    
AND InvoiceAbstract.ReferredBy *= Doctor.ID    
AND InvoiceAbstract.SalesmanID *= salesman.salesmanid
