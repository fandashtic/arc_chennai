
CREATE PROCEDURE [sp_insert_Country]
	( @Country_2 	[nvarchar](50))
	

AS INSERT INTO [Country] 
	( [Country])
	 
 
VALUES (
	 @Country_2)

Select @@identity

