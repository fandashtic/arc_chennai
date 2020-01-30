CREATE procedure sp_ser_bookstock_issue_fmcg(@PRODUCT_CODE nvarchar(15),  
	@TRACK_BATCH int, @CAPTURE_PRICE int)  
AS  

IF @CAPTURE_PRICE = 1  
BEGIN  
	IF @TRACK_BATCH = 1  
	BEGIN    
		Select Batch_Number 'batch', Expiry 'expiry', SUM(Quantity) 'qty', SalePrice 'price', PKD,   
		Isnull(Free, 0) 'free', IsNull(Max(TaxSuffered), 0)  'TaxSuffered',
		isnull(PurchasePrice, 0) 'Purchaseprice'
		From Batch_Products where Product_Code= @PRODUCT_CODE AND   
		Quantity > 0 And ISNULL(Damage, 0) = 0   
		Group By Batch_Number, Expiry, SalePrice, PKD, Isnull(Free, 0),	isnull(PurchasePrice , 0)
		Order By Isnull(Free, 0), MIN(Batch_Code)  
	END  
	ELSE  
	BEGIN  
		Select '' 'batch', '' 'expiry', SUM(Quantity) 'qty', SalePrice 'price', PKD, Isnull(Free, 0) 'free',   
		IsNull(Max(TaxSuffered), 0) 'TaxSuffered', isnull(PurchasePrice, 0) 'Purchaseprice'
		From Batch_Products where Product_Code= @PRODUCT_CODE AND Quantity > 0 And 
		ISNULL(Damage, 0) = 0   
		Group By SalePrice, PKD, Isnull(Free, 0), isnull(PurchasePrice , 0) 
		Order By Isnull(Free, 0), MIN(Batch_Code)  
	END
END  
ELSE  --- Option CSP Capture Price
BEGIN  
	IF @TRACK_BATCH = 1  		
	BEGIN  
		Select Batch_Number  'batch', Expiry 'expiry', SUM(Quantity) 'qty', 0  'price', PKD, 
		Isnull(Free, 0) 'free', IsNull(Max(TaxSuffered), 0) 'TaxSuffered', isnull(PurchasePrice, 0) 'Purchaseprice'
		From Batch_Products where Product_Code= @PRODUCT_CODE AND 
		Quantity > 0 And ISNULL(Damage, 0) = 0   
		Group By Batch_Number, Expiry, PKD, Isnull(Free, 0), isnull(SalePrice , 0), isnull(PurchasePrice, 0)
		Order By Isnull(Free, 0), MIN(Batch_Code)  
	END  
	ELSE    /* PKD = 1 */
	BEGIN  
		Select '' 'batch', '' 'expiry', SUM(Quantity) 'qty', 0  'price', '' 'PKD', Isnull(Free, 0) 'free', 
		IsNull(Max(TaxSuffered), 0) 'TaxSuffered', isnull(PurchasePrice, 0) 'Purchaseprice'
		From Batch_Products   
		where Product_Code= @PRODUCT_CODE AND Quantity > 0 And 
		ISNULL(Damage, 0) = 0   
		Group By isnull(Free,0) ,isnull(SalePrice, 0), isnull(PurchasePrice, 0) 
		Order By Isnull(Free, 0), MIN(Batch_Code)  
	END  
END 




