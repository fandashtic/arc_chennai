CREATE Function GetLastLevelUOMQty (@ItemCode nvarchar(20), @Quantity Decimal(18,6))          
Returns Decimal(18,6)      
As          
Begin          
-- var to store the respective conversions          
Declare @Conversion2 Decimal(18,6)  
Declare @Conversion3 Decimal(18,6)  
Declare @Conversion2Qty Int      
Declare @Conversion3Qty Int      
Declare @Conversion2_R_Qty Decimal(18,6)      
Declare @Conversion3_R_Qty Decimal(18,6)      

Select  @Conversion2 = IsNull(UOM1_Conversion, 0), @Conversion3 = IsNull(UOM2_Conversion, 0) From Items Where Product_Code = @ItemCode          
-- to chk if there is UOM3          
if @Conversion3 <> 0 -- if there is UOM3          
begin       
if @Conversion3 > @Conversion2
begin   
   Set @Conversion3Qty = @Quantity / @Conversion3 -- to get the converted UOM3 qty      
   Set @Conversion3_R_Qty = @Quantity -(@Conversion3Qty*@Conversion3) -- to get the remaining qty after convering uom3      
   If @Conversion2 <> 0 -- if there is UOM2          
   Begin
      Set @Conversion2Qty = @Conversion3_R_Qty / @Conversion2       
      Set @Conversion2_R_Qty = @Conversion3_R_Qty -(@Conversion2Qty*@Conversion2)-- to get the remaining qty after convering uom2          
   End
end
else
begin
   Set @Conversion3Qty = @Quantity / @Conversion2 -- to get the converted UOM3 qty      
   Set @Conversion3_R_Qty = @Quantity -(@Conversion3Qty*@Conversion2) -- to get the remaining qty after convering uom3      

   Set @Conversion2Qty = @Conversion3_R_Qty / @Conversion3       
   Set @Conversion2_R_Qty = @Conversion3_R_Qty -(@Conversion2Qty*@Conversion3)-- to get the remaining qty after convering uom2          
end
end  
else -- if no UOM3          
begin          
 set @Conversion3_R_Qty =  @Quantity      
  -- now to chk if there is UOM2          
 if @Conversion2 <> 0 -- if there is UOM2          
 begin        
   Set @Conversion2Qty = @Conversion3_R_Qty / @Conversion2       
   Set @Conversion2_R_Qty = @Conversion3_R_Qty -(@Conversion2Qty*@Conversion2)-- to get the remaining qty after convering uom2          
 end          
 else -- if no UOM2          
 begin          
  set @Conversion2_R_Qty =  @Conversion3_R_Qty      
 end          
end          
-- now for UOM1          
Return @Conversion2_R_Qty          
end          

    
    
    
  
  


