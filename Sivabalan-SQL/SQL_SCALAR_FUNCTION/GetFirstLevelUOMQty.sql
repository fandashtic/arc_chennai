CREATE Function GetFirstLevelUOMQty (@ItemCode nvarchar(20), @Quantity Decimal(18,6))          
Returns Int         
As          
Begin          
-- var to store the respective conversions          
Declare @Conversion3 decimal(18,6)   
Declare @Conversion2 Decimal(18,6)   
Declare @Conversion3Qty Decimal(18,6)          
Declare @Conversion3BalQty Decimal(18,6)  
Declare @Conversion2Qty Decimal(18,6)               
  
Select  @Conversion3 = IsNull(UOM2_Conversion, 0),@Conversion2 = IsNull(UOM1_Conversion, 0) From Items           
Where Product_Code = @ItemCode          
-- to chk if there is UOM3          
If @Conversion3 <> 0 -- if there is UOM3    
--IF uom1 conv greater than uom2 conv then here the code is changed to calculate from uom1 first
-- otherwise the previous code by uom2 is calculated.
	 If @Conversion2 > @Conversion3 
		Begin        
-- to convert UOM1 qty and assigned in a variable        
			Set @Conversion2Qty = Cast(@Quantity As Decimal(18,6)) / @Conversion2 
-- to get the remaining qty after converting uom1          
			Set @Conversion3BalQty = @Quantity - (Cast(@Conversion2Qty as integer) * @Conversion2)
-- Get the uom2 conversion Quantity.
			Set @Conversion3Qty = @Conversion3BalQty / @Conversion3  
		End   
	 Else  
	 	Set @Conversion3Qty = Cast(@Quantity As Decimal(18,6)) / @Conversion3 -- to get the converted UOM3 qty          
Else          
	Set @Conversion3Qty = 0          
Return @Conversion3Qty          
End          
    
  



