CREATE Procedure sp_Close_SRAbstractRecd (@StockRequestNo int)
As
Update SRAbstractReceived Set Status = IsNull(Status, 0) | 128 
Where StockRequestNo = @StockRequestNo
