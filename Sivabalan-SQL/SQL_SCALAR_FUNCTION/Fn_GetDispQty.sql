
Create Function Fn_GetDispQty(@ProductCode nvarchar(30),@Batch_Code Int ,@PriceFlag as Int)   
Returns Decimal(18,6)  
As  
Begin  
Declare @Quantity decimal(18,6)  
If @PriceFlag = 0 -- Total Remaining Qty on Dispatch     
Begin    
  select @Quantity =  sum(Isnull(DD.Quantity,0))     
  from DispatchAbstract DA, DispatchDetail DD, Batch_Products BP       
  where DA.DispatchID = DD.DispatchID
  And DD.Product_code = @ProductCode   
  And DD.Product_Code = BP.Product_Code
  And BP.Batch_Code = DD.Batch_Code
  And BP.Batch_Code = @Batch_Code
  And (DA.Status & 128) = 0
  group by DD.Product_Code    
End    
Else If @PriceFlag = 1 -- Total Remaining Saleable Qty on Dispatch  
Begin  
  select @Quantity =  sum(Isnull(DD.Quantity,0))     
  from DispatchAbstract DA, DispatchDetail DD, Batch_Products BP    
  where (DA.Status & 128) = 0
  And DD.Product_code = @ProductCode 
  And DA.DispatchID = DD.DispatchID
  And DD.Product_Code = BP.Product_Code
  And BP.Batch_Code = DD.Batch_Code
  And BP.Batch_Code = @Batch_Code
  And IsNull(BP.Free,0) <> 1  And IsNull(BP.Damage,0) = 0
  group by DD.Product_Code   
End  
Else If @PriceFlag = 2 -- Total Remaining Free Saleable Qty on Dispatch  
Begin  

  select @Quantity =  sum(Isnull(DD.Quantity,0))     
  from DispatchAbstract DA, DispatchDetail DD, Batch_Products BP    
  where (DA.Status & 128) = 0
  And DD.Product_code = @ProductCode 
  And DA.DispatchID = DD.DispatchID
  And DD.Product_Code = BP.Product_Code
  And BP.Batch_Code = DD.Batch_Code
  And BP.Batch_Code = @Batch_Code
  And IsNull(BP.Free,0) = 1 And IsNull(BP.Damage,0) <> 1
  group by DD.Product_Code   
End   
  Return Isnull(@Quantity,0)  
End  
