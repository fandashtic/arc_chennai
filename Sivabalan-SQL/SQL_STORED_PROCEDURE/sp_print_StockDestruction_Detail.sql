CREATE Procedure sp_print_StockDestruction_Detail (@StockDestroyID as integer)  
As  
SELECT "Product Code" = ClaimsDetail.Product_Code, "Item Name" = Items.ProductName, 
"Batch" = Batch,"Expiry" = Expiry,"Purchase Price" = PurchasePrice, 
"Claimed Quantity" = StockDestructionDetail.ClaimQuantity,
"Destroy Quantity" = StockDestructionDetail.DestroyQuantity, 
"Rate" = Rate, "Value" =  Quantity * Rate, "Remarks" = Remarks
FROM ClaimsDetail, Items, StockDestructionDetail, StockDestructionAbstract  
WHERE StockDestructionDetail.DocSerial = @StockDestroyID
AND ClaimsDetail.Product_Code = Items.Product_Code  
AND StockDestructionAbstract.ClaimID = ClaimsDetail.ClaimID  
AND StockDestructionAbstract.DocSerial = StockDestructionDetail.DocSerial 
AND StockDestructionDetail.Product_Code = Items.Product_code
AND StockDestructionDetail.BatchCode = ClaimsDetail.Batch_Code 


