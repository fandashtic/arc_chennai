Create Procedure sp_get_AmendFreeBatch_MUOM (@BatchCode Int)
As
Select dbo.GetQtyAsMultiple(Batch_Products.Product_Code, QuantityReceived) 
From Batch_Products Where BatchReference = @BatchCode

