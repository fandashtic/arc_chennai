
Create Procedure sp_get_Sales_item_uom (@ITEMCODE nvarchar(30), @FUNCTION int = 0)        
AS        
DECLARE @UOM Table(UOM int, Description nvarchar(128), UOMConv Decimal(18,6))        
DECLARE @UOM1 int        
DECLARE @UOM2 int        
DECLARE @UOM3 int        
DECLARE @UOMDefault int        
DECLARE @DefaultDesc nvarchar(128)        
DECLARE @UOMDesc1 nvarchar(128)        
DECLARE @UOMDesc2 nvarchar(128)        
DECLARE @UOMDesc3 nvarchar(128)        
DECLARE @UOMConv Decimal(18,6)        
DECLARE @UOMConv1 Decimal(18,6)        
DECLARE @UOMConv2 Decimal(18,6)        
DECLARE @i int        
DECLARE @j Decimal(18,6)        
DECLARE @k int        
DECLARE @Total_Qty Decimal(18,6)        
        
IF @FUNCTION = 0 Or @FUNCTION = 5        
BEGIN        
Select  @UOM1 = IsNull(Items.UOM,0), @UOM2 = IsNull(Items.UOM1,0), @UOM3 = IsNull(Items.UOM2,0),        
 @UOMDesc1 = IsNull(a.Description,N''), @UOMDesc2 = IsNull(b.Description,N''), @UOMDesc3 = IsNull(c.Description,N''),         
 @UOMDefault = Case @FUNCTION When 0 Then (Case IsNull(DefaultUOM,0) & 7 When 7 Then @UOM1        
          When 0 Then @UOM1        
          When 1 Then @UOM2        
          When 2 Then @UOM3        
          Else 0 End)        
         Else (Case (IsNull(DefaultUOM,0) / 8) & 7 When 7 Then @UOM1        
          When 0 Then @UOM1        
          When 1 Then @UOM2        
          When 2 Then @UOM3        
          Else 0 End) End,         
 @UOMConv = Case @FUNCTION When 0 Then (Case IsNull(DefaultUOM,0) & 7 When 7 Then 1        
          When 0 Then 1        
          When 1 Then UOM1_Conversion        
          When 2 Then UOM2_Conversion        
          Else 1 End)        
      Else (Case (IsNull(DefaultUOM,0) / 8) & 7 When 7 Then 1        
          When 0 Then 1        
          When 1 Then UOM1_Conversion        
          When 2 Then UOM2_Conversion        
          Else 1 End) End,         
 @DefaultDesc = Case @FUNCTION When 0 Then (Case IsNull(DefaultUOM,0) & 7 When 7 Then @UOMDesc1        
          When 0 Then @UOMDesc1        
          When 1 Then @UOMDesc2        
          When 2 Then @UOMDesc3        
          Else N'Multiple' End)        
          Else (Case (IsNull(DefaultUOM,0) / 8) & 7 When 7 Then @UOMDesc1        
          When 0 Then @UOMDesc1        
          When 1 Then @UOMDesc2        
          When 2 Then @UOMDesc3        
          Else N'Multiple' End) End,        
 @UOMConv1 = IsNull(UOM1_Conversion, 0), @UOMConv2 = IsNull(UOM2_Conversion, 0)        
From Items 
left outer join UOM a on  Items.UOM = a.UOM
left outer join UOM b on Items.UOM1 = b.UOM
left outer join UOM c on Items.UOM2 = c.UOM
Where Product_Code = @ITEMCODE           
        
Insert @UOM Values(@UOMDefault, @DefaultDesc, @UOMConv)        
--IF @UOM1 > 0        
-- Insert @UOM Values(@UOM1, @UOMDesc1, 1)        
--IF @UOM2 > 0        
-- Insert @UOM Values(@UOM2, @UOMDesc2, @UOMConv1)        
--IF @UOM3 > 0        
-- Insert @UOM Values(@UOM3, @UOMDesc3, @UOMConv2)        
Select @UOMConv        
END        

