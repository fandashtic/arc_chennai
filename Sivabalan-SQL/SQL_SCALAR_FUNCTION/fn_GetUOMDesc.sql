Create Function fn_GetUOMDesc(@UOMID integer, @isCnv integer)
returns nvarchar(100)
as 
begin
declare @UOMdesc as nvarchar(100)
Set @UOMdesc=dbo.LookupDictionaryItem(N'No UOM',default)

if(@UOMID <> 0)
	begin
	    if (@isCnv <> 1)
	      Select @UOMdesc=Description from UOM where UOM=@UOMID
	    else
	      Select @UOMdesc=ConversionUnit from ConversionTable where ConversionID=@UOMID
	end
return (Select @UOMdesc )
end



