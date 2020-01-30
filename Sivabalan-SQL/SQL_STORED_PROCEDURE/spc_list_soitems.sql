CREATE PROCEDURE spc_list_soitems(@SONUMBER int)
AS
SELECT "Item Code" = Items.Alias, "Batch" = SODetail.Batch_Number,
SODetail.Quantity, SODetail.Pending, "Sale Price" = SODetail.SalePrice, 
SODetail.SaleTax, SODetail.TaxCode2, SODetail.Discount, SODetail.TaxSuffered
FROM SODetail, Items 
WHERE SONumber = @SONUMBER And SODetail.Product_Code = Items.Product_Code
