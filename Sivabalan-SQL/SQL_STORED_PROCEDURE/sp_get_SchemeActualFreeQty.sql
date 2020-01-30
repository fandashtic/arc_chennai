Create Procedure sp_get_SchemeActualFreeQty(@Item_Code nVarChar(15),@UOM int,@SchemeID int=0)
AS
Declare @FreeItem nVarChar(15)
if @UOM = 0 and @SchemeID > 0 
Begin
Select @FreeItem = Max(FreeItem) from SchemeItems where schemeID = @SchemeID
if Len(@FreeItem) > 0
Select @UOM = isNull(FreeUOM,0) from SchemeItems where schemeID=@SchemeID And FreeItem = @Item_Code
Else
Select @UOM = isNull(Max(FreeUOM),0) from SchemeItems where schemeID=@SchemeID
End

Select Case @UOM when 1 then UOM1_conversion when 2 then UOM2_Conversion else 1 end from Items
where Product_Code = @Item_Code
