
CREATE PROCEDURE [sp_put_DownloadedItems]
	(
	@DocumentType 	[nvarchar](25),
	@CompanyID 	[nvarchar](15),
	@DocumentDate 	[datetime],
	 @Product_ID 	[nvarchar](15),
	 @ProductName 	[nvarchar](255),
	 @Description 	[nvarchar](255),
	 @ManufacturerID 	[nvarchar](15),
	 @ManufacturerName 	[nvarchar](255),
	 @CategoryID 	[nvarchar](15),
	 @CategoryName 	[nvarchar](255),
	 @SalePrice 	Decimal(18,6),
	 @UOM		[nvarchar](50),
	 @Packing 	[nvarchar](50),
	 @Remarks 	[nvarchar](255),
	 @MRP 	Decimal(18,6))

AS INSERT INTO [DownloadedItems] 
	 ( 
	 [DocumentType],
	[CompanyID],
	 [DocumentDate],
	 [Product_ID],
	 [ProductName],
	 [Description],
	 [ManufacturerID],
	 [ManufacturerName],
	 [CategoryID],
	 [CategoryName],
	 [SalePrice],
	 [UOM],
	 [Packing],
	 [Remarks],
	 [MRP]) 
 
VALUES 
	( 
	 @DocumentType,
	@CompanyID,
	 @DocumentDate,
	 @Product_ID,
	 @ProductName,
	 @Description,
	 @ManufacturerID,
	 @ManufacturerName,
	 @CategoryID,
	 @CategoryName,
	 @SalePrice,
	 @UOM,
	 @Packing,
	 @Remarks,
	 @MRP)

