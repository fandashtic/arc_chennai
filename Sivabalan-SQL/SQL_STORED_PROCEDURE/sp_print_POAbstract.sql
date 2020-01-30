CREATE procedure [dbo].[sp_print_POAbstract](@PONo INT)    
AS    
Declare @ItemCount int  
SELECT @ItemCount = Count(*)
FROM PODetail, Items, UOM, ItemCategories  
WHERE PODetail.PONumber = @PONo   
AND PODetail.Product_Code = Items.Product_Code  
AND Items.UOM *= UOM.UOM  
And Items.CategoryID = ItemCategories.CategoryID  
  
SELECT "PO Date" = PODate, "Required Date" = RequiredDate,     
"Vendor" = Vendors.Vendor_Name, "Value" = POAbstract.Value,    
"Billing Address" = POAbstract.BillingAddress, "Shipping Address" = POAbstract.ShippingAddress,     
"Credit Term" = CreditTerm.Description, "GRN" = GRN.Prefix + CAST(GRNID AS NVARCHAR),     
"PO Reference" = PO.Prefix + CAST(POReference AS NVARCHAR),     
"PO Number" = PO.Prefix + CAST(DocumentID AS NVARCHAR), Remarks,
"Document Reference" = DocRef,  
"Total Quantity" = (Select Sum(PODetail.Quantity) from PODetail Where PONumber = @PoNo),  
"TIN Number" = TIN_Number,  
"Vendor Address" = Vendors.Address,   
"Vendor City" = (select CityName from City where CityID = Vendors.CityID),  
"Vendor State" = (select State from State where StateID = Vendors.StateID),  
"Vendor Country" = (select Country from Country where CountryID = Vendors.CountryID),  
"Vendor PIN Code" = Vendors.Zip,  
"Vendor Fax" = Vendors.Fax,  
"ITEM COUNT" = @ItemCount,    
"Document Ref" = POAbstract.DocRef
FROM POAbstract, Vendors, CreditTerm, VoucherPrefix GRN, VoucherPrefix PO   
WHERE POAbstract.PONumber = @PoNo  
AND POAbstract.VendorID = Vendors.VendorID    
AND POAbstract.CreditTerm *= CreditTerm.CreditID    
AND PO.TranID = 'PURCHASE ORDER'    
AND GRN.TranID = 'GOODS RECEIVED NOTE'
