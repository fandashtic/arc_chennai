CREATE Procedure sp_get_SalesUomConversion(@Product_Code nVarchar(100), @UomId Int=0)
As
Declare @SalesUOM Decimal(18,6)  
If @UomId = 0
	Select @SalesUOM = (Case 
	IsNull(DefaultUOM,0) & 7 When 7 Then 1
	When 0 Then 1 
	When 1 Then UOM1_Conversion 
	When 2 Then UOM2_Conversion Else 1 End)        
	From Items Where Product_Code = @Product_Code  
Else
	Select @SalesUOM = (Case 
    When IsNull(UOM,0) = @UomID Then 1
    When IsNull(UOM1,0) = @UomID Then UOM1_Conversion 
    When IsNull(UOM2,0) = @UomID Then UOM2_Conversion 
	Else 1 End )
	From Items Where Product_Code = @Product_Code 

Select @SalesUOM

