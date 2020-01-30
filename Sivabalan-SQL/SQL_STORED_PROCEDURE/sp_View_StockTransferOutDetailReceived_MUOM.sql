Create Procedure sp_View_StockTransferOutDetailReceived_MUOM(@DocSerial int)  
As  
Select Items.Product_Code,
Items.ProductName, 
StockTransferOutDetailReceived.Batch_Number,
StockTransferOutDetailReceived.PTS,
StockTransferOutDetailReceived.PTR,
StockTransferOutDetailReceived.ECP,
StockTransferOutDetailReceived.SpecialPrice as [Special Price],
StockTransferOutDetailReceived.Rate,
StockTransferOutDetailReceived.Quantity,
StockTransferOutDetailReceived.Amount,
StockTransferOutDetailReceived.Expiry,
StockTransferOutDetailReceived.PKD,
StockTransferOutDetailReceived.TaxSuffered as [Tax Suffered], 
StockTransferOutDetailReceived.TaxAmount,
StockTransferOutDetailReceived.TotalAmount as [Total],
StockTransferOutDetailReceived.UOM as UOMID,
"Promotion" = '',
"TaxCode" = '',
StockTransferOutDetailReceived.serial,
StockTransferOutDetailReceived.UOMPrice,
StockTransferOutDetailReceived.UOM as UOMID,
"DocumentQuantity" = (Case When StockTransferOutDetailReceived.Free = 1 Then 0 Else Quantity End),
"DocumentFreeQty" = (Case When StockTransferOutDetailReceived.Free = 1 Then Quantity Else 0 End),
"QuantityReceived" = 0,
"QuantityRejected" = 0
from StockTransferOutDetailReceived,items
where
StockTransferOutDetailReceived.Product_code = Items.Product_Code And
Docserial in (@DocSerial)
