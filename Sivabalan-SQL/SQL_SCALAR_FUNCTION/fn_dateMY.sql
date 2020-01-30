create function fn_dateMY(@gDate datetime) 
returns nVarchar(7) 
as
Begin

declare @Month as nvarchar(2)
declare @Year as nvarchar(4)
declare @rDate as nvarchar(7)


if @gDate is null
	set @rdate =''
else
begin
	if len(month(@gDate))=1 
		set @Month = '0'+cast(month(@gDate) as nvarchar(2))
	else
		set @Month = cast(month(@gDate) as nvarchar(2))

	set @rDate = @Month  + cast('/' as nvarchar) + cast(Year(@gdate) as nvarchar(4))
end
return @rDate
End
