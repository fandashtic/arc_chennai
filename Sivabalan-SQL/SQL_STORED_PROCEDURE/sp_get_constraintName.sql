Create  procedure  sp_get_constraintName(@table_name nvarchar(256), @col_name nvarchar(256))
as
DECLARE @defname VARCHAR(100), @cmd VARCHAR(1000)

SET @defname = (SELECT name FROM sysobjects so JOIN sysconstraints sc ON so.id = sc.constid WHERE object_name(so.parent_obj) = @table_name AND so.xtype = 'D'
AND sc.colid =  (SELECT colid FROM syscolumns WHERE id = object_id(@table_name) AND name = @col_name))
SET @cmd = 'ALTER TABLE ' + @table_name + ' DROP CONSTRAINT ' + @defname
exec(@cmd)
