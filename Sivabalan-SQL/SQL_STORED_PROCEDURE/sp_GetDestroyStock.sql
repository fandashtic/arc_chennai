Create Procedure sp_GetDestroyStock(@StockDestructID nvarchar(255), @Batch_Code nvarchar(255)) 
As
Select DestroyQuantity 
From StockDestructionDetail, StockDestructionAbstract 
where StockDestructionDetail.DocSerial = @StockDestructID
and BatchCode in (@Batch_Code) 
and StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial


