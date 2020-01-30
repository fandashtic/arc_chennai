
CREATE PROCEDURE [sp_insert_Users]
	(@USERNAME 	[nvarchar](50),
	 @GROUPNAME 	[nvarchar](50),
	 @PASSWORD	[nvarchar] (50))


AS INSERT INTO [Users] 
	 ( UserName,
	   GroupName,
	   password)
 
VALUES 
	(@USERNAME,
	 @GROUPNAME,
	 @PASSWORD)





