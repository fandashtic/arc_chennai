
CREATE PROCEDURE [sp_insert_Groups]
	(@GROUPNAME 	NVARCHAR (50),
	 @PERMISSION 	TEXT )
	 


AS INSERT INTO [Groups] 
	 ( GroupName,
	   permission)
 
VALUES 
	(@GROUPNAME,
	 @PERMISSION)
	 


