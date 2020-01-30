CREATE procedure [dbo].[sp_get_BillItems_UOM_Combo](@Bill_ID int) as    
select BillDetail.Product_Code as "Code", Items.ProductName as "Name",     
Quantity, PurchasePrice, Amount, BillDetail.TaxSuffered, TaxAmount, Discount,    
BillDetail.Batch, BillDetail.Expiry, BillDetail.PKD,     
(BillDetail.PTS * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))),     
(BillDetail.PTR * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))),    
(BillDetail.ECP * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))),    
(BillDetail.SpecialPrice * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))),    
"UOMID" = BillDetail.UOM,     
"UOMDescription" = UOM.Description, BillDetail.UOMQty, BillDetail.UOMPrice,BillDetail.ComboID as ComboId,  
"ExciseDuty" = IsNull(BillDetail.ExciseDuty,0), "PPBED" = IsNull(BillDetail.PurchasePriceBeforeExciseAmount,0),"VAT" = ISNULL(BillDetail.VAT,0),
"Promotion" = isnull(billdetail.promotion,0)
from BillDetail
Inner Join Items on BillDetail.Product_Code = Items.Product_Code
Left Outer Join UOM on BillDetail.UOM = UOM.UOM
where 
--BillDetail.Product_Code = Items.Product_Code and 
BillID = @Bill_ID 
--and BillDetail.UOM *= UOM.UOM   
