
CREATE PROCEDURE [sp_put_PriceChange]
	(
	@DocumentType 	[nvarchar](25),
	@DocumentDate 	[datetime],
	@CompanyID 	[nvarchar](15),
	 @Product_ID 	[nvarchar](15),
	 @ProductName 	[nvarchar](255),
	 @Description 	[nvarchar](255),
	@MRP 	Decimal(18,6),	 
	@SalePrice 	Decimal(18,6),
	 @Packing 	[nvarchar](50),
	 @Remarks 	[nvarchar](255),
	 @UOM		[nvarchar](50)
	 )

AS INSERT INTO [DownloadedItems] 
	 ( 
	 [DocumentType],
	 [DocumentDate],
	[CompanyID],
	 [Product_ID],
	 [ProductName],
	 [Description],
	 [MRP],
	 [SalePrice],
	 [Packing],
	 [Remarks],
	 [UOM]) 
 
VALUES 
	( 
	 @DocumentType,
	 @DocumentDate,
	@CompanyID,
	 @Product_ID,
	 @ProductName,
	 @Description,
	 @MRP	,
	 @SalePrice,
	 @Packing,
	 @Remarks,
	 @UOM
	)



