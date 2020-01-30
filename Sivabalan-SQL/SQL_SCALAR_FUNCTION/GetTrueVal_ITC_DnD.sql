Create Function GetTrueVal_ITC_DnD(@Input nvarchar(255))   
returns Bigint  
as  
begin  
  declare @i as int  
  declare @j as int  
  declare @n as int  
  declare @result as nvarchar(255)
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
  Set @result=substring(@Input, @i, @n - @i + 1)
  If isnumeric(@result) = 0
	Set @result='0'
  Return cast( cast(@result as decimal) as Bigint)
End  
