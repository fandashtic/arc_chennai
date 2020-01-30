Create Procedure mERP_sp_TableShrink (@TableName nVarChar(128))
As
Declare @columnname nvarchar(128)
Declare @SQL nvarchar(4000)
Declare @Allcolumnnames nvarchar(4000)
Declare @identityflag int

Set   @SQL = 'alter table [' + @TableName + '] nocheck constraint all'
Exec (@SQL) -- disable all constraints
Set   @SQL = 'select * into tempdb..temptable from [' + @tablename + ']'
Exec (@SQL) -- copy all data to a temp table
Set   @SQL = 'truncate table [' + @tablename + ']'
Exec (@SQL) -- truncate all data from original table

If Exists(Select [Name] From SysColumns where [ID] = Object_ID(@TableName) And IsNull(Columnproperty([id],[name],'IsIdentity'),0) = 1)
Set @identityflag = 1

If @identityflag = 1
Begin
Set @SQL = 'set identity_insert [' + @tablename + '] on' + char(13) + char(10)
Set @SQL = @SQL + 'insert into [' + @tablename + ']('
End
Else
Begin
Set @SQL = 'insert into [' + @tablename + ']('
End

Set @Allcolumnnames = ''

Declare enumcolumns cursor for
Select [Name] from syscolumns where id = object_id(@tablename)

Open enumcolumns
Fetch From enumcolumns into @columnname
While @@fetch_status = 0
Begin
Set @Allcolumnnames = @Allcolumnnames + '[' + @columnname + '],'
Set @SQL = @SQL + '[' + @columnname + '], '
Fetch Next From enumcolumns into @columnname
End
Close enumcolumns
DeAllocate enumcolumns
Set @SQL = substring(@SQL, 1, len(@SQL) - 1) + ')' + char(13) + char(10) + 'select ' + substring(@Allcolumnnames, 1, len(@Allcolumnnames) - 1) + ' from tempdb..temptable'

If @identityflag = 1
Begin
Set @sql = @SQL + char(13) + char(10) + 'set identity_insert [' + @tablename + '] off'
Exec (@sql) -- copy data and disable identity insert
End
Else
Begin
Exec (@SQL) -- copy all the data back to original table from temp table
End
set @SQL = 'alter table [' + @tablename + '] check constraint all'
exec (@SQL) -- re-enable constraints
Drop table tempdb..temptable

