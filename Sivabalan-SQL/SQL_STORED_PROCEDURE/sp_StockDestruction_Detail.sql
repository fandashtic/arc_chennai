CREATE PROCEDURE sp_StockDestruction_Detail(    
@DocID Integer,    
@ProductCode nvarchar(20),    
@BatchCode Integer,    
@ClaimQty Decimal(18,6),    
@DestroyQty Decimal(18,6),
@OpeningDate Datetime = Null,
@BackDatedTransaction Integer = 0)    
    
AS    
DECLARE @Diff Decimal(18,6)
DECLARE @PurPrice Decimal(18,6)
DECLARE @FreeRow Int
DECLARE @Damage Int
    
Update Batch_Products set Quantity = case When (Quantity - @DestroyQty) < 0 Then 0 Else (Quantity - @DestroyQty) end, ClaimedAlready = (ClaimedAlready - @DestroyQty)   
where Batch_Code in (@BatchCode)    
    
Insert into  StockDestructionDetail(    
DocSerial,    
Product_Code,    
BatchCode,    
ClaimQuantity,    
DestroyQuantity)    
VALUES(    
@DocID,    
@ProductCode ,        
@BatchCode,      
@ClaimQty,    
@DestroyQty)    
  
IF @BackDatedTransaction = 1 and IsNull(@OpeningDate,0) <> 0
BEGIN  
SET @Diff = 0 - @DestroyQty  
Select @FreeRow=IsNull(Free,0), @Damage=IsNull(Damage,0), @PurPrice=IsNull(PurchasePrice,0) from Batch_Products where Batch_Code=@BatchCode
Exec sp_update_opening_stock @ProductCode, @OpeningDate, @Diff, @FreeRow, @PurPrice, @Damage  
END    


