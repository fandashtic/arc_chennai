
Create Function Fn_GetVanQty (@ProductCode nvarchar(30),@Batch_Code Int,@PriceFlag as Int) 
Returns Decimal(18,6)
As
Begin
Declare @Quantity decimal(18,6)
If @PriceFlag = 0 -- Total Remaining Qty on Van   
Begin  
  select @Quantity =  sum(Isnull(VD.Pending,0))   
  from VanStatementAbstract VA, VanStatementDetail VD, Batch_Products BP  
  where VA.DocSerial = VD.DocSerial   
  and VD.Product_code = @ProductCode   
  And VD.Product_Code = BP.Product_Code
  And VD.Batch_Code = BP.Batch_Code
  And BP.Batch_Code = @Batch_Code
  group by VD.Product_Code  
End  
Else If @PriceFlag = 1 -- Total Remaining Saleable Qty on Van
Begin
  select @Quantity =  sum(Isnull(VD.Pending,0))   
  from VanStatementAbstract VA, VanStatementDetail VD,Batch_Products BP  
  where VA.DocSerial = VD.DocSerial   
  and VD.Batch_Code = BP.Batch_Code
  and Isnull(Free,0) <> 1 And Isnull(Damage,0) = 0
  and VD.Product_code = @ProductCode   
  And VD.Product_Code = BP.Product_Code
  And VD.Batch_Code = BP.Batch_Code
  And BP.Batch_Code = @Batch_Code
  group by VD.Product_Code 
End
Else If @PriceFlag = 2 -- Total Remaining Free Saleable Qty on Van
Begin
  select @Quantity =  sum(Isnull(VD.Pending,0))   
  from VanStatementAbstract VA, VanStatementDetail VD,Batch_Products BP   
  where VA.DocSerial = VD.DocSerial  
  and VD.Batch_Code = BP.Batch_Code 
  and Isnull(Free,0) = 1 And IsNull(Damage,0) <> 1
  and VD.Product_code = @ProductCode   
  And VD.Product_Code = BP.Product_Code
  And VD.Batch_Code = BP.Batch_Code
  And BP.Batch_Code = @Batch_Code  
  group by VD.Product_Code 
End 
  Return Isnull(@Quantity,0)
End
