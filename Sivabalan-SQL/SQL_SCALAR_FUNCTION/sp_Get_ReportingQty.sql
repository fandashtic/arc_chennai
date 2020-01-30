CREATE Function sp_Get_ReportingQty(@Quantity Decimal(18,6), @ReportQty Decimal(18,6))    
RETURNS Decimal(18,6)     
Begin            
Declare @ContUOM as nvarchar(3000)    

Set @ContUOM = @Quantity / (Case @ReportQty when 0 then 1 else @ReportQty end)

Return @ContUOM        
End
