CREATE procedure sp_Check_RecSTO(@DocSerial as int)
As
If Exists(select StockTransferInAbstract.ReferenceSerial
from StockTransferInAbstract,StockTransferOutAbstractReceived 
Where StockTransferInAbstract.ReferenceSerial = StockTransferOutAbstractReceived.OriginalID  
and StockTransferInAbstract.DocSerial = @DocSerial)
select 1
Else
select 0
