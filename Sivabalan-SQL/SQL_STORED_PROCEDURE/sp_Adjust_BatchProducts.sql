
CREATE procedure sp_Adjust_BatchProducts(@StockID integer, @ItemCode nvarchar(50), @BatchCode nvarchar(255), @BatchNumber nvarchar(255), @Qty Decimal(18,6),  @OldVal Decimal(18,6), @NewQty Decimal(18,6), @NewVal Decimal(18,6), @SaveAdjType Integer, 
@ReconcileDate DateTime, @Damage Int, @ActDamage Integer)   
As  
  
Declare @EXPIRY DateTime  
Declare @PTS Decimal(18,6)   
Declare @PTR Decimal(18,6)  
Declare @ECP Decimal(18,6)  
Declare @PKD_DATE DateTime   
Declare @GRN_ID Integer  
Declare @SalePrice Decimal(18,6)  
Declare @PurPrice Decimal(18,6)  
Declare @TAXSUFFERED Decimal(18,6)  
  
Update StockAdjustmentAbstract Set AdjustmentValue = AdjustmentValue +  (@NewVal - @OldVal) Where AdjustmentID = @StockID  
  
IF @ActDamage = 0    
INSERT INTO StockAdjustment (SerialNO, Product_Code, Batch_Code, Batch_Number,        
Quantity, Rate, ReasonID, OldQty, OldValue) VALUES (@StockID, @ItemCode,         
@BatchCode, @BatchNumber,        
@NewQty, @NewVal , 0, @Qty, @OldVal)        
  
IF @SaveAdjType = 4 And @Damage > 0      
  UPDATE Batch_Products SET Quantity = @NewQty,   
  ClaimedAlready = Case When IsNull(ClaimedAlready, 0) - (@Qty - @NewQty) >= 0      
  Then IsNull(ClaimedAlready, 0) - (@NewQty)    
  Else 0      
  End      
  where Batch_Code = @BatchCode      
  
IF @ActDamage = 1   
Begin  
 SELECT @EXPIRY = Expiry, @PurPrice = Purchaseprice, @SalePrice = SalePrice, @PTS = PTS, @PTR = PTR, @ECP = ECP, @PKD_DATE = PKD, @GRN_ID = GRN_ID, @TAXSUFFERED = TaxSuffered      
 FROM Batch_Products WHERE Batch_Code = @BatchCode      
  
 INSERT INTO Batch_Products(Batch_Number, Expiry, Product_Code, Quantity, PurchasePrice,       
 SalePrice, PTS, PTR, ECP, Damage, DamagesReason, PKD, GRN_ID, TaxSuffered,QuantityReceived)      
 Values(@BatchNumber, @EXPIRY, @ItemCode, @NewQty, @PurPrice,       
 @SalePrice, @PTS, @PTR, @ECP, 1, 0, @PKD_DATE, @GRN_ID, @TAXSUFFERED,@NewQty)      
  
 INSERT INTO StockAdjustment (SerialNO, Product_Code, Batch_Code, Batch_Number,      
 Quantity, Rate, ReasonID, OldQty, OldValue) VALUES (@StockID, @ItemCode, @@IDENTITY,       
 @BatchNumber, @NewQty, @NewVal, 0,  
 @Qty, @OldVal)      
End  
  
IF @SaveAdjType = 3  
  UPDATE Batch_Products SET Quantity = @NewQty where Batch_Code = @BatchCode   
    
