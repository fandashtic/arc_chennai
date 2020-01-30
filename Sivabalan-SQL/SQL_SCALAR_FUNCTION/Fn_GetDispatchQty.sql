
Create Function Fn_GetDispatchQty(@ProductCode nvarchar(30),@FromDate DateTime,@PriceFlag as Int)   
Returns Decimal(18,6)  
As  
Begin  
Declare @Quantity decimal(18,6)  
If @PriceFlag = 0 -- Total Remaining Qty on Dispatch     
Begin    
  select @Quantity =  sum(Isnull(DD.Quantity,0))     
  from DispatchAbstract DA, DispatchDetail DD    
  where DA.DispatchID = DD.DispatchID
  And DD.Product_code = @ProductCode     
  And DA.DispatchDate < @FromDate  
  And (DA.Status & 128) = 0
  group by DD.Product_Code    
End    
Else If @PriceFlag = 1 -- Total Remaining Saleable Qty on Dispatch  
Begin  
  select @Quantity =  sum(Isnull(DD.Quantity,0))     
  from DispatchAbstract DA, DispatchDetail DD, Batch_Products BP    
  where DA.DispatchID = DD.DispatchID
  And DD.Product_code = @ProductCode 
  And DD.Product_Code = BP.Product_Code
  And DD.Batch_Code = BP.Batch_Code
  And IsNull(Free,0) <> 1    
  And DA.DispatchDate < @FromDate  
  And (DA.Status & 128) = 0
  group by DD.Product_Code   
End  
Else If @PriceFlag = 2 -- Total Remaining Free Saleable Qty on Dispatch  
Begin  

  select @Quantity =  sum(Isnull(DD.Quantity,0))     
  from DispatchAbstract DA, DispatchDetail DD, Batch_Products BP    
  where DA.DispatchID = DD.DispatchID
  And DD.Product_code = @ProductCode 
  And DD.Product_Code = BP.Product_Code
  And DD.Batch_Code = BP.Batch_Code
  And IsNull(Free,0) = 1   
  And DA.DispatchDate < @FromDate  
  And (DA.Status & 128) = 0
  group by DD.Product_Code  
End   
  Return Isnull(@Quantity,0)  
End  
