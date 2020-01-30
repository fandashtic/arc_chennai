
CREATE PROCEDURE [sp_put_MasterCatalog]
	(
	@DocumentType 	[nvarchar](25),
	@DocumentDate 	[datetime],
	 @Product_ID 	[nvarchar](15),
	 @ProductName 	[nvarchar](255),
	 @Description 	[nvarchar](255),
	 @ManufacturerID 	[nvarchar](15),
	 @ManufacturerName 	[nvarchar](255),
	 @CategoryID 	[nvarchar](15),
	 @CategoryName 	[nvarchar](255),
	 @MRP 	Decimal(18,6),
	 @UOM		[nvarchar](50)
	)
AS INSERT INTO [DownloadedItems] 
	 ( 
	 [DocumentType],
	 [DocumentDate],
	 [Product_ID],
	 [ProductName],
	 [Description],
	 [ManufacturerID],
	 [ManufacturerName],
	 [CategoryID],
	 [CategoryName],
	 [MRP],
	 [UOM]) 
 
VALUES 
	( 
	 @DocumentType,
	 @DocumentDate,
	 @Product_ID,
	 @ProductName,
	 @Description,
	 @ManufacturerID,
	 @ManufacturerName,
	 @CategoryID,
	 @CategoryName,
	 @MRP,
	 @UOM
	)


