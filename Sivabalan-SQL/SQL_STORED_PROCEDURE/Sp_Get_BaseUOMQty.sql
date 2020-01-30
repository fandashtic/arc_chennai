Create procedure Sp_Get_BaseUOMQty @Product_code nvarchar(30), @UOM int, @Qty Decimal(18,6)
AS
Begin	
	DECLARE @UOM1 int        
	DECLARE @UOM2 int   
	DECLARE @UOMConv1 Decimal(18,6)        
	DECLARE @UOMConv2 Decimal(18,6) 
	Select @UOM1 = IsNull(Items.UOM1,0),@UOMConv1=Items.UOM1_Conversion, @UOM2 = IsNull(Items.UOM2,0),@UOMConv2=Items.UOM2_Conversion From items where Product_code=@Product_code
	Select cast(@Qty *
	(Select case @UOM when @UOM1 then @UOMConv1 when @UOM2 then @UOMConv2 else 1 end) as decimal(18,6)) 
End
