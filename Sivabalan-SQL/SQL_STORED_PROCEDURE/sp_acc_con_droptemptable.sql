

CREATE procedure sp_acc_con_droptemptable(@Table1 nVarchar(4000),@Table2 nVarchar(4000))
as
Declare @DynamicSQL nVarchar(4000)
Declare @Type nvarchar(10)
Set @Type =N'U'

Set @DynamicSQL = N'if exists(select [ID] from Tempdb..sysobjects where name =''' + @Table1 + ''' and xType = ''' + @Type + ''')' +
N' begin
	Drop Table Tempdb..' + @Table1 +
N' End'

Execute sp_executesql @DynamicSQL

Set @DynamicSQL = N'if exists(select [ID] from Tempdb..sysobjects where name =''' + @Table2 + ''' and xType = ''' + @Type + ''')' +
N' begin
	Drop Table Tempdb..' + @Table2 +
N' End'

Execute sp_executesql @DynamicSQL


