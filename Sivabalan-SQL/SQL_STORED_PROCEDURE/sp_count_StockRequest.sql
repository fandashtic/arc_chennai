
Create Procedure sp_count_StockRequest
As
Select Count(*) From SRAbstractReceived Where (IsNull(Status, 0) & 128) = 0

