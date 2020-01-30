CREATE procedure sp_ser_bookstock(@PRODUCT_CODE nvarchar(15),  
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
			Select Batch_Number 'batch', Expiry 'Expiry', SUM(Quantity) 'qty', IsNull(Company_Price,0) 'price', PKD 'pkd',   
			IsNull(Free, 0) 'free', IsNull(Max(TaxSuffered), 0) 'TaxSuffered', IsNull(ecp , 0) 'ecp'
			From Batch_Products where Product_Code= @PRODUCT_CODE AND   
			Quantity > 0 And IsNull(Damage, 0) = 0   
			Group By Batch_Number, Expiry, IsNull(Company_Price,0), PKD, IsNull(Free, 0),
			IsNull(ecp , 0)
			Order By IsNull(Free, 0), MIN(Batch_Code)  
		END  
		ELSE IF IsNull(@CUSTOMER_TYPE,0) <>  3 -- Other then Institution   
		BEGIN  
			Select Batch_Number 'batch', Expiry 'Expiry', SUM(Quantity) 'qty', IsNull(ECP,0) 'price', PKD 'pkd',   
			IsNull(Free, 0) 'free', IsNull(Max(TaxSuffered), 0) 'TaxSuffered', IsNull(ecp , 0) 'ecp'
			From Batch_Products where Product_Code= @PRODUCT_CODE AND   
			Quantity > 0 And IsNull(Damage, 0) = 0   
			Group By Batch_Number, Expiry, IsNull(ECP,0), PKD, IsNull(Free, 0),
			IsNull(ecp , 0)
			Order By IsNull(Free, 0), MIN(Batch_Code)  
		END  
	END  
ELSE  
BEGIN  
	IF @CUSTOMER_TYPE = 3   
	BEGIN  
		Select '' 'batch', '' 'Expiry', SUM(Quantity) 'qty', IsNull(Company_Price,0) 'price', PKD 'pkd', IsNull(Free, 0) 'free',   
		IsNull(Max(TaxSuffered), 0) 'TaxSuffered', IsNull(ECP , 0) 'ecp'
		From Batch_Products where Product_Code= @PRODUCT_CODE AND Quantity > 0 And 
		IsNull(Damage, 0) = 0   
		Group By IsNull(Company_Price,0), PKD, IsNull(Free, 0), IsNull(ecp , 0) 
		Order By IsNull(Free, 0), MIN(Batch_Code)  
	END  
	ELSE IF IsNull(@CUSTOMER_TYPE, 0) <> 3   
		BEGIN  
			Select '' 'batch', '' 'Expiry', SUM(Quantity) 'qty', IsNull(ECP,0) 'price', PKD 'pkd', IsNull(Free, 0) 'free',   
			IsNull(Max(TaxSuffered), 0) 'TaxSuffered', IsNull(ecp , 0) 'ecp' 
			From Batch_Products where Product_Code= @PRODUCT_CODE AND 
			Quantity > 0 And IsNull(Damage, 0) = 0   
			Group By IsNull(ECP,0), PKD, IsNull(Free, 0) ,IsNull(ecp , 0)
			Order By IsNull(Free, 0), MIN(Batch_Code)  
		END  
	END  
END  
ELSE  --- Option CSP Capture Price
BEGIN  
	IF @TRACK_BATCH = 1  		
	BEGIN  
		IF @CUSTOMER_TYPE = 3
		BEGIN
			Select Batch_Number 'batch', Expiry 'Expiry', SUM(Quantity) 'qty', 0 'price', PKD 'pkd', 
			IsNull(Free, 0) 'free', IsNull(Max(TaxSuffered), 0) 'TaxSuffered', IsNull(ecp , 0) 'ecp'
			From Batch_Products where Product_Code= @PRODUCT_CODE AND 
			Quantity > 0 And IsNull(Damage, 0) = 0   
			Group By Batch_Number, Expiry, PKD, IsNull(Free, 0),IsNull(ecp , 0)
			Order By IsNull(Free, 0), MIN(Batch_Code)  
		END
		ELSE
		BEGIN
			Select Batch_Number 'batch', Expiry 'Expiry', SUM(Quantity) 'qty', 0 'price', PKD 'pkd', 
			IsNull(Free, 0) 'free', IsNull(Max(TaxSuffered), 0) 'TaxSuffered', IsNull(ecp , 0) 'ecp'
			From Batch_Products where Product_Code= @PRODUCT_CODE AND 
			Quantity > 0 And IsNull(Damage, 0) = 0   
			Group By Batch_Number, Expiry, PKD, IsNull(Free, 0) ,IsNull(ecp , 0)
			Order By IsNull(Free, 0), MIN(Batch_Code)  
		END 
	END  
	ELSE    /* PKD = 1 */
	BEGIN  
		IF @CUSTOMER_TYPE = 3
		BEGIN
			Select '' 'batch', '' 'Expiry', SUM(Quantity) 'qty', 0 'price', '' 'pkd', IsNull(Free, 0) 'free', 
			IsNull(Max(TaxSuffered), 0) 'taxsuffered', IsNull(ecp , 0) 'ecp'
			From Batch_Products   
			where Product_Code= @PRODUCT_CODE AND Quantity > 0 And 
			IsNull(Damage, 0) = 0   
			Group By IsNull(Free,0) ,IsNull(ecp , 0)
			Order By IsNull(Free, 0), MIN(Batch_Code)  
		END
		ELSE
		BEGIN
			Select '' 'batch', '' 'Expiry', SUM(Quantity) 'qty', 0 'price', '' 'pkd', IsNull(Free, 0) 'free', 
			IsNull(Max(TaxSuffered), 0) 'TaxSuffered', IsNull(ecp , 0) 'ecp'
			From Batch_Products   
			where Product_Code= @PRODUCT_CODE AND Quantity > 0 And 
			IsNull(Damage, 0) = 0   
			Group By IsNull(Free,0) ,IsNull(ecp , 0)
			Order By IsNull(Free, 0), MIN(Batch_Code)  			
		END 
	END  
END
