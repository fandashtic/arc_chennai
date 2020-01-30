CREATE procedure spr_list_items_in_saleable_free
(@docserial as integer)
as
select docserial,
"Item Code" = conversiondetail.Product_Code, 
"Item Name" = Items.ProductName,
"Quantity" = conversiondetail.Quantity,
"Batch" = conversiondetail.Batch,
"PKD" = conversiondetail.PKD,
"Expiry" = conversiondetail.Expiry,
"Purchase Price" = ConversionDetail.PurchasePrice,
"PTS" = ConversionDetail.PTS,
"PTR" = ConversionDetail.PTR,
"ECP" = ConversionDetail.ECP,
"Special Price" = ConversionDetail.SpecialPrice
from Items,Conversiondetail
where docserial=@docserial and
conversiondetail.product_code=items.product_code
