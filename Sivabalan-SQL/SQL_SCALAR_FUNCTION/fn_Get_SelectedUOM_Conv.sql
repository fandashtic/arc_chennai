Create Function [dbo].[fn_Get_SelectedUOM_Conv] (@ITEMCODE nvarchar(30), @SELECTED_UOM int = 0)
Returns Decimal(18, 6)
As
Begin

DECLARE @UOM1 int        
DECLARE @UOM2 int        
DECLARE @UOM3 int       

DECLARE @UOMConv Decimal(18,6)        
DECLARE @UOMConv1 Decimal(18,6)        
DECLARE @UOMConv2 Decimal(18,6)
Declare @Selected_Conv Decimal(18,6)

 Select  @UOM1 = IsNull(UOM,0), @UOM2 = IsNull(UOM1,0), @UOM3 = IsNull(UOM2,0),        
 @UOMConv = IsNull(UOM1_Conversion, 0), @UOMConv2 = IsNull(UOM2_Conversion, 0)        
 from items        
 Where Product_Code = @ITEMCODE        
 Select @Selected_Conv = Case @SELECTED_UOM When 0 Then 1        
      When @UOM1 Then 1        
      When @UOM2 Then @UOMConv        
      When @UOM3 Then @UOMConv2        
      Else 1 End        

Return IsNull(@Selected_Conv, 0)
End
