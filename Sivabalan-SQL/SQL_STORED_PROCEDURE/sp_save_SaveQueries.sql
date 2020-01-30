
CREATE PROCEDURE sp_save_SaveQueries(  @TABLE_ID INT,
			               @SQL_NAME NVARCHAR(50),
				       @SQL NVARCHAR(2048))

AS

UPDATE SavedQueries SET SQL = @SQL WHERE SQLName = @SQL_NAME 
AND TableID = @TABLE_ID

