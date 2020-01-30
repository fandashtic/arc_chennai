CREATE PROCEDURE sp_get_bookstock_fmcg(@PRODUCT_CODE nvarchar(15),
				  @TRACK_BATCH int,
				  @CAPTURE_PRICE int,
				  @UNUSED int = 0)
AS
	IF @TRACK_BATCH = 1
	BEGIN
		Select Batch_Number, Expiry, SUM(Quantity), SalePrice, PKD, 
		Isnull(Free, 0),
		IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0)
		From Batch_Products 
		where Product_Code= @PRODUCT_CODE AND Quantity > 0 And 
		ISNULL(Damage, 0) = 0 
		Group By Batch_Number, Expiry, SalePrice, PKD, Isnull(Free, 0),
		IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0)
		Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code) 
	END
	ELSE
	BEGIN
		Select N'', '', SUM(Quantity), SalePrice, PKD, Isnull(Free, 0),
		IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0)
		From Batch_Products 
		where Product_Code= @PRODUCT_CODE AND Quantity > 0 And 
		ISNULL(Damage, 0) = 0 
		Group By SalePrice, PKD, Isnull(Free, 0) ,
		IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0)
		Order By Isnull(Free, 0), PKD, MIN(Batch_Code) 
	END




