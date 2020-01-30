CREATE procedure sp_print_PurchaseReturnMUOM (@AdjustmentID int)  
as  
Select "Document No" = VoucherPrefix.Prefix + cast(DocumentID as varchar),   
"Date" = AdjustmentDate,  
"VendorID" = AdjustmentReturnAbstract.VendorID,   
"Vendor" = Vendors.Vendor_Name,   
"Address" = Vendors.Address,  
"Value" = Value,   
"Total Tax" = sum(AdjustmentReturnDetail.tax),  
"Nett Value" = sum((AdjustmentReturnDetail.quantity * AdjustmentReturnDetail.rate)+(AdjustmentReturnDetail.tax))  
From AdjustmentReturnAbstract, Vendors, VoucherPrefix, AdjustmentReturnDetail  
Where AdjustmentReturnAbstract.AdjustmentID = @AdjustmentID AND  
AdjustmentReturnDetail.AdjustmentID = @AdjustmentID AND  
AdjustmentReturnAbstract.VendorID = Vendors.VendorID AND  
VoucherPrefix.TranID = 'STOCK ADJUSTMENT PURCHASE RETURN'  
group by   
VoucherPrefix.Prefix, AdjustmentReturnAbstract.DocumentID,  
AdjustmentDate,AdjustmentReturnAbstract.VendorID, Vendors.Vendor_Name, Vendors.Address,  
Value  


