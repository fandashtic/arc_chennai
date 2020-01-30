CREATE PROCEDURE spUtil_ReIndexSchemeTables_UpdateStats
AS
DECLARE @MyTable VARCHAR(255)
DECLARE myCursor
CURSOR FOR
SELECT table_name
FROM information_schema.tables
WHERE table_type IN('tbl_mERP_SchemeAbstract','tbl_mERP_SchemeSlabDetail','tbl_mERP_SchemeSubGroup','tbl_mERP_SchemeOutlet','tbl_mERP_SchemePayoutPeriod','ItemCategories','Items','SchemeProducts')
OPEN myCursor
FETCH NEXT
FROM myCursor INTO @MyTable
WHILE @@FETCH_STATUS = 0
BEGIN
		DBCC DBREINDEX(@MyTable, '', 80)
		FETCH NEXT
		FROM myCursor INTO @MyTable
END
CLOSE myCursor
DEALLOCATE myCursor
EXEC sp_updatestats
