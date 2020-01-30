CREATE PROCEDURE spUtil_ForumDB_ReIndex_UpdateStats
AS
DECLARE @MyTable VARCHAR(255)
DECLARE myCursor
CURSOR FOR
SELECT table_name
FROM information_schema.tables
WHERE table_type = 'base table'
OPEN myCursor
FETCH NEXT
FROM myCursor INTO @MyTable
WHILE @@FETCH_STATUS = 0
BEGIN
Print @MyTable
DBCC DBREINDEX(@MyTable, '', 80)
FETCH NEXT
FROM myCursor INTO @MyTable
END
CLOSE myCursor
DEALLOCATE myCursor
EXEC sp_updatestats
