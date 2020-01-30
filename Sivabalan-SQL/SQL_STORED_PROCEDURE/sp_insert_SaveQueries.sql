
CREATE PROCEDURE sp_insert_SaveQueries(@TABLE_ID INT,
				       @SQL_NAME NVARCHAR(50),
				       @SQL NVARCHAR(2048))

AS

INSERT INTO SavedQueries (TableID, SQLName, SQL) 
VALUES (@TABLE_ID, @SQL_NAME, @SQL)


