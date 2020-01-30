CREATE Procedure sp_Print_StockTransferOutAbstract (@DocSerial int)
As
Declare @ItemCount int  
select @ItemCount=count(*) From StockTransferOutDetail
Inner Join Items On StockTransferOutDetail.Product_Code = Items.Product_Code 
Left Outer Join Batch_Products On StockTransferOutDetail.Batch_Code = Batch_Products.Batch_Code 
Where StockTransferOutDetail.DocSerial = @DocSerial      

Select "Doc Serial" = DocSerial, 
"Stock Transfer No" = DocPrefix + Cast(DocumentID As nvarchar),
"Date" = DocumentDate, "WareHouseID" = StockTransferOutAbstract.WareHouseID, 
"WareHouse Name" = WareHouse.WareHouse_Name,
"Net Value" = NetValue, Status, "Reference" = Reference,
"Address" = StockTransferOutAbstract.Address,
"Total Tax" = StockTransferOutAbstract.TaxAmount,
"Goods Value" = NetValue - StockTransferOutAbstract.TaxAmount,
"TIN Number" = TIN_Number,
"Item Count" = @ItemCount
From StockTransferOutAbstract, WareHouse
Where StockTransferOutAbstract.DocSerial = @DocSerial And
StockTransferOutAbstract.WareHouseID = WareHouse.WareHouseID
