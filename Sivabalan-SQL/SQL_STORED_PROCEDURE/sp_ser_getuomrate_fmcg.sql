CREATE Procedure sp_ser_getuomrate_fmcg(@ProductCode nvarchar(15),@UOM Int)
as

Declare @DefaultUOM Int,@UOM1 Int,@UOM2 Int
Declare @UOMConversion1 Int,@UOMConversion2 Int
Declare @UOMPrice Decimal(18,6),@Price Decimal(18,6)

select @Price = sale_price  from items where Product_code = @ProductCode

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

Select @UOMPrice


