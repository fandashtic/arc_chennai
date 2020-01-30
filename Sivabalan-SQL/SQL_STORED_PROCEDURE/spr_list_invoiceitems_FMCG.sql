CREATE procedure [dbo].[spr_list_invoiceitems_FMCG](@INVOICEID int)

AS

SELECT InvoiceID, Product_Code, Batch_Code, Batch_Number, Quantity, SalePrice, TaxCode,
DiscountPercentage, DiscountValue, Amount, PurchasePrice, STPayable, FlagWord, SaleID,
MRP, Tax.Tax_Description, CSTPayable, TaxCode2, TaxSuffered, TaxSuffered2,
StockAdjustmentReason.Message
FROM InvoiceDetail, Tax, StockAdjustmentReason
WHERE InvoiceID = @INVOICEID AND
InvoiceDetail.TaxID *= Tax.Tax_Code AND
InvoiceDetail.ReasonID *= StockAdjustmentReason.MessageID
