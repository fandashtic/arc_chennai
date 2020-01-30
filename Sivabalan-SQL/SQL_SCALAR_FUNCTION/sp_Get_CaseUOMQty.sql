
Create Function sp_Get_CaseUOMQty
 (@ItemCode as nVarchar(200),  
  @Quantity as Decimal(18,6))        
RETURNS NVarchar(4000)
Begin        
Declare @UOMDese as nVarchar(100)        
Declare @CaseUOM as Decimal(18,6)        
Declare @CaseQty Int    
Declare @RemQty as Int    
Declare @InQty Int    
Declare @ContUOM as nVarChar(3000)    
Declare @RepeatZero as nVarchar(10)        
Declare @BaseUOM as NVarchar(255)

Set @BaseUOM = (Select UOM.Description from Items, UOM Where Items.UOM = UOM.UOM and Items.Product_Code = @ItemCode)          
Set @UOMDese = (Select UOM.Description from Items, UOM Where Items.Case_UOM = UOM.UOM and Items.Product_Code = @ItemCode)        
Set @CaseUOM = (Select Case_Conversion from Items Where Items.Product_Code = @ItemCode)        
  
If Isnull(@UOMDese, N'') <> N'' and @Quantity <> 0        
Begin        
 Set @CaseUOM = Case Cast(@CaseUOM as Decimal(18,6)) When 0 Then 1 Else @CaseUOM End 
 Set @InQty = Cast(@Quantity as Decimal(18,6)) / cast(@CaseUOM as Decimal(18,6))    
 Set @RemQty =  Cast(@Quantity as Decimal(18,6)) - cast((@InQty * @CaseUOM) as Decimal(18,6))         
 Set @CaseQty = Cast(@Quantity as Decimal(18,6))/@CaseUOM         
 Set @RepeatZero = Cast(Case When len(abs(@RemQty)) < len(Cast(@CaseUOM as Int))  
			Then Replicate(0,Len(Cast(@CaseUOM as Int))-Len(abs(@RemQty)))
   			Else N'' End as nVarchar)     
End

If @Quantity = 0        
 Select @ContUOM = N'0'        
Else If Isnull(@UOMDese, N'') = N''         
 Select @ContUOM = @Quantity     
Else If @Quantity < 0     
 Begin    
  If (@Quantity * -1) < @CaseUOM    
    Set @ContUOM =  N'-' + Cast(@CaseQty as nVarchar) + N' '+ @UOMDese + N'  ' +  @RepeatZero            
    + Cast(@RemQty * -1 as nVarchar) + N' ' + @BaseUOM                  
  Else    
    Set @ContUOM = Cast(@CaseQty as nVarchar) +  N' '+ @UOMDese + N'  ' +  @RepeatZero            
    + Cast(@RemQty * -1 as nVarchar) + N' ' + @BaseUOM                 
 End    
Else    
 Select @ContUOM = Cast(@CaseQty as nVarchar) +  N' '+ @UOMDese + N'  ' +  @RepeatZero 
    + Cast(@RemQty as nVarchar) + N' ' + @BaseUOM         
    
If @ContUOM = N''       
Set @ContUOM = @Quantity      
Return @ContUOM        
End 
  
  
