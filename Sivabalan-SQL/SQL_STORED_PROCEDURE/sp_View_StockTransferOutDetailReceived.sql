CREATE Procedure sp_View_StockTransferOutDetailReceived (@DocSerial int)
As
Select StockTransferOutDetailReceived.Product_Code, Items.ProductName, Batch_Number, 
StockTransferOutDetailReceived.PTS, StockTransferOutDetailReceived.PTR, 
StockTransferOutDetailReceived.ECP, StockTransferOutDetailReceived.SpecialPrice, 
StockTransferOutDetailReceived.Rate, StockTransferOutDetailReceived.Quantity, 
StockTransferOutDetailReceived.Amount, StockTransferOutDetailReceived.Expiry, 
StockTransferOutDetailReceived.PKD, StockTransferOutDetailReceived.TaxSuffered,
StockTransferOutDetailReceived.TaxAmount, StockTransferOutDetailReceived.TotalAmount
,"Promotion" = Null,"Serial"=Serial,"QuantityRejected"=0
From StockTransferOutDetailReceived, Items
Where StockTransferOutDetailReceived.DocSerial = @DocSerial And
StockTransferOutDetailReceived.Product_Code = Items.Product_Code
Order By StockTransferOutDetailReceived.Product_Code, StockTransferOutDetailReceived.Rate

