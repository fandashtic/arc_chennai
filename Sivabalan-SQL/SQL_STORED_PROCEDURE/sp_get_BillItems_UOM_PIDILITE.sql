CREATE procedure [dbo].[sp_get_BillItems_UOM_PIDILITE](@Bill_ID int) 
As    
Select BillDetail.Product_Code as "Code", Items.ProductName as "Name",     
Quantity, PurchasePrice, Amount, BillDetail.TaxSuffered, TaxAmount, Discount,    
BillDetail.Batch, BillDetail.Expiry, BillDetail.PKD,     
(BillDetail.PTS * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))),     
(BillDetail.PTR * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))),    
(BillDetail.ECP * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))),    
(BillDetail.SpecialPrice * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))),    
"UOMID" = BillDetail.UOM,     
"UOMDescription" = UOM.Description, BillDetail.UOMQty, BillDetail.UOMPrice, BillDetail.TaxCode "TaxCode",    
"ExciseDuty" = IsNull(BillDetail.ExciseDuty,0), "PPBED" = IsNull(BillDetail.PurchasePriceBeforeExciseAmount,0) ,"VAT" = ISNULL(BillDetail.VAT,0) ,  
"Promotion" = isnull(billdetail.promotion,0), "PromotionECP" =   
Case IsNull(Promotion,0) When 1 Then BillDetail.ECP Else  
(BillDetail.ECP * (BillDetail.UOMPrice / (Case When IsNull(BillDetail.PurchasePrice, 0) = 0 Then 1 Else BillDetail.PurchasePrice End))) End,
"Octroi Percentage" = BillDetail.OctroiPercentage,
"Octroi Amount" = BillDetail.OctroiAmount,"Freight" = BillDetail.Freight  
from BillDetail
Inner Join Items on BillDetail.Product_Code = Items.Product_Code
Left Outer Join UOM on BillDetail.UOM = UOM.UOM
where 
--BillDetail.Product_Code = Items.Product_Code and 
BillID = @Bill_ID 
--and   BillDetail.UOM *= UOM.UOM    
Order By BillDetail.Serial    


