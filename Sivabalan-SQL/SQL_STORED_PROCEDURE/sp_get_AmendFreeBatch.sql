Create Procedure sp_get_AmendFreeBatch (@BatchCode Int)
As
Select QuantityReceived From Batch_Products Where BatchReference = @BatchCode


