CREATE Function sp_Get_ReportingUOMQty(@ItemCode as nvarchar(200),@Quantity as Decimal(18,6))    
RETURNS Decimal(18,6) 
Begin    
    
	Declare @ReportingUOM as nvarchar(100)    
	Declare @ReportingUnit as Decimal(18,6)    
	Declare @ContUOM as nvarchar(3000)

	Set @ReportingUOM = (Select UOM.Description from Items, UOM Where Items.ReportingUOM = UOM.UOM and Items.Product_Code = @ItemCode)    
	Set @ReportingUnit = (Select ReportingUnit from Items Where Items.Product_Code = @ItemCode)    
	If Isnull(@ReportingUOM, N'') <> N'' and @Quantity <> 0    
	Begin    
		Set @ReportingUnit = Case Cast(@ReportingUnit as Decimal(18,6)) When 0 Then 1 Else @ReportingUnit End
	End    
	If @Quantity = 0    
		Select @ContUOM = N'0'    
	Else If Isnull(@ReportingUOM, N'') = N''     
		Select @ContUOM = @Quantity 
	Else    
		Select @ContUOM = Cast(@Quantity as decimal(18,6) ) / Cast( @ReportingUnit as decimal(18,6))

	If @ContUOM = N''   
		Set @ContUOM = @Quantity  
	Return @ContUOM    
End    

