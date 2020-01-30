CREATE procedure [dbo].[sp_get_GRNItems_RecdInvoice](@GRN_ID int) 
as
select Batch_Products.Product_Code as "Code", Items.ProductName as "Name", 
Batch_Products.QuantityReceived as "Qty", 
Case IsNull(Batch_Products.Free, 0) When 1 Then 0 Else IsNull(dbo.sp_get_recd_invoice_batchdetails(GRNAbstract.RecdInvoiceID, 
Batch_Products.Product_Code, 0, 0, 0, 0, Batch_Products.Batch_Number, 
Batch_Products.Expiry, Batch_Products.PKD, 0, 0),Batch_Products.PurchasePrice) End as "Price",
0 as "BatchCode", Batch_Products.Batch_Number as "Batch", 
Batch_Products.Expiry as "Expiry", 
Case Batch_Products.Free When 1 Then 0 Else Items.PTS End as "PTS", 
Case Batch_Products.Free When 1 Then 0 Else Items.PTR End as "PTR",
Case Batch_Products.Free When 1 Then 0 Else Items.ECP End as "ECP", 
-- Case IsNull(Batch_Products.Free, 0) When 1 Then 0 Else IsNull(dbo.sp_get_recd_invoice_batchdetails(GRNAbstract.RecdInvoiceID, 
-- Batch_Products.Product_Code, 0, 0, 0, 0, Batch_Products.Batch_Number, 
-- Batch_Products.Expiry, Batch_Products.PKD, 1, IsNull(Vendors.Locality, 1)), 
-- Case IsNull(Vendors.Locality, 1)
-- When 1 then
-- Tax.Percentage
-- Else
-- ISNULL(Tax.CST_Percentage, 0) 
-- End) End as "Tax Suffered",
Case IsNull(Batch_Products.Free, 0) When 1 Then 0 Else
(Case When (Batch_Products.TaxSuffered is Null) then   
 Case Vendors.Locality When 1 then   
  isnull((Select Percentage From Tax Where Tax_Code = Items.TaxSuffered),0)  
 Else  
  isnull((Select CST_Percentage From Tax Where Tax_Code = Items.TaxSuffered),0)  
 End  
Else  
 Batch_Products.TaxSuffered   
End) End
as "Tax Suffered",      
Batch_Products.PKD as "Packaging Date", Batch_Products.Free as "Free",
Case Batch_Products.Free When 1 Then 0 Else Items.Company_Price End as "Special Price",
IsNull(dbo.sp_get_recd_invoice_batchdetails(GRNAbstract.RecdInvoiceID, 
Batch_Products.Product_Code, 0, Batch_Products.PTS, Batch_Products.PTR, 
Batch_Products.ECP, Batch_Products.Batch_Number, 
Batch_Products.Expiry, Batch_Products.PKD, 2, IsNull(Vendors.Locality, 1)), 
0) as "Item Discount%", dbo.sp_get_recd_invoice_batchdetails(GRNAbstract.RecdInvoiceID, 
Batch_Products.Product_Code, 0, 0, 0, 0, Batch_Products.Batch_Number, 
Batch_Products.Expiry, Batch_Products.PKD, 1, IsNull(Vendors.Locality, 1)) as "TaxPercentage",
------ THIS FIELD IS USED FOR SORTING GRNITEMS IN THE BILL DO NOT USE FOR ANY OTHER PURPOSE-
Batch_Products.Batch_Code,batch_products.grntaxid
--------------------------------------------------------------------------------------------
from Items,ItemCategories, Batch_Products, Vendors, GRNAbstract, Tax
where   GRNAbstract.GRNID = @GRN_ID and 
	GRNAbstract.VendorID = Vendors.VendorID and
	Items.CategoryID = ItemCategories.CategoryID and
	ItemCategories.Price_Option = 0 and
	Batch_Products.Product_Code = Items.Product_Code and
	Batch_Products.GRN_ID = @GRN_ID and
	Items.TaxSuffered *= Tax.Tax_Code and
	Batch_Products.QuantityReceived > 0

