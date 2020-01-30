
CREATE PROCEDURE sp_acc_execquery(@SQL nvarchar(4000), @Output int output)
AS
create Table #temp(result int null)

SET @SQL = N'insert into #temp ' + @SQL
exec sp_executesql @SQL
Select @Output = result from #temp
drop table #temp



