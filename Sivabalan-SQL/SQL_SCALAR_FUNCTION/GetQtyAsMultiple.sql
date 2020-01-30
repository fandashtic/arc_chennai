
Create function GetQtyAsMultiple (@ItemCode nvarchar(20), @Quantity decimal(18,6))            
returns nvarchar(128)            
as            
Begin            
-- var to store the respective conversions                  
Declare @Conversion1 decimal(18,6)                   
Declare @Conversion2 decimal(18,6)                  
Declare @Conversion3 decimal(18,6)                  
Declare @Conversion1Qty decimal(18,6)                   
Declare @Conversion2Qty decimal(18,6)                  
Declare @Conversion3Qty decimal(18,6)                  
Declare @Temp Decimal(18,6)
Declare @result nvarchar(128)                  
Declare @Found Int
Declare @IsNeg int                 
      
Set @Conversion1Qty = 0                
Set @Conversion2Qty = 0                
Set @Conversion3Qty = 0                
Set @Found = 0
      
if left(cast(@Quantity as nvarchar),1)='-'                    
Begin                    
    set @IsNeg=1                    
    set @Quantity=@Quantity*(-1)                    
End                     
  
Select  @Conversion1 = 1, @Conversion2 = IsNull(UOM1_Conversion, 0), @Conversion3 = IsNull(UOM2_Conversion, 0)                 
From Items Where Product_Code = @ItemCode                    

If @Conversion2 > @Conversion3 
begin
Set @Temp = @Conversion3
Set @Conversion3 = @Conversion2
Set @Conversion2 = @Temp
Set @Found = 1
end
  
if @Quantity / @Conversion3 >= 1  
Begin  
Set @Conversion3Qty = Cast((@Quantity / @Conversion3) As Int)
Set @Quantity = @Quantity - (@Conversion3Qty * @Conversion3)
End  
  
if @Quantity / @Conversion2 >= 1  
Begin  
Set @Conversion2Qty = Cast((@Quantity / @Conversion2) As Int)
Set @Quantity = @Quantity - (@Conversion2Qty * @Conversion2)
End  
  
Set @Conversion1Qty = @Quantity  

If @Found = 1 
Set @result =  Cast(IsNull(@Conversion2Qty,0) As NVarchar) + '*' + Cast(IsNull(@Conversion3Qty,0) As NVarchar) + '*' + Cast (IsNull(@Conversion1Qty,0) As NVarchar)    
Else  
Set @result =  Cast(IsNull(@Conversion3Qty,0) As NVarchar) + '*' + Cast(IsNull(@Conversion2Qty,0) As NVarchar) + '*' + Cast (IsNull(@Conversion1Qty,0) As NVarchar)    
  
if @IsNeg=1                     
set @result='-' + @result                 
Return @result    
End            
