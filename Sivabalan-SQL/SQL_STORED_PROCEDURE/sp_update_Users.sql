
CREATE PROCEDURE [sp_update_Users]
	(@USERNAME  	NVARCHAR (50),
	 @GROUPNAME 	NVARCHAR (50),
	 @PASSWORD 	nVARCHAR (50))

AS UPDATE [Users] 

SET     GroupName	 = @GROUPNAME,
	 Password	 = @Password 

WHERE 
	 USERNAME	 = @USERNAME


