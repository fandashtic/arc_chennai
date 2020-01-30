
CREATE PROCEDURE [sp_insert_AdjReason]
	(@Message 	[nvarchar](255))

AS INSERT INTO [StockAdjustmentReason] 
	 ([Message]) 
 
VALUES 
	(@Message)
select @@identity


