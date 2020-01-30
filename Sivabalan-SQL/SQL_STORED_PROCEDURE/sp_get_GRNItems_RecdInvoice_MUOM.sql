Create procedure sp_get_GRNItems_RecdInvoice_MUOM(@GRN_ID int)   
as  
select Batch_Products.Product_Code as "Code", Items.ProductName as "Name",   
Batch_Products.UOMQty as "Qty",   
Case IsNull(Batch_Products.Free, 0) When 1 Then 0 Else IsNull(dbo.sp_get_recd_invoice_batchdetails_MUOM(GRNAbstract.RecdInvoiceID,
Batch_Products.Product_Code, 0, 0, 0, 0, Batch_Products.Batch_Number,   
Batch_Products.Expiry, Batch_Products.PKD, 0, 0, Batch_Products.UOM),Batch_Products.UOMPrice) End as "Price",  
0 as "BatchCode", Batch_Products.Batch_Number as "Batch",   
Batch_Products.Expiry as "Expiry",   
Case Batch_Products.Free When 1 Then 0 Else Items.PTS End as "PTS",   
Case Batch_Products.Free When 1 Then 0 Else Items.PTR End as "PTR",  
Case Batch_Products.Free When 1 Then 0 Else Items.ECP End as "ECP",   
Case IsNull(Batch_Products.Free, 0) When 1 Then 0 Else IsNull(dbo.sp_get_recd_invoice_batchdetails_MUOM(GRNAbstract.RecdInvoiceID,   
Batch_Products.Product_Code, 0, 0, 0, 0, Batch_Products.Batch_Number,   
Batch_Products.Expiry, Batch_Products.PKD, 1, IsNull(Vendors.Locality, 1), Batch_Products.UOM ),   
Case IsNull(Vendors.Locality, 1)  
When 1 then  
Tax.Percentage  
Else  
ISNULL(Tax.CST_Percentage, 0)   
End) End as "Tax Suffered",  
Batch_Products.PKD as "Packaging Date", Batch_Products.Free as "Free",  
Case Batch_Products.Free When 1 Then 0 Else Items.Company_Price End as "Special Price",  
-- IsNull(dbo.sp_get_recd_invoice_batchdetails_MUOM(GRNAbstract.RecdInvoiceID,   
-- Batch_Products.Product_Code, 0, Batch_Products.PTS, Batch_Products.PTR,   
-- Batch_Products.ECP, Batch_Products.Batch_Number,   
-- Batch_Products.Expiry, Batch_Products.PKD, 2, IsNull(Vendors.Locality, 1), Batch_Products.UOM),   
-- 0) as "Item Discount%", 
(Case When
IsNull(dbo.sp_get_recd_invoice_batchdetails_MUOM(GRNAbstract.RecdInvoiceID,     
Batch_Products.Product_Code, 0, Batch_Products.PTS, Batch_Products.PTR,     
Batch_Products.ECP, Batch_Products.Batch_Number,     
Batch_Products.Expiry, Batch_Products.PKD, 2, IsNull(Vendors.Locality, 1), Batch_Products.UOM), 0) = 0 
Then 
(Case when isNull(Free,0)=1 then 0
Else
(Select  Max(IsNull(DiscountPercentage,0)) From InvoiceDetailReceived Where Product_Code = Batch_Products.Product_Code And 
InvoiceId = GRNAbstract.RecdInvoiceid)
end
)
-- (Select IsNull(DiscountValue,0) From InvoiceDetailReceived Where Product_Code = Batch_Products.Product_Code And 
-- InvoiceId = GRNAbstract.RecdInvoiceid)
Else 
IsNull(dbo.sp_get_recd_invoice_batchdetails_MUOM(GRNAbstract.RecdInvoiceID,     
Batch_Products.Product_Code, 0, Batch_Products.PTS, Batch_Products.PTR,     
Batch_Products.ECP, Batch_Products.Batch_Number,     
Batch_Products.Expiry, Batch_Products.PKD, 2, IsNull(Vendors.Locality, 1), Batch_Products.UOM),     
0)End) As "Item Discount%",   

dbo.sp_get_recd_invoice_batchdetails_MUOM(GRNAbstract.RecdInvoiceID,   
Batch_Products.Product_Code, 0, 0, 0, 0, Batch_Products.Batch_Number,   
Batch_Products.Expiry, Batch_Products.PKD, 1, IsNull(Vendors.Locality, 1), Batch_Products.UOM) as "TaxPercentage",  
UOM.Description as "UOM", Batch_Products.UOM as "UOMID",
------ THIS FIELD IS USED FOR SORTING GRNITEMS IN THE BILL DO NOT USE FOR ANY OTHER PURPOSE-
Batch_Products.Batch_Code,batch_products.grntaxid
--------------------------------------------------------------------------------------------
from Items
 inner join ItemCategories on  Items.CategoryID = ItemCategories.CategoryID    
 inner join Batch_Products on  Batch_Products.Product_Code = Items.Product_Code    
 inner join  GRNAbstract on GRNAbstract.GRNID = @GRN_ID  
 inner join Vendors on  GRNAbstract.VendorID = Vendors.VendorID   
left outer join Tax on  Items.TaxSuffered = Tax.Tax_Code    
left outer join UOM on  Batch_Products.UOM = UOM.UOM

where      
 ItemCategories.Price_Option = 0 and  
 Batch_Products.GRN_ID = @GRN_ID and  
 Batch_Products.QuantityReceived > 0 and  
 Batch_Products.UOMQty > 0   
