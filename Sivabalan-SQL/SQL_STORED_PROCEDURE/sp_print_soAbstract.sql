CREATE Procedure sp_print_soAbstract(@SONumber int)  
AS  
SELECT "SO Date" = SODate, "Delivery Date" = DeliveryDate,   
"Customer" = Customer.Company_Name, "Value" = SOAbstract.Value,  
"Billing Address" = SOAbstract.BillingAddress,   
"Shipping Address" = SOAbstract.ShippingAddress,   
"Credit Term" = CreditTerm.Description,   
"POReference" = PO.Prefix + CAST(POReference AS nvarchar),   
"SCReference" = SO.Prefix + CAST(DocumentID AS nvarchar),  
"Reference" = PODocReference,  
"Invoice Gross Value" = (SELECT Sum(IsNull(dbo.GetInvoiceGrossValueFromSC(@SONumber, SODetail.Product_Code),0)) FROM SoDetail WHERE SONumber = @SONumber),  
"Gross Value" = Sum(Quantity * SalePrice),  
"TIN Number" = TIN_Number,
"Total Tax Suffered Amount" = Case SOAbstract.TaxOnMRP
When 1 Then
Sum(SODetail.Quantity * SODetail.ECP * SODetail.TaxSuffered/100)
Else
Sum((((SODetail.Quantity * SODetail.SalePrice) - 
(SODetail.Quantity * SODetail.SalePrice * SODetail.Discount / 100)) 
* SODetail.TaxSuffered / 100))End,  
"Total Tax Applicable Amount" = Case SOAbstract.TaxOnMRP
When 1 Then
Sum(((SODetail.Quantity * SODetail.ECP) + 
(SODetail.Quantity * SODetail.ECP * SODetail.TaxSuffered/100)) *
(IsNull(SODetail.SaleTax, 0) + IsNull(SODetail.TaxCode2, 0)) / 100)
Else
 Sum(((((SODetail.Quantity * SODetail.SalePrice) - (SODetail.Quantity * SODetail.SalePrice * SODetail.Discount / 100))   
+ (((SODetail.Quantity * SODetail.SalePrice) - (SODetail.Quantity * SODetail.SalePrice * SODetail.Discount / 100)) * SODetail.TaxSuffered / 100))   
* (IsNull(SODetail.SaleTax, 0) + IsNull(SODetail.TaxCode2, 0)) / 100)) End,  

"Total Discount Amount" = Sum(((SODetail.Quantity * SODetail.SalePrice)* SODetail.Discount / 100)),  

"Total Tax Amount" = Case SOAbstract.TaxOnMRP
When 1 Then
Sum((SODetail.Quantity * SODetail.ECP * SODetail.TaxSuffered/100) + ((SODetail.Quantity * SODetail.ECP) + 
(SODetail.Quantity * SODetail.ECP * SODetail.TaxSuffered/100)) *
(IsNull(SODetail.SaleTax, 0) + IsNull(SODetail.TaxCode2, 0)) / 100)
Else
Round(Sum((((SODetail.Quantity * SODetail.SalePrice) - (SODetail.Quantity * SODetail.SalePrice * SODetail.Discount / 100)) * SODetail.TaxSuffered / 100) +  
((((SODetail.Quantity * SODetail.SalePrice) - (SODetail.Quantity * SODetail.SalePrice * SODetail.Discount / 100))   
+ (((SODetail.Quantity * SODetail.SalePrice) - (SODetail.Quantity * SODetail.SalePrice * SODetail.Discount / 100)) * SODetail.TaxSuffered / 100))   
* (IsNull(SODetail.SaleTax, 0) + IsNull(SODetail.TaxCode2, 0)) / 100)),2) End,  
"Total Item" = Count(distinct Sodetail.Product_code),
"Document Number" = SoAbstract.DocumentReference, "Doc Type" = DocSerialType, "Alternate Name" = Alternate_Name,
"Customer Sequence No." = Customer.SequenceNo
FROM SOAbstract, SoDetail, Customer, CreditTerm, VoucherPrefix SO, VoucherPrefix PO   
WHERE SOAbstract.SONumber = @SONumber AND SOAbstract.CustomerID = Customer.CustomerID  
And SODetail.SoNumber = SOAbstract.SONumber  
AND SOAbstract.CreditTerm = CreditTerm.CreditID  
AND SO.TranID = 'SALE CONFIRMATION'  
AND PO.TranID = 'PURCHASE ORDER'  
GROUP BY SODate, DeliveryDate, Customer.Company_Name, SOAbstract.Value,  
SOAbstract.BillingAddress, SOAbstract.ShippingAddress, CreditTerm.Description, POReference,  
PO.Prefix, SO.Prefix, DocumentID, PODocReference, TaxOnMRP,DocumentReference, 
TIN_Number, DocSerialType, Alternate_Name, Customer.SequenceNo


