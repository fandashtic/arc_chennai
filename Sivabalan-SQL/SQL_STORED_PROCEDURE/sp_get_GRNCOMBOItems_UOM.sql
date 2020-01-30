CREATE procedure [dbo].[sp_get_GRNCOMBOItems_UOM](@GRN_ID int)   
as  
select Batch_Products.Product_Code as "Code", Items.ProductName as "Name",   
Batch_Products.UOMQty as "Qty",   
Batch_Products.UOMPrice as "Price",  
0 as "BatchCode", Batch_Products.Batch_Number as "Batch",   
Batch_Products.Expiry as "Expiry",   
Case Batch_Products.Free When 1 Then 0 Else Items.PTS End as "PTS",   
Case Batch_Products.Free When 1 Then 0 Else Items.PTR End as "PTR",  
Case Batch_Products.Free When 1 Then 0 Else Items.ECP End as "ECP",   
Case IsNull(Vendors.Locality, 1)  
When 1 then  
Tax.Percentage  
Else  
ISNULL(Tax.CST_Percentage, 0)  
End as "Tax Suffered",  
Batch_Products.PKD as "Packaging Date", Batch_Products.Free as "Free",  
Case Batch_Products.Free When 1 Then 0 Else Items.Company_Price End as "Special Price",  
UOM.Description as "UOM", Batch_Products.UOM as "UOMID",
------ THIS FIELD IS USED FOR SORTING GRNITEMS IN THE BILL DO NOT USE FOR ANY OTHER PURPOSE-  
Batch_Products.Batch_Code,Isnull(Batch_products.ComboId,0)  as "ComboId"  
--------------------------------------------------------------------------------------------  
from Items,ItemCategories, Batch_Products, Vendors, GRNAbstract, Tax, UOM  
where   GRNAbstract.GRNID = @GRN_ID and   
 GRNAbstract.VendorID = Vendors.VendorID and  
 Items.CategoryID = ItemCategories.CategoryID and  
 ItemCategories.Price_Option = 0 and  
 Batch_Products.Product_Code = Items.Product_Code and  
 Batch_Products.GRN_ID = @GRN_ID and  
 Items.TaxSuffered *= Tax.Tax_Code and  
 Batch_Products.UOMQty > 0 and  
 Batch_Products.UOM *= UOM.UOM  
  
UNION ALL  
  
select Batch_Products.Product_Code as "Code", Items.ProductName as "Name",  
Batch_Products.UOMQty as "Qty", Batch_Products.UOMPrice as "Price",  
Batch_Products.Batch_Code as "BatchCode", Batch_Products.Batch_Number as "Batch",   
Batch_Products.Expiry as "Expiry",   
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.PTS End as "PTS",   
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.PTR End as "PTR",  
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.ECP End as "ECP",   
Case IsNull(Vendors.Locality, 1)  
When 1 then  
Tax.Percentage   
Else   
ISNULL(Tax.CST_Percentage, 0)  
End as "Tax Suffered",  
Batch_Products.PKD as "Packaging Date", Batch_Products.Free as "Free",  
Case Batch_Products.Free When 1 Then 0 Else Batch_Products.Company_Price End as "Special Price",  
UOM.Description as "UOM", Batch_Products.UOM as "UOMID",
------ THIS FIELD IS USED FOR SORTING GRNITEMS IN THE BILL DO NOT USE FOR ANY OTHER PURPOSE-  
Batch_Products.Batch_Code,Isnull(Batch_Products.ComboId,0) as "ComboId"  
--------------------------------------------------------------------------------------------  
from Batch_Products, Items, ItemCategories, Tax, GRNAbstract, Vendors, UOM  
where  Batch_Products.GRN_ID = @GRN_ID and  
 GRNAbstract.GRNID = @GRN_ID and   
 GRNAbstract.VendorID = Vendors.VendorID and  
 Batch_Products.Product_Code = Items.Product_Code and  
 Items.CategoryID = ItemCategories.CategoryID and  
 ItemCategories.Price_Option = 1 and  
 Items.TaxSuffered *= Tax.Tax_Code and  
 Batch_Products.UOMQty > 0 and  
 Batch_Products.UOM *= UOM.UOM  
Order By Batch_Products.Batch_Code
