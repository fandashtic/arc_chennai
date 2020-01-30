CREATE procedure sp_ser_bookstock_issue(@PRODUCT_CODE nvarchar(15),  
	@TRACK_BATCH int, @CAPTURE_PRICE int, @CustomerID nvarchar(15))  
AS  

Declare @Customer_Type Int  
Select @Customer_Type = CustomerCategory  from Customer Where CustomerID = @CustomerID   

IF @CAPTURE_PRICE = 1  
BEGIN  
	IF @TRACK_BATCH = 1  
	BEGIN    
	  	IF @CUSTOMER_TYPE = 3   -- Special Price -- Institution Customer
		BEGIN  
			Select Batch_Number 'batch', Expiry 'expiry', SUM(Quantity) 'qty', Company_Price 'price', PKD,   
			Isnull(Free, 0) 'free', IsNull(Max(TaxSuffered), 0)  'TaxSuffered', isnull(ecp , 0) 'ecp' , 
			isnull(PurchasePrice, 0) 'Purchaseprice'
			From Batch_Products where Product_Code= @PRODUCT_CODE AND   
			Quantity > 0 And ISNULL(Damage, 0) = 0   
			Group By Batch_Number, Expiry, Company_Price, PKD, Isnull(Free, 0), isnull(ecp , 0),
			isnull(PurchasePrice , 0)
			Order By Isnull(Free, 0), MIN(Batch_Code)  
		END  
		ELSE IF IsNull(@CUSTOMER_TYPE,0) <>  3 -- Other then Institution   
		BEGIN  
			Select Batch_Number  'batch', Expiry 'expiry', SUM(Quantity) 'qty', ECP 'price', PKD,   
			Isnull(Free, 0) 'free', IsNull(Max(TaxSuffered), 0) 'TaxSuffered', isnull(ecp , 0) 'ecp', 
			isnull(PurchasePrice, 0) 'Purchaseprice'
			From Batch_Products where Product_Code= @PRODUCT_CODE AND   
			Quantity > 0 And ISNULL(Damage, 0) = 0   
			Group By Batch_Number, Expiry, ECP, PKD, Isnull(Free, 0),
			isnull(PurchasePrice , 0)
			Order By Isnull(Free, 0), MIN(Batch_Code)  
		END  
	END  
ELSE  
BEGIN  
	IF @CUSTOMER_TYPE = 3   
	BEGIN  
		Select '' 'batch', '' 'expiry', SUM(Quantity) 'qty', Company_Price 'price', PKD, Isnull(Free, 0) 'free',   
		IsNull(Max(TaxSuffered), 0) 'TaxSuffered', isnull(ecp , 0) 'ecp', isnull(PurchasePrice, 0) 'Purchaseprice'
		From Batch_Products where Product_Code= @PRODUCT_CODE AND Quantity > 0 And 
		ISNULL(Damage, 0) = 0   
		Group By Company_Price, PKD, Isnull(Free, 0), isnull(ecp, 0), isnull(PurchasePrice , 0) 
		Order By Isnull(Free, 0), MIN(Batch_Code)  
	END  
	ELSE IF IsNUll(@CUSTOMER_TYPE, 0) <> 3   
		BEGIN  
			Select '' 'batch', '' 'expiry', SUM(Quantity) 'qty', ECP 'price', PKD, Isnull(Free, 0) 'free',   
			IsNull(Max(TaxSuffered), 0) 'TaxSuffered', isnull(ecp , 0) 'ecp', isnull(PurchasePrice, 0) 'Purchaseprice'
			From Batch_Products where Product_Code= @PRODUCT_CODE AND 
			Quantity > 0 And ISNULL(Damage, 0) = 0   
			Group By ECP, PKD, Isnull(Free, 0) ,isnull(PurchasePrice , 0)
			Order By Isnull(Free, 0), MIN(Batch_Code)  
		END  
	END  
END  
ELSE  --- Option CSP Capture Price
BEGIN  
	IF @TRACK_BATCH = 1  		
	BEGIN  
		IF @CUSTOMER_TYPE = 3
		BEGIN
			Select Batch_Number  'batch', Expiry 'expiry', SUM(Quantity) 'qty', 0  'price', PKD, 
			Isnull(Free, 0) 'free', IsNull(Max(TaxSuffered), 0) 'TaxSuffered', isnull(ecp , 0) 'ecp', 
			isnull(PurchasePrice, 0) 'Purchaseprice'
			From Batch_Products where Product_Code= @PRODUCT_CODE AND 
			Quantity > 0 And ISNULL(Damage, 0) = 0   
			Group By Batch_Number, Expiry, PKD, Isnull(Free, 0), isnull(ecp , 0), isnull(PurchasePrice, 0)
			Order By Isnull(Free, 0), MIN(Batch_Code)  
		END
		ELSE
		BEGIN
			Select Batch_Number 'batch', Expiry 'expiry', SUM(Quantity) 'qty', 0 'price', PKD, 
			Isnull(Free, 0) 'free', IsNull(Max(TaxSuffered), 0) 'TaxSuffered', isnull(ecp , 0) 'ecp', 
			isnull(PurchasePrice, 0) 'Purchaseprice'
			From Batch_Products where Product_Code= @PRODUCT_CODE AND 
			Quantity > 0 And ISNULL(Damage, 0) = 0   
			Group By Batch_Number, Expiry, PKD, Isnull(Free, 0) ,isnull(ecp , 0), isnull(PurchasePrice, 0)
			Order By Isnull(Free, 0), MIN(Batch_Code)  
		END 
	END  
	ELSE    /* PKD = 1 */
	BEGIN  
		IF @CUSTOMER_TYPE = 3
		BEGIN
			Select '' 'batch', '' 'expiry', SUM(Quantity) 'qty', 0  'price', '' 'PKD', Isnull(Free, 0) 'free', 
			IsNull(Max(TaxSuffered), 0) 'TaxSuffered', isnull(ecp , 0) 'ecp', isnull(PurchasePrice, 0) 'Purchaseprice'
			From Batch_Products   
			where Product_Code= @PRODUCT_CODE AND Quantity > 0 And 
			ISNULL(Damage, 0) = 0   
			Group By isnull(Free,0) ,isnull(Company_Price , 0), isnull(ecp, 0), isnull(PurchasePrice, 0) 
			Order By Isnull(Free, 0), MIN(Batch_Code)  
		END
		ELSE
		BEGIN
			Select '' 'batch', '' 'expiry', SUM(Quantity) 'qty', 0 'price', '' 'PKD', Isnull(Free, 0) 'free', 
			IsNull(Max(TaxSuffered), 0) 'TaxSuffered', isnull(ecp , 0) 'ecp' , isnull(PurchasePrice, 0) 'Purchaseprice'
			From Batch_Products   
			where Product_Code= @PRODUCT_CODE AND Quantity > 0 And 
			ISNULL(Damage, 0) = 0   
			Group By isnull(Free,0) ,isnull(ecp , 0), isnull(PurchasePrice, 0)
			Order By Isnull(Free, 0), MIN(Batch_Code)  			
		END 
	END  
END 




