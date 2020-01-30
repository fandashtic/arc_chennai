
CREATE function sp_get_item_uom_2_param (@ITEMCODE nvarchar(15), @SELECTED_UOM int = 0)  
returns Decimal(18,6)  
AS  
begin  
--DECLARE @UOM Table(UOM int, Description nvarchar(128), UOMConv int)  
  
DECLARE @UOM1 int  
DECLARE @UOM2 int  
DECLARE @UOM3 int  
  
DECLARE @UOMConv int  
DECLARE @UOMConv1 int  
DECLARE @UOMConv2 int  
  
--DECLARE @Total_Qty Decimal(18,6)  
declare @Res Decimal(18,6)  
  
 select  @UOM1 = IsNull(UOM,0), @UOM2 = IsNull(UOM1,0), @UOM3 = IsNull(UOM2,0),  
  @UOMConv = IsNull(UOM1_Conversion, 0), @UOMConv2 = IsNull(UOM2_Conversion, 0)  
 from items  
 Where Product_Code = @ITEMCODE  
 Select @Res = Case @SELECTED_UOM When 0 Then 1  
      When @UOM1 Then 1  
      When @UOM2 Then @UOMConv  
      When @UOM3 Then @UOMConv2  
      Else 1 End  
 return @Res   
END  
  


