--EXEC SP_ADDPRIMARYKEY @TableName = 'Customer_Mappings', @ColumnName = 'CustomerID', @DataType = 'nvarchar(255)'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_ADDPRIMARYKEY')
BEGIN
    DROP PROC SP_ADDPRIMARYKEY
END
GO
Create Proc SP_ADDPRIMARYKEY(@TableName Nvarchar(255), @ColumnName Nvarchar(255), @DataType Nvarchar(255))  
AS  
BEGIN 
	DECLARE @SQL AS NVARCHAR(255) 
	SET @SQL = 'ALTER TABLE '+ @TableName + ' ALTER COLUMN '+ @ColumnName +' '+ @DataType +' NOT NULL'
	PRINT @SQL
	EXEC(@SQL)
	SET @SQL = 'ALTER TABLE '+ @TableName + ' ADD PRIMARY KEY ('+ @ColumnName +');'
	EXEC(@SQL)
	PRINT @SQL
END
GO