UNION ALL

select Batch_Products.Product_Code as "Code", Items.ProductName as "Name",
Batch_Products.QuantityReceived as "Qty", 
Case IsNull(Batch_Products.Free, 0) When 1 Then 0 Else IsNull(dbo.sp_get_recd_invoice_batchdetails(GRNAbstract.RecdInvoiceID, 
Batch_Products.Product_Code, 1, Batch_Products.PTS, Batch_Products.PTR, Batch_Products.ECP, 
Batch_Products.Batch_Number, Batch_Products.Expiry, Batch_Products.PKD, 0, 0),
Batch_Products.PurchasePrice)End as "Price",
Batch_Products.Batch_Code as "BatchCode", Batch_Products.Batch_Number as "Batch", 
Batch_Products.Expiry as "Expiry", 
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.PTS End as "PTS", 
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.PTR End as "PTR",
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.ECP End as "ECP", 
-- Case IsNull(Batch_Products.Free, 0) When 1 Then 0 Else IsNull(dbo.sp_get_recd_invoice_batchdetails(GRNAbstract.RecdInvoiceID, 
-- Batch_Products.Product_Code, 0, Batch_Products.PTS, Batch_Products.PTR, 
-- Batch_Products.ECP, Batch_Products.Batch_Number, 
-- Batch_Products.Expiry, Batch_Products.PKD, 1, IsNull(Vendors.Locality, 1)), 
-- Case IsNull(Vendors.Locality, 1)
-- When 1 then
-- Tax.Percentage 
-- Else 
-- ISNULL(Tax.CST_Percentage, 0)
-- End) End as "Tax Suffered",
Case IsNull(Batch_Products.Free, 0) When 1 Then 0 Else
(Case When (Batch_Products.TaxSuffered is Null) then   
 Case Vendors.Locality When 1 then   
  isnull((Select Percentage From Tax Where Tax_Code = Items.TaxSuffered),0)  
 Else  
  isnull((Select CST_Percentage From Tax Where Tax_Code = Items.TaxSuffered),0)  
 End  
Else  
 Batch_Products.TaxSuffered   
End) End
as "Tax Suffered",      
Batch_Products.PKD as "Packaging Date", Batch_Products.Free as "Free",
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.Company_Price End as "Special Price",
IsNull(dbo.sp_get_recd_invoice_batchdetails(GRNAbstract.RecdInvoiceID, 
Batch_Products.Product_Code, 0, Batch_Products.PTS, Batch_Products.PTR, 
Batch_Products.ECP, Batch_Products.Batch_Number, 
Batch_Products.Expiry, Batch_Products.PKD, 2, IsNull(Vendors.Locality, 1)), 
0) as "Item Discount%", dbo.sp_get_recd_invoice_batchdetails(GRNAbstract.RecdInvoiceID, 
Batch_Products.Product_Code, 0, 0, 0, 0, Batch_Products.Batch_Number, 
Batch_Products.Expiry, Batch_Products.PKD, 1, IsNull(Vendors.Locality, 1)) as "TaxPercentage",
------ THIS FIELD IS USED FOR SORTING GRNITEMS IN THE BILL DO NOT USE FOR ANY OTHER PURPOSE-
Batch_Products.Batch_Code,batch_products.grntaxid
--------------------------------------------------------------------------------------------
from Batch_Products, Items, ItemCategories, Tax, GRNAbstract, Vendors
where 	Batch_Products.GRN_ID = @GRN_ID and
	GRNAbstract.GRNID = @GRN_ID and	
	GRNAbstract.VendorID = Vendors.VendorID and
	Batch_Products.Product_Code = Items.Product_Code and
	Items.CategoryID = ItemCategories.CategoryID and
	ItemCategories.Price_Option = 1 and
	Items.TaxSuffered *= Tax.Tax_Code and
	Batch_Products.QuantityReceived > 0
Order By Batch_Products.Batch_Code
