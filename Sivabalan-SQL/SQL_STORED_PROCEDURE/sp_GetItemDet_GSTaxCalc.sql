CREATE PROCEDURE sp_GetItemDet_GSTaxCalc(@ItemCode nVarChar(15))
As
Begin
	Select MRP, UOM1_Conversion, UOM2_Conversion From Items  Where Product_Code = @ItemCode
End
