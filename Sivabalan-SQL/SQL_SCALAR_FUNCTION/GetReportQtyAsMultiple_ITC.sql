
Create Function GetReportQtyAsMultiple_ITC (@ItemCode nvarchar(20), @Quantity decimal(18,6), @UOMLevel Int)                    
Returns nVarchar(128)                    
As                    
Begin                    
-- var to store the respective conversions                    
Declare @Conversion1 decimal(18,6)                     
Declare @Conversion2 decimal(18,6)                    
Declare @Conversion3 decimal(18,6)                    
Declare @Conversion1Qty decimal(18,6)                     
Declare @Conversion2Qty decimal(18,6)                    
Declare @Conversion3Qty decimal(18,6)                    
Declare @Conv3Desc nVarchar(100)    
Declare @Conv2Desc nVarchar(100)    
Declare @Conv1Desc nVarchar(100)    
Declare @result nvarchar(128)                    
Declare @IsNeg int                   
Declare @Found Int
Declare @OrgQty Decimal(18,6)    
Declare @Conv1Uom As Int  
Declare @Conv2Uom As Int  
Declare @Conv3Uom As Int  
Declare @Temp Decimal(18,6)


Set @Conversion1Qty = 0                  
Set @Conversion2Qty = 0                  
Set @Conversion3Qty = 0                  
      
if left(cast(@Quantity as nvarchar),1)='-'                      
Begin                      
    set @IsNeg=1                      
    set @Quantity=@Quantity*(-1)                      
End                       
Set @OrgQty = @Quantity    

Select  @Conversion1 = 1, @Conversion2 = IsNull(UOM1_Conversion, 0), @Conversion3 = IsNull(UOM2_Conversion, 0),  
@Conv1Uom = UOM, @Conv2Uom = UOM1, @Conv3Uom = UOM2                                                      
From Items Where Product_Code = @ItemCode  
                      

If @Conversion2 >= @Conversion3 
begin
Set @Temp = @Conversion3
Set @Conversion3 = @Conversion2
Set @Conversion2 = @Temp
Set @Found = 1
end

If @Conversion3 <> 0 
Begin
if @Quantity / @Conversion3 >= 1  
Begin  
	Set @Conversion3Qty = Cast((@Quantity / @Conversion3) As Int)
	Set @Quantity = @Quantity - (@Conversion3Qty * @Conversion3) 
End  
End

If @Conversion2 <> 0 
Begin 
if @Quantity / @Conversion2 >= 1  
Begin  
	Set @Conversion2Qty = Cast((@Quantity / @Conversion2) As Decimal(18,6))
	Set @Quantity = @Quantity - (@Conversion2Qty * @Conversion2) 
End  
Else
	Set @Conversion2Qty = Cast(@Quantity As Decimal(18,6))
End

Set @Conversion1Qty = @OrgQty  


If @Found = 1 
Begin
     Select @Conv3Desc = Description From UOM Where UOM = @Conv2Uom  
     Select @Conv2Desc = Description From UOM Where UOM = @Conv3Uom  
End
Else
Begin
     Select @Conv3Desc = Description From UOM Where UOM = @Conv3Uom  
     Select @Conv2Desc = Description From UOM Where UOM = @Conv2Uom  
End

Select @Conv1Desc = Description From UOM Where UOM = @Conv1Uom  
   
If @UomLevel =  3     
 Set @result =  Cast (Cast(@Conversion3Qty As Decimal(18,6)) As nVarchar) + ',' + Cast (@Conv3Desc As nVarchar)        
Else If @UomLevel = 2     
 Set @result =  Cast (Cast(@Conversion2Qty as Decimal(18,6)) as nvarchar) + ',' + Cast (@Conv2Desc As nVarchar)        
Else If @UomLevel = 1     
 Set @result =  Cast (Cast(@Conversion1Qty as Decimal(18,6)) as nvarchar) + ',' + Cast (@Conv1Desc As nVarchar)        
      
      
if @IsNeg=1                       
set @result='-' + @result                   
Return @result                     
          
End  

      
