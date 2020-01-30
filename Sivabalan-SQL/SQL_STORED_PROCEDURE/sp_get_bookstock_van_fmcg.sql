CREATE PROCEDURE [dbo].[sp_get_bookstock_van_fmcg](@PRODUCT_CODE nvarchar(15),
				  @TRACK_BATCH int,
				  @CAPTURE_PRICE int,
				  @DOCID int)
AS
IF @TRACK_BATCH = 1
BEGIN
	Select VanStatementDetail.Batch_Number, Batch_Products.Expiry, SUM(Pending), 
	VanStatementDetail.SalePrice, Batch_Products.PKD, 
	isnull(Batch_Products.Free, 0), IsNull(Batch_Products.TaxSuffered, 0),
	Isnull(ApplicableOn,0), Isnull(Partofpercentage,0)
	From VanStatementDetail
	Left Outer Join Batch_Products on VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
	where VanStatementDetail.DocSerial = @DOCID 
	--and VanStatementDetail.Batch_Code *= Batch_Products.Batch_Code 
	and VanStatementDetail.Product_Code= @PRODUCT_CODE 
	AND VanStatementDetail.Pending > 0 
	Group By VanStatementDetail.Batch_Number, Expiry, VanStatementDetail.SalePrice, Batch_Products.PKD, isnull(Batch_Products.Free, 0),
	IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0)
	Order By Isnull(Free, 0), MIN(VanStatementDetail.Batch_Code)
END
ELSE
BEGIN
	Select N'', '', SUM(VanStatementDetail.Pending), 
	VanStatementDetail.SalePrice, Batch_Products.PKD, 
	isnull(Batch_Products.Free, 0), IsNull(Batch_Products.TaxSuffered, 0),
	Isnull(ApplicableOn,0), Isnull(Partofpercentage,0)
	From VanStatementDetail
	Left Outer Join Batch_Products on VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
	where VanStatementDetail.DocSerial = @DOCID 
	--and VanStatementDetail.Batch_Code *= Batch_Products.Batch_Code 
	and VanStatementDetail.Product_Code= @PRODUCT_CODE 
	AND VanStatementDetail.Pending > 0 
	Group By VanStatementDetail.SalePrice, Batch_Products.PKD, isnull(Batch_Products.Free, 0),
	IsNull(TaxSuffered, 0) , Isnull(ApplicableOn,0), Isnull(Partofpercentage,0)
	Order By Isnull(Free, 0), MIN(VanStatementDetail.Batch_Code)
END


