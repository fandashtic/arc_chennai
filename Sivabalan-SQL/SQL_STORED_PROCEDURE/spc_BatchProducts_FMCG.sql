CREATE procedure [dbo].[spc_BatchProducts_FMCG]
as
Select Batch_Products.Batch_Code, Batch_Products.Batch_Number, Items.Alias, 
Batch_Products.GRN_ID, Batch_Products.Expiry, Batch_Products.Quantity, 
Batch_Products.PurchasePrice, PTax.Tax_Description, Batch_Products.SalePrice, 
STax.Tax_Description, Batch_Products.QuantityReceived, 
Batch_Products.Flags, Batch_Products.Damage, StockAdjustmentReason.Message,
Batch_Products.PKD, Batch_Products.ClaimedAlready, Batch_Products.Free, 
Batch_Products.StockTransferID, Batch_Products.BatchReference
From Batch_Products, Tax as PTax, Tax as STax, Items,
StockAdjustmentReason
Where Batch_Products.TaxCode *= STax.Tax_Code and
Batch_Products.PurchaseTax *= PTax.Tax_Code and
Batch_Products.DamagesReason *= StockAdjustmentReason.MessageID And
Batch_Products.Product_Code = Items.Product_Code
