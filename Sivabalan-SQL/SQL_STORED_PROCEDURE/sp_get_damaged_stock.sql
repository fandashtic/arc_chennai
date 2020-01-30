CREATE PROCEDURE sp_get_damaged_stock(@MANUFACTURERID int)    
AS    
Select tmp.Product_Code, tmp.ProductName, tmp.Batch_Number, tmp.Expiry, tmp.Price, Sum(tmp.Quantity),
tmp.TaxSuffered, Sum(TotalValue), tmp.[Message], tmp.Damage From(
select Batch_Products.Product_Code, Items.ProductName,   
 ISNULL(Batch_Number, N'') as 'Batch_Number', Expiry,   
 ISNULL(Batch_Products.PurchasePrice, 0) as 'Price',   
 Sum(Quantity - ISNULL(ClaimedAlready, 0)) as 'Quantity',   
 Max(IsNull(Batch_products.taxSuffered,0)) as 'TaxSuffered',  
 Sum(ISNULL(Batch_Products.PurchasePrice * (Quantity - ISNULL(ClaimedAlready, 0)), 0)) as 'TotalValue',     
 dbo.mERP_fn_Get_RFADamageDesc(Batch_Products.Product_Code,Batch_Number,Batch_Products.PurchasePrice,Expiry,Damage,Max(Batch_products.taxSuffered)) as [Message],
 IsNull(Batch_Products.Damage, 0) as 'Damage'
FROM Items
inner join Batch_Products on Items.Product_Code = Batch_Products.Product_Code  
left outer join  StockAdjustmentReason on Batch_Products.DamagesReason = StockAdjustmentReason.MessageID  
WHERE       
 ISNULL(Batch_Products.Damage, 0) >= 1 AND     
 ISNULL(Batch_Products.Flags, 0) = 0 AND    
 Items.ManufacturerID = @MANUFACTURERID And Batch_Products.Quantity > 0 AND
 Quantity - ISNULL(ClaimedAlready, 0) > 0    
Group By Batch_Products.Product_Code, Items.ProductName, Batch_Number, Expiry,    
 Batch_Products.PurchasePrice, StockAdjustmentReason.Message, Batch_Products.Damage
 ) tmp
Group By tmp.Product_Code, tmp.ProductName, tmp.Batch_Number, tmp.Expiry, tmp.Price,
tmp.TaxSuffered, tmp.[Message], tmp.Damage 
