CREATE Procedure sp_Print_ConversionDetail (@DocSerial as int)
As
Select "Item Code" = ConversionDetail.Product_Code, 
"Item Name" = Items.ProductName, "Batch" = ConversionDetail.Batch, 
"PKD" = ConversionDetail.PKD, "Expiry" = ConversionDetail.Expiry, 
"Quantity" = ConversionDetail.Quantity, 
"Purchase Price" = ConversionDetail.PurchasePrice, 
--If CSP not set, The prices should be taken from item master
"PTS" = case price_option when 1 then ConversionDetail.PTS  else items.PTS end,
"PTR" = case price_option when 1 then ConversionDetail.PTR  else items.PTR end,
"ECP" = case price_option when 1 then ConversionDetail.ECP  else items.ECP end,
"Special Price" = case price_option when 1 then ConversionDetail.SpecialPrice else items.company_price end
From ConversionDetail, Items,itemcategories
Where ConversionDetail.Product_Code = Items.Product_Code And
itemcategories.categoryid = items.categoryid and
ConversionDetail.DocSerial = @DocSerial

