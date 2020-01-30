CREATE Procedure mERP_SP_isItemHavingTransaction @Product_Code nvarchar(1000)  
AS  
BEGIN  
 Declare @HavingTrans int  
 Set @HavingTrans = 0  
 -- *** IF @HavingTrans is 1 then Item Having Transaction. Dont Allow to Reimport  
 IF (Select Count(*) From GRNDetail Where Product_code= @Product_Code) <> 0  
 BEGIN  
  Set @HavingTrans = 1  
  Goto OverNOut  
 END  
 ELSE IF (Select Count(*) From BillDetail Where Product_code= @Product_Code) <> 0  
 BEGIN  
  Set @HavingTrans = 1  
  Goto OverNOut  
 END  
 ELSE IF (Select Count(*) From DispatchDetail Where Product_code= @Product_Code) <> 0  
 BEGIN  
  Set @HavingTrans = 1  
  Goto OverNOut  
 END  
 ELSE IF (Select Count(*) From InvoiceDetail Where Product_code= @Product_Code) <> 0  
 BEGIN  
  Set @HavingTrans = 1  
  Goto OverNOut  
 END  
 ELSE IF (Select Count(*) From StockTransferOutDetail Where Product_code= @Product_Code) <> 0  
 BEGIN  
  Set @HavingTrans = 1  
  Goto OverNOut  
 END  
 ELSE IF (Select Count(*) From StockTransferInDetail Where Product_code= @Product_Code) <> 0  
 BEGIN  
  Set @HavingTrans = 1  
  Goto OverNOut  
 END  
 ELSE IF (Select Count(*) From StockAdjustment Where Product_code= @Product_Code) <> 0  
 BEGIN  
  Set @HavingTrans = 1  
  Goto OverNOut  
 END  
 ELSE IF (Select Count(*) From AdjustmentReturnDetail Where Product_code= @Product_Code) <> 0  
 BEGIN  
  Set @HavingTrans = 1  
  Goto OverNOut  
 END  
 ELSE IF (Select Count(*) From StockDestructionDetail Where Product_code= @Product_Code) <> 0  
 BEGIN  
  Set @HavingTrans = 1  
  Goto OverNOut  
 END  
 ELSE IF (Select Count(*) From ConversionDetail Where Product_code= @Product_Code) <> 0  
 BEGIN  
  Set @HavingTrans = 1  
  Goto OverNOut  
 END  
 ELSE IF (Select Count(*) From ClaimsDetail Where Product_code= @Product_Code) <> 0  
 BEGIN  
  Set @HavingTrans = 1  
  Goto OverNOut  
 END  
 ELSE IF (Select Count(*) From VanStatementDetail Where Product_code= @Product_Code) <> 0  
 BEGIN  
  Set @HavingTrans = 1  
  Goto OverNOut  
 END  
OverNOut:  
 Select @HavingTrans  
END
