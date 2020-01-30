
CREATE PROCEDURE [sp_insert_District]
	(	 @District 	[nvarchar](50))

AS INSERT INTO [District] 
	 ( 
	 [DistrictName]) 
 
VALUES 
	(@District)


select @@identity



