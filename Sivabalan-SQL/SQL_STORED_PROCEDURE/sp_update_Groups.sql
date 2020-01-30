
CREATE PROCEDURE [sp_update_Groups]
	(@GROUPNAME 	NVARCHAR (50),
	 @PERMISSION 	TEXT)

AS UPDATE [Groups] 

SET      Permission	 = @Permission

WHERE 
	 GroupName	 = @GROUPNAME


