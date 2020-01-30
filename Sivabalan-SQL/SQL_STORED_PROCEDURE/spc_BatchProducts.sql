CREATE procedure [dbo].[spc_BatchProducts]
as
Select Batch_Code, Batch_Number, Product_Code, GRN_ID, 
Expiry, Quantity, PurchasePrice,
PTax.Tax_Description, SalePrice, STax.Tax_Description, PTS, PTR, ECP, QuantityReceived,
Company_Price, Flags,
Damage, StockAdjustmentReason.Message, PKD, ClaimedAlready, Free, StockTransferID, 
BatchReference
From Batch_Products, Tax as PTax, Tax as STax,
StockAdjustmentReason
Where Batch_Products.TaxCode *= STax.Tax_Code and
Batch_Products.PurchaseTax *= PTax.Tax_Code and
Batch_Products.DamagesReason *= StockAdjustmentReason.MessageID
