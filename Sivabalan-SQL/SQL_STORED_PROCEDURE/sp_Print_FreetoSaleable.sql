CREATE Procedure sp_Print_FreetoSaleable (@DocSerial int)
As
Select "Item Code" = ConversionDetail.Product_Code, "Item Name" = Items.ProductName, 
"Batch" = ConversionDetail.Batch, "Expiry" = ConversionDetail.Expiry,
"PKD" = ConversionDetail.PKD, "Quantity" = ConversionDetail.Quantity, 
"PTS" = ConversionDetail.PTS, "PTR" = ConversionDetail.PTR, 
"ECP" = ConversionDetail.ECP, "Special Price" = ConversionDetail.SpecialPrice
From ConversionDetail, Items
Where ConversionDetail.DocSerial = @DocSerial And
Items.Product_Code = ConversionDetail.Product_Code
