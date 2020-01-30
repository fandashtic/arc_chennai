CREATE procedure spr_list_items_in_saleable_free_pidilite
(@docserial as integer)
as
select docserial,
"Item Code" = conversiondetail.Product_Code, 
"Item Name" = Items.ProductName,
"Quantity" = conversiondetail.Quantity,
"Reporting UOM" = conversiondetail.Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End,
"Conversion Factor" = conversiondetail.Quantity * IsNull(ConversionFactor, 0),
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
