CREATE function sp_ser_getuomprice(@ProductCode nvarchar(15),@UOM Int,
@CustomerType Int)
Returns Decimal(18,6)
as
Begin
Declare @DefaultUOM Int,@UOM1 Int,@UOM2 Int
Declare @UOMConversion1 Decimal(18,6),@UOMConversion2 Decimal(18,6)
Declare @UOMPrice Decimal(18,6),@Price Decimal(18,6)

set @Price = dbo.sp_ser_getspareprice(@CustomerType,@ProductCode)

Select @DefaultUOM = UOM,@UOM1 = UOM1,@UOM2 = UOM2,
@UOMConversion1 = UOM1_Conversion,@UOMConversion2 = UOM2_Conversion
from Items Where Product_Code = @ProductCode

If @DefaultUOM = @UOM
Begin
	Set @UOMPrice = @Price * 1
End
Else If @UOM1 = @UOM
Begin
	Set @UOMPrice = @Price * @UOMConversion1
End
Else If @UOM2 = @UOM
Begin
	Set @UOMPrice = @Price * @UOMConversion2
End

return @UOMPrice
End






