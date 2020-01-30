CREATE procedure [dbo].[sp_print_BillItems](@BillNo INT)

AS

SELECT "Item Code" = BillDetail.Product_Code, 
"Item Name" = Items.ProductName, "Description" = Items.description, "Quantity" = Quantity, 
"UOM" = UOM.Description, "Purchase Price" = PurchasePrice, 
"Amount" = Amount, "Tax Suffered" = BillDetail.TaxSuffered, 
"Tax Amount" = BillDetail.TaxAmount,
"Batch" = BillDetail.Batch, "Expiry" = BillDetail.Expiry, 
"PKD" = BillDetail.PKD, "PTS" = BillDetail.PTS, "PTR" = BillDetail.PTR,
"ECP" = BillDetail.ECP, 
"PPBED" = IsNull(BillDetail.PurchasePriceBeforeExciseAmount, 0), 
"Excise Duty" = IsNull(BillDetail.ExciseDuty, 0)
FROM BillDetail, Items, UOM
WHERE BillDetail.BillID = @BillNo 
AND BillDetail.Product_Code = Items.Product_Code
AND Items.UOM *= UOM.UOM
Order By BillDetail.Serial
