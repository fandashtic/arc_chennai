CREATE Procedure sp_Update_Pending_Request_MUOM (@StockRequestNo int,    
         @ProductCode nvarchar(20),    
         @Quantity Decimal(18,6),
		 @UOM Int) -- UnUsed
As  
Declare @Serial Int
Declare @Pending Int

Select @Serial = Min(Serial),@Pending = Sum(Pending) From Stock_Request_Detail_Received 
Where Product_Code = @ProductCode And
Stk_Req_Number = @StockRequestNo
Group by Product_Code
  
Update Stock_Request_Detail_Received Set ExcessQuantity = @Quantity - @Pending    
Where Stk_Req_Number = @StockRequestNo And Product_Code = @ProductCode And  
Serial = @Serial And @Quantity - @Pending > 0    

Update Stock_Request_Detail_Received Set Pending = 0 
Where Stk_Req_Number = @StockRequestNo And Product_Code = @ProductCode 
    
Update Stock_Request_Detail_Received Set Pending = @Pending - @Quantity    
Where Stk_Req_Number = @StockRequestNo And Serial = @Serial And Product_Code = @ProductCode    

Update Stock_Request_Detail_Received Set Pending = 0  
Where Stk_Req_Number = @StockRequestNo And Serial = @Serial And Product_Code = @ProductCode    
And  Pending < 0

    
  
  
  
  


