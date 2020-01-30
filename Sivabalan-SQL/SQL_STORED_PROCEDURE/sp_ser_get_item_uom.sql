CREATE procedure [dbo].[sp_ser_get_item_uom] (@ITEMCODE varchar(30), @FUNCTION int = 0, @SELECTED_UOM int = 0, @RAW_QTY varchar(50) = '')      
AS
-- procedure based on sp_get_item_uom    
DECLARE @UOM Table(UOM int, Description varchar(128), UOMConv Decimal(18,6))      
DECLARE @UOM1 int      
DECLARE @UOM2 int      
DECLARE @UOM3 int      
DECLARE @UOMDefault int      
DECLARE @DefaultDesc varchar(128)      
DECLARE @UOMDesc1 varchar(128)      
DECLARE @UOMDesc2 varchar(128)      
DECLARE @UOMDesc3 varchar(128)      
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
 @UOMDesc1 = IsNull(a.Description,''), @UOMDesc2 = IsNull(b.Description,''), @UOMDesc3 = IsNull(c.Description,''),       
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
          Else 'Multiple' End)      
          Else (Case (IsNull(DefaultUOM,0) / 8) & 7 When 7 Then @UOMDesc1      
          When 0 Then @UOMDesc1      
          When 1 Then @UOMDesc2      
          When 2 Then @UOMDesc3      
          Else 'Multiple' End) End,      
 @UOMConv1 = IsNull(UOM1_Conversion, 0), @UOMConv2 = IsNull(UOM2_Conversion, 0)      
From Items, UOM a, UOM b, UOM c      
Where Product_Code = @ITEMCODE And Items.UOM *= a.UOM And Items.UOM1 *= b.UOM And Items.UOM2 *= c.UOM      
      
Insert @UOM Values(@UOMDefault, @DefaultDesc, @UOMConv)      
IF @UOM1 > 0      
 Insert @UOM Values(@UOM1, @UOMDesc1, 1)      
IF @UOM2 > 0      
 Insert @UOM Values(@UOM2, @UOMDesc2, @UOMConv1)      
IF @UOM3 > 0      
 Insert @UOM Values(@UOM3, @UOMDesc3, @UOMConv2)      
Select * From @UOM      
END      
ELSE IF @FUNCTION = 1      
BEGIN      
 select  @UOM1 = IsNull(UOM,0), @UOM2 = IsNull(UOM1,0), @UOM3 = IsNull(UOM2,0),      
  @UOMConv = IsNull(UOM1_Conversion, 0), @UOMConv2 = IsNull(UOM2_Conversion, 0)      
 from items      
 Where Product_Code = @ITEMCODE      
 Select Case @SELECTED_UOM When 0 Then 1      
      When @UOM1 Then 1      
      When @UOM2 Then @UOMConv      
      When @UOM3 Then @UOMConv2      
      Else 1 End      
END      
ELSE IF @FUNCTION = 2      
BEGIN      
 select  @UOM1 = IsNull(UOM,0), @UOM2 = IsNull(UOM1,0), @UOM3 = IsNull(UOM2,0)      
 from items      
 Where Product_Code = @ITEMCODE      
      
 IF @UOM1 = 0 or @UOM2 = 0 or @UOM3 = 0 Select 0 Else Select 1      
END      
ELSE IF @FUNCTION = 3      
BEGIN      
 select  @UOMConv1 = IsNull(UOM1_Conversion,0), @UOMConv2 = IsNull(UOM2_Conversion,0)      
 from items      
 Where Product_Code = @ITEMCODE      
      
 Set @i = charindex('*', @RAW_QTY)      
 Set @j = 0  
 If @i > 0   
Set @j = cast(substring(@RAW_QTY, 1, @i - 1) as Decimal(18,6))      
 Set @Total_Qty = @j * @UOMConv2      
 Set @k = Charindex('*', @RAW_QTY, @i+1)      
 IF @K <> 0      
 BEGIN      
  set @j = cast(substring(@RAW_QTY, @i+1, @k - (@i+1)) as Decimal(18,6))      
 Set @Total_Qty = @Total_Qty + @j * @UOMConv1 + cast(substring(@RAW_QTY, @k+1, 50) as Decimal(18,6))      
  Select @Total_Qty      
 END      
 ELSE      
 BEGIN      
  Set @Total_Qty = @j * @UOMConv1      
  set @j = cast(substring(@RAW_QTY, @i+1, 100) as Decimal(18,6))      
  Set @Total_Qty = @Total_Qty + @j      
  Select @Total_Qty      
 END      
END      
ELSE IF @FUNCTION = 4      
BEGIN      
 Select Case @SELECTED_UOM When 1 Then 1       
      When 2 Then IsNull(UOM1_Conversion, 0)      
      When 3 Then IsNull(UOM2_Conversion, 0)      
      End,      
        Case @SELECTED_UOM When 1 Then IsNull(UOM, 0)      
      When 2 Then IsNull(UOM1, 0)      
      When 3 Then IsNull(UOM2, 0)      
      End      
 From Items      
 Where Product_Code = @ITEMCODE      
END      
ELSE IF @FUNCTION = 6      
BEGIN      
 Select @UOMDesc1 = IsNull(a.Description,''), @UOMDesc2 = IsNull(b.Description,''), @UOMDesc3 = IsNull(c.Description,'')      
 From Items, UOM a, UOM b, UOM c      
 Where Product_Code = @ITEMCODE And Items.UOM *= a.UOM And Items.UOM1 *= b.UOM And Items.UOM2 *= c.UOM      
 Select '%1d ' + @UOMDesc3 + ' %2d ' + @UOMDesc2 + ' %3d ' + @UOMDesc1      
END      
ELSE IF @FUNCTION = 7      
BEGIN      
 select  @UOM1 = IsNull(UOM,0), @UOM2 = IsNull(UOM1,0), @UOM3 = IsNull(UOM2,0)      
 from items      
 Where Product_Code = @ITEMCODE      
      
 IF @UOM1 = 0 or @UOM2 = 0 Select 0 Else Select 1, @UOM3    
END
