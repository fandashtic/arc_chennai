

CREATE procedure dbo.spr_list_Damaged_Stock(@ITEMCODE nvarchar(15))  
as  
Select Batch_Products.Product_Code, "Item Code" = Batch_Products.Product_Code,   
"Item Name" = Items.ProductName, "Batch" = Batch_Products.Batch_Number,  
"PKD" = Batch_Products.PKD, "Expiry" = Batch_Products.Expiry,   
"Quantity" = Sum(Batch_Products.Quantity),  
"Purchase Price" = Batch_Products.PurchasePrice, "PTS" = Batch_Products.PTS,   
"PTR" = Batch_Products.PTR, "ECP" = Batch_Products.ECP,"MRPPerPack" = isnull(Batch_Products.MRPPerPack,0)  
From Batch_Products, Items  
Where Batch_Products.Product_Code = Items.Product_Code And  
Batch_Products.Damage in (1, 2)  And Batch_Products.Product_Code = @ITEMCODE And  
Quantity > 0  
Group By Batch_Products.Product_Code, Items.ProductName, Batch_Products.Batch_Number,  
Batch_Products.PKD, Batch_Products.Expiry, Batch_Products.PurchasePrice,  
Batch_Products.PTS, Batch_Products.PTR, Batch_Products.ECP ,Batch_Products.MRPPerPack   
