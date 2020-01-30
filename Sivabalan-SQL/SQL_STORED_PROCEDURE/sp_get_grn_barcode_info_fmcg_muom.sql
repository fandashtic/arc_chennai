CREATE procedure [dbo].[sp_get_grn_barcode_info_fmcg_muom](@GRNID int)    
AS    
Select  "Item Code" = Batch_Products.Product_Code, 
"Sale Price" = dbo.LookupDictionaryItem(N'Rs.', Default) + Cast(Cast((Case Price_Option When 1 Then ISNULL(Batch_Products.SalePrice,0) Else Items.Sale_Price End) * (Sum(QuantityReceived) / Sum(UOMQty)) as decimal(18,2)) as nvarchar),   
"Qty" = Cast(Sum(IsNull(UOMQty, 0)) as Decimal(18,2)), 
"Item Name" = Items.ProductName, "PKD" = Case When Month(Batch_Products.PKD) < 10 Then N'0' Else N'' End + Cast(Month(Batch_Products.PKD) as nvarchar) + N'/' + Cast(Year(Batch_Products.PKD) as nvarchar), 
"Batch" = Batch_Number, 
"Expiry" = Case When Month(Batch_Products.Expiry) < 10 Then N'0' Else N'' End + Cast(Month(Batch_Products.Expiry) as nvarchar) + N'/' + Cast(Year(Batch_Products.Expiry) as nvarchar), 
"MRP" = dbo.LookupDictionaryItem(N'Rs.', Default) + Cast(Cast(Items.MRP as Decimal(18,2)) as nvarchar),   
"Sale Price + Tax" = dbo.LookupDictionaryItem(N'Rs.', Default) + Cast(Cast((Case Price_Option When 1 Then ISNULL(Batch_Products.SalePrice,0) Else Items.Sale_Price End * (Sum(QuantityReceived) / Sum(UOMQty))) * (1 + (IsNull(Tax.Percentage,0) / 100)) as Decimal(18,2)) as nvarchar)  
From  Batch_Products, Items, ItemCategories, Tax  
WHERE  GRN_ID = @GRNID And Batch_Products.Product_code = Items.Product_Code And    
Items.CategoryID = ItemCategories.CategoryID And (IsNull(Items.Flags, 0) & 1) = 0 And  
Items.Sale_Tax *= Tax.Tax_Code    
Group By Batch_Products.Product_Code, Items.ProductName, Batch_Products.UOM,   
Price_Option, Batch_Products.SalePrice, Items.Sale_Price, Batch_Products.PKD, Batch_Number, Batch_Products.Expiry, Tax.Percentage, Items.MRP  
Order By Min(Batch_Code)
