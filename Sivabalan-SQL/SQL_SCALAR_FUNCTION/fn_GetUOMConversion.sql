CREATE Function fn_GetUOMConversion(@Product_Code nvarchar(15),@Type int)
returns decimal(18,6)
as 
begin
declare @UOMConv as decimal(18,6)
if @Product_Code <> N''
begin
	if @Type = 1 --Sales UOM Conversion
	begin
		select @UOMConv = (Case IsNull(DefaultUOM,0) & 7 When 7 Then 1        
	          When 0 Then 1        
	          When 1 Then UOM1_Conversion        
	          When 2 Then UOM2_Conversion        
	          Else 1 End) from items where product_Code = @Product_Code
	end
	else if @Type = 2 --Purchase UOM Conversion
	begin
		select  @UOMConv = (Case (IsNull(DefaultUOM,0) / 8) & 7 When 7 Then 1        
	          When 0 Then 1        
	          When 1 Then UOM1_Conversion        
	          When 2 Then UOM2_Conversion        
	          Else 1 End) from items where product_Code = @Product_Code
	end
	else if @Type = 3 --Price at UOM Conversion
	begin
		select  @UOMConv = (case PriceatUOMLevel        
	          When 1 Then UOM1_Conversion        
	          When 2 Then UOM2_Conversion        
	          Else 1 End) from items where product_Code = @Product_Code
	end
end
else
	set @UOMConv = 1

return @UOMConv
end

