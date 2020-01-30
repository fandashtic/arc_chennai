CREATE procedure [dbo].[sp_get_grn_barcode_info_muom](@GRNID int)        
AS        
Select  "Item Code" = Batch_Products.Product_Code, 
"ECP" = dbo.LookupDictionaryItem(N'Rs.', Default) + Cast(Cast((Case Price_Option When 1 Then ISNULL(Batch_Products.ECP,0) Else Items.ECP End) * (Sum(QuantityReceived) / Sum(UOMQty)) as decimal(18,2)) As nvarchar),     
"Qty" = Cast(Sum(IsNull(UOMQty, 0)) as Decimal(18,2)), "Item Name" = Items.ProductName, 
"PKD" = Case When Month(Batch_Products.PKD) < 10 Then N'0' Else N'' End + Cast(Month(Batch_Products.PKD) as nvarchar) + N'/' + Cast(Year(Batch_Products.PKD) as nvarchar),  
"Batch" = Batch_Number, "Expiry" = Case When Month(Batch_Products.Expiry) < 10 Then N'0' Else N'' End + Cast(Month(Batch_Products.Expiry) as nvarchar) + N'/' + Cast(Year(Batch_Products.Expiry) as nvarchar),   
"MRP" = dbo.LookupDictionaryItem(N'Rs.', Default) + Cast(Cast(Items.MRP as Decimal(18,2)) as nvarchar),    
"PTS" = dbo.LookupDictionaryItem(N'Rs.', Default) + Cast(Cast(Case Price_Option When 1 Then ISNULL(Batch_Products.PTS,0) Else Items.PTS End * (Sum(QuantityReceived) / Sum(UOMQty)) as Decimal(18,2)) As nvarchar),       
"PTR" = dbo.LookupDictionaryItem(N'Rs.', Default) + Cast(Cast(Case Price_Option When 1 Then ISNULL(Batch_Products.PTR,0) Else Items.PTR End * (Sum(QuantityReceived) / Sum(UOMQty)) as Decimal(18,2)) As nvarchar),       
"Spl Price" = dbo.LookupDictionaryItem(N'Rs.', Default) + Cast(Cast(Case Price_Option When 1 Then ISNULL(Batch_Products.Company_Price,0) Else Items.Company_Price End * (Sum(QuantityReceived) / Sum(UOMQty)) as Decimal(18,2)) As nvarchar),      
"ECP + Tax" = dbo.LookupDictionaryItem(N'Rs.', Default) + Cast(Cast((Case Price_Option When 1 Then ISNULL(Batch_Products.ECP,0) Else Items.ECP End * (Sum(QuantityReceived) / Sum(UOMQty))) * (1 + (IsNull(Tax.Percentage,0) / 100)) as Decimal(18,2)) as nvarchar)      
From  Batch_Products, Items, ItemCategories, Tax    
WHERE  GRN_ID = @GRNID And Batch_Products.Product_code = Items.Product_Code And        
 Items.CategoryID = ItemCategories.CategoryID And (IsNull(Items.Flags, 0) & 1) = 0 And    
 Items.Sale_Tax *= Tax.Tax_Code      
Group By Batch_Products.Product_Code, Items.ProductName, Batch_Products.UOM,     
-- N'Rs.' + Cast(Case Price_Option When 1 Then ISNULL(Batch_Products.ECP,0) Else Items.ECP End As nvarchar), Batch_Products.PKD, Batch_Number, convert(nvarchar, Batch_Products.Expiry, 103)        
 Price_Option, Batch_Products.ECP, Items.ECP, Batch_Products.PKD, Batch_Number, Batch_Products.Expiry, Items.MRP,     
Batch_Products.PTS, Items.PTS, Batch_Products.PTR, Items.PTR, Batch_Products.Company_Price, Items.Company_Price,     
Batch_Products.ECP, Items.ECP, Tax.Percentage    
Order By Min(Batch_Code)