UNION ALL  
  
select Batch_Products.Product_Code as "Code", 
	Items.ProductName as "Name",  
	Batch_Products.UOMQty as "Qty",   
Case IsNull(Batch_Products.Free, 0) When 1 Then 0 Else IsNull(dbo.sp_get_recd_invoice_batchdetails_MUOM(GRNAbstract.RecdInvoiceID,   
Batch_Products.Product_Code, 1, Batch_Products.PTS, Batch_Products.PTR, Batch_Products.ECP,   
Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD, 0, 0, Batch_Products.UOM),  
Batch_Products.UOMPrice)End as "Price",  
Batch_Products.Batch_Code as "BatchCode", Batch_Products.Batch_Number as "Batch",   
Batch_Products.Expiry as "Expiry",   
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.PTS End as "PTS",   
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.PTR End as "PTR",  
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.ECP End as "ECP",   
Case IsNull(Batch_Products.Free, 0) When 1 Then 0 Else IsNull(dbo.sp_get_recd_invoice_batchdetails_MUOM(GRNAbstract.RecdInvoiceID,   
Batch_Products.Product_Code, 0, Batch_Products.PTS, Batch_Products.PTR,   
Batch_Products.ECP, Batch_Products.Batch_Number,   
Batch_Products.Expiry, Batch_Products.PKD, 1, IsNull(Vendors.Locality, 1), Batch_Products.UOM),   
Case IsNull(Vendors.Locality, 1)  
When 1 then  
Tax.Percentage   
Else   
ISNULL(Tax.CST_Percentage, 0)  
End) End as "Tax Suffered",  
Batch_Products.PKD as "Packaging Date", Batch_Products.Free as "Free",  
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.Company_Price End as "Special Price",  
-- IsNull(dbo.sp_get_recd_invoice_batchdetails_MUOM(GRNAbstract.RecdInvoiceID,   
-- Batch_Products.Product_Code, 0, Batch_Products.PTS, Batch_Products.PTR,   
-- Batch_Products.ECP, Batch_Products.Batch_Number,   
-- Batch_Products.Expiry, Batch_Products.PKD, 2, IsNull(Vendors.Locality, 1), Batch_Products.UOM), 
-- 0) as "Item Discount%", 
(Case When
IsNull(dbo.sp_get_recd_invoice_batchdetails_MUOM(GRNAbstract.RecdInvoiceID,     
Batch_Products.Product_Code, 0, Batch_Products.PTS, Batch_Products.PTR,     
Batch_Products.ECP, Batch_Products.Batch_Number,     
Batch_Products.Expiry, Batch_Products.PKD, 2, IsNull(Vendors.Locality, 1), Batch_Products.UOM), 0) = 0 
Then 
(
Case when IsNull(Free,0)=1 then 0

Else
(Select  max(IsNull(DiscountPercentage,0)) From InvoiceDetailReceived Where Product_Code = Batch_Products.Product_Code And 
InvoiceId = GRNAbstract.RecdInvoiceid)

end
)
Else 
IsNull(dbo.sp_get_recd_invoice_batchdetails_MUOM(GRNAbstract.RecdInvoiceID,     
Batch_Products.Product_Code, 0, Batch_Products.PTS, Batch_Products.PTR,     
Batch_Products.ECP, Batch_Products.Batch_Number,     
Batch_Products.Expiry, Batch_Products.PKD, 2, IsNull(Vendors.Locality, 1), Batch_Products.UOM),     
0)End) As "Item Discount%",   
dbo.sp_get_recd_invoice_batchdetails_MUOM(GRNAbstract.RecdInvoiceID,   
Batch_Products.Product_Code, 0, 0, 0, 0, Batch_Products.Batch_Number,   
Batch_Products.Expiry, Batch_Products.PKD, 1, IsNull(Vendors.Locality, 1), Batch_Products.UOM) as "TaxPercentage",  
UOM.Description as "UOM", Batch_Products.UOM as "UOMID",
------ THIS FIELD IS USED FOR SORTING GRNITEMS IN THE BILL DO NOT USE FOR ANY OTHER PURPOSE-
Batch_Products.Batch_Code,batch_products.grntaxid
--------------------------------------------------------------------------------------------
from Batch_Products
inner join Items on  Batch_Products.Product_Code = Items.Product_Code    
inner join ItemCategories on  Items.CategoryID = ItemCategories.CategoryID     
left outer join Tax on  Items.TaxSuffered = Tax.Tax_Code    
inner join GRNAbstract on  GRNAbstract.GRNID = @GRN_ID     
inner join  Vendors  on  GRNAbstract.VendorID = Vendors.VendorID   
left outer join  UOM  on  Batch_Products.UOM = UOM.UOM
--, 
--InvoiceDetailReceived IDR
where  Batch_Products.GRN_ID = @GRN_ID and  
-- IDR.Product_Code = Batch_Products.Product_Code And 
-- IDR.InvoiceId = GRNAbstract.RecdInvoiceid and
 Batch_Products.Product_Code In (Select Product_Code From InvoiceDetailReceived) And
 GRNAbstract.RecdInvoiceid In (Select InvoiceId From InvoiceDetailReceived) And
 ItemCategories.Price_Option = 1 and  
 Batch_Products.QuantityReceived > 0  and  
 Batch_Products.UOMQty > 0   


Order By Batch_Products.Batch_Code

