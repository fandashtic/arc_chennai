Create Procedure sp_get_PurPrice_Batch 
	@Batch_Number 	nvarchar(128),
	@Batch_Price	decimal(18,6),
	@Item_Code		nvarchar(30),
	@FreeRow		int,
	@Track_Batch	int,
	@PurchasedAt	int,
	@Capture_Price	int,
	@CustomerType 	int
As

IF @TRACK_BATCH = 1
	Select 
		Case @PurchasedAt 
		When 1 Then PTS
		When 2 Then	PTR
		When 3 Then Company_Price
		Else ECP
		End
	From Batch_Products
	WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER and 
		  ((ISNULL(PTS, 0) = @BATCH_PRICE And @CustomerType = 1) OR
		  (ISNULL(PTR, 0) = @BATCH_PRICE And @CustomerType = 2) OR
		  (ISNULL(Company_Price, 0) = @BATCH_PRICE And @CustomerType = 3) OR
		  (ISNULL(ECP, 0) = @BATCH_PRICE And @CustomerType = 4)) AND 
		  ISNULL(Quantity, 0) > 0   
	      And ISNULL(Damage, 0) = 0 AND 
		  (Expiry >= GetDate() OR Expiry IS NULL) And 
		  isnull(Free, 0) = @FreeRow  
ELSE -- Track Batch
	Select 
		Case @PurchasedAt 
		When 1 Then PTS
		When 2 Then	PTR
		When 3 Then Company_Price
		Else ECP
		End
	From Batch_Products
	WHERE Product_Code = @ITEM_CODE and 
		  ((ISNULL(PTS, 0) = @BATCH_PRICE And @CustomerType = 1) OR
		  (ISNULL(PTR, 0) = @BATCH_PRICE And @CustomerType = 2) OR
		  (ISNULL(Company_Price, 0) = @BATCH_PRICE And @CustomerType = 3) OR
		  (ISNULL(ECP, 0) = @BATCH_PRICE And @CustomerType = 4)) AND 
		  ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 AND 
		  (Expiry >= GetDate() OR Expiry IS NULL) And 
		  isnull(Free, 0) = @FreeRow  		  


