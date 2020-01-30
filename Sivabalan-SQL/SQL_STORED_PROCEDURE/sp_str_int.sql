
CREATE proc sp_str_int(@string nvarchar(255))
as
declare @pos int
declare @start int
set @start = 1
select @pos = charindex ( ',' , @string , @start)
while  @pos <> 0
begin
	select substring(@string, @start, (@pos - @start))
	set @start = @pos+1
	select @pos = charindex ( ',' , @string , @start)
	
	if @pos = 0
	break
end 

select substring(@string, @start, (len(@string) - @start)+1)



