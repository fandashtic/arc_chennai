Create Function Fn_GetVanLoadQty(@ProductCode nvarchar(30),@FromDate DateTime,@PriceFlag as Int) 
Returns Decimal(18,6)
As
Begin
Declare @Quantity decimal(18,6)
If @PriceFlag = 0 -- Total Remaining Qty on Van   
Begin  
  select @Quantity =  sum(Isnull(VD.Pending,0))   
  from VanStatementAbstract VA, VanStatementDetail VD  
  where VA.DocSerial = VD.DocSerial   
  and VD.Product_code = @ProductCode   
  and VA.DocumentDate < @FromDate   
  group by VD.Product_Code  
End  
Else If @PriceFlag = 1 -- Total Remaining Saleable Qty on Van
Begin
  select @Quantity =  sum(Isnull(VD.Pending,0))   
  from VanStatementAbstract VA, VanStatementDetail VD,Batch_Products BP  
  where VA.DocSerial = VD.DocSerial   
  and VD.Batch_Code = BP.Batch_Code
  and Isnull(Free,0) <> 1
  and VD.Product_code = @ProductCode   
  and VA.DocumentDate < @FromDate   
  group by VD.Product_Code 
End
Else If @PriceFlag = 2 -- Total Remaining Free Saleable Qty on Van
Begin
  select @Quantity =  sum(Isnull(VD.Pending,0))   
  from VanStatementAbstract VA, VanStatementDetail VD,Batch_Products BP   
  where VA.DocSerial = VD.DocSerial  
  and VD.Batch_Code = BP.Batch_Code 
  and Isnull(Free,0) = 1
  and VD.Product_code = @ProductCode   
  and VA.DocumentDate < @FromDate   
  group by VD.Product_Code 
End 
  Return Isnull(@Quantity,0)
End
