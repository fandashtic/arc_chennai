
CREATE PROCEDURE [sp_insert_Cash_Customer]
	(@CustomerID_1 	[int],
	 @CustomerName_2 	[nvarchar](50),
	 @Address_3 	[nvarchar](255))

AS INSERT INTO [Cash_Customer] 
	 ( [CustomerID],
	 [CustomerName],
	 [Address]) 
 
VALUES 
	( @CustomerID_1,
	 @CustomerName_2,
	 @Address_3)

