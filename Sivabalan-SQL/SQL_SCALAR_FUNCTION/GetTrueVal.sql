Create Function GetTrueVal(@Input nvarchar(255))   
returns BigInt  
as  
begin  
  declare @i as BigInt
  declare @j as BigInt
  declare @n as BigInt
  declare @result as nvarchar(255)
Start:
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
  if IsNumeric(@result) = 0 And Len(@result) > 0
	Begin	
			Set @Input = Right(@result, Len(@result)-1)
			Goto Start
	End
if isnumeric(@result) = 0  
Set @result='0'  
  return cast( cast(@result as decimal) as BigInt)


end    
