
CREATE PROCEDURE [sp_insert_Brand]
	(@BrandName_2 	[nvarchar](255),
	 @ManufacturerID_4 	[nvarchar](15))

AS INSERT INTO [Brand] 
	 ([BrandName],
	 [ManufacturerID]) 
 
VALUES 
	(@BrandName_2,
	 @ManufacturerID_4)
SELECT @@IDENTITY


