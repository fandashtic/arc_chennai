Create Procedure sp_Get_UOMQuantity(@ItemCode nVarchar(255),@Quantity Decimal(18,6))    
As    
Begin    
    Declare @Uom1_qty as Decimal(18,6)  
	Declare @Uom2_qty as Decimal(18,6)  
--	Select @uom_conversion1 = UOM1_Conversion,@uom_conversion2 = UOM2_Conversion From Items Where Product_Code = @ItemCode  
--	select dbo.sp_Get_ReportingQty(@Quantity,@uom_conversion1),dbo.sp_Get_ReportingQty(@Quantity,@uom_conversion2)  
	if @Quantity <>0 
		Select @Uom1_qty = @Quantity/(Case IsNull(UOM1_Conversion,0) When 0 Then 1 Else IsNull(UOM1_Conversion,1) End),@Uom2_qty = @Quantity /(Case IsNull(UOM2_Conversion,0) When 0 Then 1 Else isNull(UOM2_Conversion,1) End ) From Items Where Product_Code = @ItemCode    
	Select Cast(IsNull(@Uom1_qty,0) as Decimal(18,6)),Cast(IsNull(@Uom2_qty,0) as Decimal (18,6))
End    
  
