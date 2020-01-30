CREATE Procedure sp_Print_StockTransferInDetail_MultiUOM_serial (@DocSerial int)
As
Select "Item Code" = StockTransferInDetail.Product_Code, 
"Item Name" = Items.ProductName, "Batch" = Batch_Number, 
"PTS" = CASE Price_Option
WHEN 1 THEN
Max(StockTransferInDetail.PTS)
ELSE
Max(Items.PTS)
END, 
"PTR" = CASE Price_Option
WHEN 1 THEN
Max(StockTransferInDetail.PTR)
ELSE
Max(Items.PTR)
END, 
"ECP" = CASE Price_Option
WHEN 1 THEN
Max(StockTransferInDetail.ECP)
ELSE
Max(Items.ECP)
END,
"Special Price" = CASE Price_Option
WHEN 1 THEN
Max(StockTransferInDetail.SpecialPrice)
ELSE
Max(Items.Company_Price)
END,
"Rate" = StockTransferInDetail.Rate, 
"UOM2Quantity" = dbo.GetFirstLevelUOMQty(StockTransferInDetail.Product_Code, Sum(StockTransferInDetail.Quantity)),  
"UOM2Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  StockTransferInDetail.Product_Code )),  
"UOM1Quantity" = dbo.GetSecondLevelUOMQty(StockTransferInDetail.Product_Code, Sum(StockTransferInDetail.Quantity)),  
"UOM1Description" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  StockTransferInDetail.Product_Code )),  
"UOMQuantity" = dbo.GetLastLevelUOMQty(StockTransferInDetail.Product_Code, Sum(StockTransferInDetail.Quantity)),  
"UOMDescription" = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  StockTransferInDetail.Product_Code )),  
"Amount" = Sum(StockTransferInDetail.Amount), 
"Expiry" = StockTransferInDetail.Expiry, 
"PKD" = StockTransferInDetail.PKD,
"Tax Suffered" = Sum(StockTransferInDetail.TaxSuffered),
"Tax Amount" = Sum(StockTransferInDetail.TaxAmount),
"Total Amount" = Sum(StockTransferInDetail.TotalAmount)
From StockTransferInDetail, Items, ItemCategories
Where StockTransferInDetail.DocSerial = @DocSerial And
StockTransferInDetail.Product_Code = Items.Product_Code And
ItemCategories.CategoryID = Items.CategoryID
Group by StockTransferInDetail.Product_Code, Items.ProductName, Batch_Number, 
StockTransferInDetail.PTS, StockTransferInDetail.PTR, StockTransferInDetail.ECP,
StockTransferInDetail.SpecialPrice,  StockTransferInDetail.Rate, StockTransferInDetail.Expiry, 
StockTransferInDetail.PKD, Price_Option,StockTransferInDetail.Serial
Order by StockTransferInDetail.Serial


