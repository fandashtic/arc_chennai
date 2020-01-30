CREATE Procedure sp_Cancel_StockTransferOut_MUOM(@StockTfrID Int,          
      @Remarks nvarchar(255),          
      @CancelUser nvarchar(50))          
As          
Declare @ProductCode nVarchar(30)    
Declare @BatchCode Int          
Declare @Quantity Decimal(18,6)          
Declare @bStockRequest Decimal(18,6)          
Declare @StockRequestNo Int          
Declare @Serial Int        
       
Select @bStockRequest = Status & 1, @StockRequestNo = StockRequestNo           
From StockTransferOutAbstract Where DocSerial = @StockTfrID          
    
         
Declare RevertStocks Cursor Static For          
Select Product_Code,Batch_Code, Quantity From StockTransferOutDetail Where DocSerial = @StockTfrID          
          
Open RevertStocks          
          
Fetch From RevertStocks Into @ProductCode,@BatchCode, @Quantity          
While @@Fetch_Status = 0          
Begin          
 Update Batch_Products Set Quantity = Quantity + @Quantity           
 Where Batch_Code = @BatchCode          
 If @bStockRequest = 1          
 Begin          
 Select @Serial = Min(Serial) From Stock_Request_Detail_Received     
 Where Product_Code = @ProductCode And Stk_Req_Number = @StockRequestNo    
 Group by Product_Code    
 Update Stock_Request_Detail_Received       
 Set Pending = Pending + (@Quantity - IsNull(ExcessQuantity, 0)),ExcessQuantity = 0          
 Where Stk_Req_Number = @StockRequestNo And Product_Code = @ProductCode  And    
 Serial = @Serial           
 End          
 Fetch Next From RevertStocks Into @ProductCode,@BatchCode, @Quantity          
End          
If @bStockRequest = 1          
Begin          
 Update SRAbstractReceived Set Status = Status & (~128) Where          
 StockRequestNo = @StockRequestNo          
End          
Update StockTransferOutAbstract Set Status = IsNull(Status, 0) | 64,          
CancelRemarks = @Remarks, CancelUser = @CancelUser,CancellationDate=GETDATE()          
Where DocSerial = @StockTfrID          
Close RevertStocks          
DeAllocate RevertStocks  
