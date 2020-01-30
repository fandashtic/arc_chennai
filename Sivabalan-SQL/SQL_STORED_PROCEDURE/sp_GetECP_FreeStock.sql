CREATE procedure sp_GetECP_FreeStock(@Product_Code nVarchar(50), @Batch_Code INT)  
AS  
DECLARE @Free INT  
DECLARE @BatchRef INT   
DECLARE @PriceOption INT

select @priceoption = Price_Option FROM Items, ItemCategories
WHERE ItemCategories.CategoryID = Items.CategoryID And  
Product_Code = @Product_Code

if @priceoption =1 
begin
	SELECT @Free = IsNull([Free],0), @BatchRef = IsNull(BatchReference,0) FROM Batch_Products WHERE Product_Code = @Product_Code  
	And Batch_Code = @Batch_Code  
  
	SELECT  "PTS" = Batch.PTS,  
			"PTR" = Batch.PTR,  
			"ECP" = Batch.ECP,  
			"SPLPRICE" = Batch.COMPANY_PRICE,  
			"PRICE" = Batch.purchasePRICE,  
			"MRP" = items.mrp  
	FROM Items, Batch_Products Batch  
	WHERE Items.Product_Code = Batch.Product_Code And   
	Batch.Batch_Code = (CASE @Free WHEN 1 THEN @BatchRef ELSE @Batch_Code END)  
END  
ELSE
BEGIN
	SELECT  "PTS" = Items.PTS,  
			"PTR" = Items.PTR,  
			"ECP" = Items.ECP,  
			"SPLPRICE" = Items.COMPANY_PRICE,  
			"PRICE" = Items.purchase_PRICE,  
			"MRP" = items.mrp  
	FROM Items WHERE Items.Product_Code = @Product_Code
end
  
  


