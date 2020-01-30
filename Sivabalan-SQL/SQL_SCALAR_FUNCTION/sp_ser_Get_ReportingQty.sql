CREATE Function sp_ser_Get_ReportingQty(@Quantity Decimal(18,6), @ReportQty Decimal(18,6))  
RETURNS Decimal(18,6)   
Begin      
  
--Declare @ReportingUOM as nvarchar(100)      
Declare @ReportingUnit Decimal(18, 6)
Declare @ReportingQty as Int
Declare @RemQty as Int  
Declare @InQty Int  
Declare @ContUOM as nvarchar(3000)  
Declare @RepeatZero as nvarchar(10)      
--Set @ReportingUOM = (Select UOM.Description from Items, UOM Where Items.ReportingUOM = UOM.UOM and Items.Product_Code = @ItemCode)      
--Set @ReportingUnit = (Select ReportingUnit from Items Where Items.Product_Code = @ItemCode)      
If Isnull(@ReportQty, 0) <> 0 and @Quantity <> 0      
Begin      
Set @ReportingUnit = Case Cast(@ReportQty as Decimal(18,6)) When 0 Then 1 Else @ReportQty End  
Set @InQty = Cast(@Quantity as Decimal(18,6)) / cast(@ReportingUnit as Decimal(18,6))  
Set @RemQty =  Cast(@Quantity as Decimal(18,6)) - cast((@InQty * @ReportingUnit) as Decimal(18,6))       
Set @ReportingQty = Cast(@Quantity as Decimal(18,6))/@ReportingUnit       
Set @RepeatZero = Cast(Case When len(abs(@RemQty)) < len(Cast(@ReportingUnit As Int))  Then      
     Replicate(0,len(Cast(@ReportingUnit As Int))-Len(abs(@RemQty)))       
   Else N'' End as nvarchar)      
End      
If @Quantity = 0      
 Select @ContUOM = N'0'      
-- Else If Isnull(@ReportingUOM, '') = ''       
--  Select @ContUOM = @Quantity   
Else      
 if @Quantity < 0   
 Begin  
  if (@Quantity * -1) < @ReportingUnit  
    Set @ContUOM =  N'-' + Cast(@ReportingQty as nvarchar) + N'.' +  @RepeatZero          
    + Cast(@RemQty * -1 as nvarchar)                
  Else  
    Set @ContUOM = Cast(@ReportingQty as nvarchar) + N'.' +  @RepeatZero          
    + Cast(@RemQty * -1 as nvarchar)            
 End  
   Else  
   Select @ContUOM = Cast(@ReportingQty as nvarchar) + N'.' +   
                 @RepeatZero +  Cast(@RemQty as nvarchar)      
  
If @ContUOM = N''     
Set @ContUOM = @Quantity    
--Set @ContUOM = 5.05  
-- Set @ContUOM = Cast(@ReportingQty as nvarchar) + N'.' +   
--                   @RepeatZero +  Cast(@RemQty as nvarchar)  
Return @ContUOM      
End      




