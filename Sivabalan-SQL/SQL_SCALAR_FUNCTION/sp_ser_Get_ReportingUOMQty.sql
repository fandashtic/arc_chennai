CREATE Function sp_ser_Get_ReportingUOMQty(@ItemCode as varchar(200),@Quantity as Decimal(18,6))    
RETURNS Decimal(18,6) 
Begin    
    
Declare @ReportingUOM as varchar(100)    
Declare @ReportingUnit as integer    
Declare @ReportingQty Int
Declare @RemQty as Int
Declare @InQty Int
Declare @ContUOM as VarChar(3000)
Declare @RepeatZero as varchar(10)    
Set @ReportingUOM = (Select UOM.Description from Items, UOM Where Items.ReportingUOM = UOM.UOM and Items.Product_Code = @ItemCode)    
Set @ReportingUnit = (Select ReportingUnit from Items Where Items.Product_Code = @ItemCode)    
If Isnull(@ReportingUOM, '') <> '' and @Quantity <> 0    
Begin    
Set @ReportingUnit = Case Cast(@ReportingUnit as Decimal(18,6)) When 0 Then 1 Else @ReportingUnit End
Set @InQty = Cast(@Quantity as Decimal(18,6)) / cast(@ReportingUnit as Decimal(18,6))
Set @RemQty =  Cast(@Quantity as Decimal(18,6)) - cast((@InQty * @ReportingUnit) as Decimal(18,6))     
Set @ReportingQty = Cast(@Quantity as Decimal(18,6))/@ReportingUnit     
Set @RepeatZero = Cast(Case When len(@RemQty) < len(@ReportingUnit)  Then    
     Replicate(0,len(@ReportingUnit)-1)     
   Else '' End as Varchar)    
End    
If @Quantity = 0    
 Select @ContUOM = '0'    
Else If Isnull(@ReportingUOM, '') = ''     
 Select @ContUOM = @Quantity 
Else    
	if @Quantity < 0 
	Begin
		if (@Quantity * -1) < @ReportingUnit
		  Set @ContUOM =  '-' + Cast(@ReportingQty as varchar) + '.' +  @RepeatZero        
		  + Cast(@RemQty * -1 as Varchar)         					
		Else
		  Set @ContUOM = Cast(@ReportingQty as varchar) + '.' +  @RepeatZero        
		  + Cast(@RemQty * -1 as Varchar)          
	End
  	Else
		 Select @ContUOM = Cast(@ReportingQty as varchar) + '.' + 
                 @RepeatZero +  Cast(@RemQty as Varchar)    

If @ContUOM = ''   
Set @ContUOM = @Quantity  
--Set @ContUOM = 5.05
Return @ContUOM    
End    






