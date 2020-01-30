Create Function fn_GetQtyAsUOM1UOM2_ITC(@ItemCode nVarchar(20),@Quantity Decimal(18,6),@UOMLevel Int)
Returns Decimal(18,6)
As
Begin
-------------------------------------------------------------------------------
-- About This Function :                                                     --
-- First we get UOM1 and UOM2 conversions from items table for @ItemCode     --
-- This function gives UOM1 or UOM2 Converted quantity from Base quantity    --
--  for @UOMLevel based [ 1 - for UOM1 Conversion 2 - for UOM2 Conversion]   --
-- First we findout which one is biggest then calculat on that uom as whole  --
--  number , the remaining quantity converted to rest uom                    --
-------------------------------------------------------------------------------
Declare @UOM1_Conv Decimal(18,6)
Declare @UOM2_Conv Decimal(18,6)
Declare @UOM1Qty Decimal(18,6)
Declare @UOM2Qty Decimal(18,6)
Declare @Return Decimal(18,6)

Select @UOM1_Conv = UOM1_Conversion , @UOM2_Conv = UOM2_Conversion from Items 
Where Product_Code = @ItemCode

Set @UOM1_Conv = IsNull(@UOM1_Conv,0)
Set @UOM2_Conv = IsNull(@UOM2_Conv,0)

	if @UOM1_Conv > @UOM2_Conv
		Begin
			Set @UOM1Qty = Cast((@Quantity	/ Case @UOM1_Conv When 0 Then 1 Else @UOM1_Conv End) as Int)
			Set @UOM2Qty = Cast(((@Quantity - (@UOM1Qty*@UOM1_Conv)) / Case @UOM2_Conv When 0 Then 1 Else @UOM2_Conv End) as Decimal(18,6))
		End
	Else
		Begin
			Set @UOM2Qty = Cast((@Quantity	/ Case @UOM2_Conv When 0 Then 1 Else @UOM2_Conv End) as Int)
			Set @UOM1Qty = Cast(((@Quantity - (@UOM2Qty*@UOM2_Conv)) / Case @UOM1_Conv When 0 Then 1 Else @UOM1_Conv End) as Decimal(18,6))
		End

Set @Return = Case @UOMLevel when 1 Then @UOM1Qty When 2 Then @UOM2Qty Else @Quantity End
Return @Return
End
