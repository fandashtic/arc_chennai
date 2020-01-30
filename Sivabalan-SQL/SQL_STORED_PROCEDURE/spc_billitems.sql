CREATE PROCEDURE spc_billitems(@BILLID int)
AS
SELECT Items.Alias, BillDetail.Quantity, BillDetail.PurchasePrice, BillDetail.Amount,
BillDetail.TaxSuffered, BillDetail.TaxAmount, BillDetail.TaxCode,
BillDetail.Discount, BillDetail.Batch, BillDetail.Expiry, BillDetail.PKD,
BillDetail.PTS, BillDetail.PTR, BillDetail.ECP 
FROM BillDetail, Items 
WHERE BillID = @BILLID And BillDetail.Product_Code = Items.Product_Code

