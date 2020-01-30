CREATE procedure sp_GetECP_FreeStock_FMCG(@Product_Code nVarchar(50), @Batch_Code INT)
AS
DECLARE @Free INT
DECLARE @BatchRef INT 

SELECT @Free = IsNull([Free],0), @BatchRef = IsNull(BatchReference,0) FROM Batch_Products WHERE Product_Code = @Product_Code
And Batch_Code = @Batch_Code

SELECT "PRICE" = CASE Price_Option 
WHEN 1 THEN
Batch.purchasePRICE
ELSE
Items.purchase_PRICE
END,
"MRP" = items.mrp
FROM Items, ItemCategories, Batch_Products Batch
WHERE ItemCategories.CategoryID = Items.CategoryID And
Items.Product_Code = Batch.Product_Code And 
Batch.Batch_Code = (CASE @Free WHEN 1 THEN @BatchRef ELSE @Batch_Code END)



