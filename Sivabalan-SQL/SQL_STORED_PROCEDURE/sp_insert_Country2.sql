
CREATE PROCEDURE [sp_insert_Country2]
	(@CountryID_1 	[int],
	 @Country_2 	[nvarchar](50),
	 @Active_3 	[int])

AS INSERT INTO [Country] 
	 ( [CountryID],
	 [Country],
	 [Active]) 
 
VALUES 
	( @CountryID_1,
	 @Country_2,
	 @Active_3)

