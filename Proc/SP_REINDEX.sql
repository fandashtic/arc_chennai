IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'SP_REINDEX')
BEGIN
    DROP PROC SP_REINDEX
END
GO
CREATE PROCEDURE [dbo].SP_REINDEX (@FromDate DateTime, @ToDate DateTime)      
AS
BEGIN
 Declare @Table as Table (id Int Identity(1,1), TableName Nvarchar(255))
 insert into @Table(TableName)
 select name from sys.tables

 Declare @i int
 set @i  = 1
  Declare @sql nvarchar(max)
  Declare @TableName nvarchar(255)
 while (@i <= (select max(id) from @Table))
 begin
	set @TableName = (select top 1 TableName from @Table where id = @i)
	set @sql = 'ALTER INDEX ALL ON '+ @TableName +' REBUILD'
	Exec (@sql)
	DBCC DBREINDEX(@TableName, '', 80)
	set @i = @i + 1
 end
 END
 GO

