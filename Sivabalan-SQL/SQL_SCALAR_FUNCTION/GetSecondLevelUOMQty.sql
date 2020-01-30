CREATE Function GetSecondLevelUOMQty (@ItemCode nvarchar(20), @Quantity decimal(18,6))          
Returns decimal(18,6)          
As          
Begin          
-- var to store the respective conversions          
Declare @Conversion3 Decimal(18,6)          
Declare @Conversion3Qty Int          
Declare @Conversion3_R_Qty decimal(18,6)          
Declare @Conversion2 Decimal(18,6)      
Declare @Conversion2Qty Int      
Declare @Conversion2ConQty Decimal(18,6)    
Declare @Conversion3BalQty Decimal(18,6)
          
Select  @Conversion3 = IsNull(UOM2_Conversion, 0), @Conversion2 = IsNull(UOM1_Conversion,0)           
From Items Where Product_Code = @ItemCode          
-- to chk if there is UOM3          
If @Conversion3 <> 0 -- if there is UOM3          
Begin          
 Set @Conversion3Qty = @Quantity / @Conversion3      
    --Set @Conversion3_R_Qty = Cast(@Quantity As decimal(18,6)) % @Conversion3 -- to get the remaining qty after convering uom3          
 Set @Conversion3_R_Qty = @Quantity -(@Conversion3Qty*@Conversion3) -- to get the remaining qty after convering uom3          
End          
Else          
 Set @Conversion3_R_Qty = @Quantity          
If @Conversion2 <> 0   
--IF uom1 conv greater than uom2 conv then here the code is changed to calculate from uom2 first
-- otherwise the previous code by uom2 is calculated.
 If @Conversion2 > @Conversion3
	  Begin    
-- to convert UOM2 qty and assigned in a variable        
	   Set @Conversion2ConQty = @Conversion3_R_Qty / (Case @Conversion3 When 0 Then 1 Else @Conversion3 End)
-- to get the remaining qty after converting uom2     
	   Set @Conversion3BalQty = @Quantity - (Cast(@Conversion2ConQty as integer) * @Conversion3) 
-- Get the uom1 conversion Quantity.
	   Set @Conversion2Qty = @Conversion3BalQty / @Conversion2    
	  End     
 Else    
  Set @Conversion2Qty = @Conversion3_R_Qty / @Conversion2 -- to get the converted UOM2 qty          
Else          
 Set @Conversion2Qty = 0          
Return @Conversion2Qty          
End          
    
  


