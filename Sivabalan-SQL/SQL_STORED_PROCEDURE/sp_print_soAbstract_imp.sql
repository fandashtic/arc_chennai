CREATE Procedure sp_print_soAbstract_imp(@SONumber int)        
AS      
Declare @TmpItemcount Table (Product_code nvarchar(255))
Insert into @TmpItemcount(Product_code)
select Product_code from SODetail SD Where SD.SONumber=@SONumber Group by SD.Serial,Product_code  
SELECT "SO Date" = SODate, "Delivery Date" = DeliveryDate,     
"Customer ID" = SOAbstract.CustomerID,        
"Customer" = Customer.Company_Name,    
"SaleMan" = SalesMan.Salesman_Name,    
"BeatName" = Beat.Description,    
 "Value" = SOAbstract.Value,        
"Billing Address" = SOAbstract.BillingAddress,         
"Shipping Address" = SOAbstract.ShippingAddress,         
"Credit Term" = CreditTerm.Description,         
"POReference" = PO.Prefix + CAST(POReference AS nvarchar),         
"SCReference" = SO.Prefix + CAST(DocumentID AS nvarchar),        
"Reference" = PODocReference,        
"Invoice Gross Value" = (SELECT Sum(IsNull(dbo.GetInvoiceGrossValueFromSC(@SONumber, SODetail.Product_Code),0)) FROM SoDetail WHERE SONumber = @SONumber),        
"Gross Value" = Sum(Quantity * SalePrice),   
"VATTaxAmount" = SoAbstract.VATTaxAmount,       
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
"Item Count" = (Select Count(Product_code) from @TmpItemcount),      
"Document Number" = SoAbstract.DocumentReference, "Doc Type" = DocSerialType, "Alternate Name" = Alternate_Name,      
"Customer Sequence No." = Customer.SequenceNo      
FROM SOAbstract, SoDetail, Customer, CreditTerm, VoucherPrefix SO, VoucherPrefix PO,SalesMan,Beat         
WHERE SOAbstract.SONumber = @SONumber AND SOAbstract.CustomerID = Customer.CustomerID     
And SOAbstract.SalesManid = SalesMan.SalesmanID    
And SOAbstract.BeatID = Beat.BeatID    
And SODetail.SoNumber = SOAbstract.SONumber        
AND SOAbstract.CreditTerm = CreditTerm.CreditID        
AND SO.TranID = 'SALE CONFIRMATION'        
AND PO.TranID = 'PURCHASE ORDER'        
GROUP BY SODate, DeliveryDate,SOAbstract.CustomerID, Customer.Company_Name, SalesMan.Salesman_Name,Beat.Description,    
SOAbstract.Value,SOAbstract.BillingAddress, SOAbstract.ShippingAddress, CreditTerm.Description, POReference,        
PO.Prefix, SO.Prefix, DocumentID, PODocReference, TaxOnMRP,DocumentReference,       
TIN_Number,SoAbstract.VATTaxAmount, DocSerialType, Alternate_Name, Customer.SequenceNo    

SET QUOTED_IDENTIFIER OFF 
