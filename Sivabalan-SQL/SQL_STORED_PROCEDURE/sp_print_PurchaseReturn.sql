CREATE procedure sp_print_PurchaseReturn (@AdjustmentID int)  
as  
Select "Document No" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),   
"Date" = AdjustmentDate,  
"VendorID" = AdjustmentReturnAbstract.VendorID,   
"Vendor" = Vendors.Vendor_Name,   
"Address" = Vendors.Address,  
"Value" = Value,   
"Total Tax" = sum(AdjustmentReturnDetail.Total_Value - AdjustmentReturnDetail.quantity * AdjustmentReturnDetail.rate) ,  
"Nett Value" = sum(AdjustmentReturnDetail.Total_Value),
"Doc ID" = AdjustmentReturnAbstract.Reference,
"TIN Number" = TIN_Number,
"Doc Type" = DocSerialType
From AdjustmentReturnAbstract, Vendors, VoucherPrefix, AdjustmentReturnDetail  
Where AdjustmentReturnAbstract.AdjustmentID = @AdjustmentID AND  
AdjustmentReturnDetail.AdjustmentID = @AdjustmentID AND  
AdjustmentReturnAbstract.VendorID = Vendors.VendorID AND  
VoucherPrefix.TranID = 'STOCK ADJUSTMENT PURCHASE RETURN'  
group by   
VoucherPrefix.Prefix + cast(AdjustmentReturnAbstract.DocumentID as nvarchar),  
AdjustmentDate,AdjustmentReturnAbstract.VendorID, Vendors.Vendor_Name, Vendors.Address,  
Value,AdjustmentReturnAbstract.Reference, TIN_Number, DocSerialType



