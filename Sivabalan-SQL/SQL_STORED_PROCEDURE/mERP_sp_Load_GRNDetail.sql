CREATE PROCEDURE mERP_sp_Load_GRNDetail(@GRNID INT)
AS
Select 
"ItemCode" = G.Product_Code ,
"ItemName" = I.ProductName  ,
"UOMQty" = G.UOMQty ,
"FreeQty" = G.FreeQty ,
"UOMID" = G.UOM,
"UOMDescription" = (Select IsNull(Description, 'Multiple') From UOM Where UOM = G.UOM),
"TaxID" = IsNull((select top 1 GRNTAXID from batch_products where batch_products.GRN_ID = @GRNID and batch_Products.Product_code = G.Product_code order by batch_products.batch_code desc),0),
"DiscPer" = G.DiscPer,
"DiscPerUnit" = G.DiscPerUnit,
"InvDiscPer" = G.InvDiscPer,
"InvDiscPerUnit" = G.InvDiscPerUnit,  
"InvDiscAmt" = G.InvDiscAmt, 
"OtherDiscPer" = G.OtherDiscPer, 
"OtherDiscPerUnit" = G.OtherDiscPerUnit, 
"OtherDiscAmt" = G.OtherDiscAmt, 
"Serial" = G.Serial,
"TOQ"=isnull(G.TOQ,0)
,"HSNNumber" = I.HSNNumber
From GRNDetail G, Items I
Where GRNID = @GRNID
And G.Product_Code = I.Product_Code
Order By G.Serial
