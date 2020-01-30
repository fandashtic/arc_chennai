CREATE function sp_ser_GetTrueVal(@Input nvarchar(255)) 
returns int
as
begin
  declare @i as int
  declare @j as int
  declare @n as int

  set @n = Len(@Input)
  set @i = 1
  while @i <= @n
  begin
    set @j = ascii(substring(@Input, @i, 1))
    if @j > 47 and @j < 58 
    break
    set @i = @i + 1
    continue
  end
  return (cast(substring(@Input, @i, @n - @i + 1) as int))
end
/* 
	Copied from Erp Forum 
*/

