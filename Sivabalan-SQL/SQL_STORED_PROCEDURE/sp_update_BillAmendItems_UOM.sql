CREATE procedure sp_update_BillAmendItems_UOM(@Bill_ID int,     
     @Product_Code as nvarchar(50),     
     @Qty Decimal(18,6),     
     @Price Decimal(18,6),     
     @Amount Decimal(18,6),    
     @TaxSuffered Decimal(18,6),     
     @TaxAmount Decimal(18,6),     
     @Taxcode int,    
     @Discount Decimal(18,6),    
     @Batch nvarchar(255),    
     @Expiry datetime,    
     @PKD datetime,    
     @PTS Decimal(18,6),    
     @PTR Decimal(18,6),    
     @ECP Decimal(18,6),    
     @SpecialPrice Decimal(18,6),    
     @UOMID Int,    
     @UOMQty Decimal(18,6),    
     @UOMPrice Decimal(18,6),  
     @ComboId int=-123,  
     @ExciseDuty Decimal(18,6) = 0,  
     @PurchasePriceBeforeExciseAmount Decimal(18,6) = 0,  
     @ExciseID Int = 0,  
     @VAT int =0,  
	  @Promotion int =0)    
as    

if(@ComboId=-123)  
insert into BillDetail (BillID, Product_Code, Quantity, PurchasePrice, Amount,    
TaxSuffered, TaxAmount, TaxCode, Discount, Batch, Expiry, PKD, PTS, PTR, ECP,     
SpecialPrice, UOM, UOMQty, UOMPrice, ExciseDuty,PurchasePriceBeforeExciseAmount,ExciseID,VAT,promotion)    
values (@Bill_ID, @Product_Code, @Qty, @Price, @Amount, @TaxSuffered, @TaxAmount, @TaxCode,    
@Discount, @Batch, @Expiry, @PKD, @PTS, @PTR, @ECP, @SpecialPrice, @UOMID, @UOMQty, @UOMPrice,  
@ExciseDuty, @PurchasePriceBeforeExciseAmount, @ExciseID,@VAT,@Promotion)    
else  
insert into BillDetail (BillID, Product_Code, Quantity, PurchasePrice, Amount,    
TaxSuffered, TaxAmount, TaxCode, Discount, Batch, Expiry, PKD, PTS, PTR, ECP,     
SpecialPrice, UOM, UOMQty, UOMPrice,ComboID, ExciseDuty,PurchasePriceBeforeExciseAmount,ExciseID,VAT,Promotion)    
values (@Bill_ID, @Product_Code, @Qty, @Price, @Amount, @TaxSuffered, @TaxAmount, @TaxCode,    
@Discount, @Batch, @Expiry, @PKD, @PTS, @PTR, @ECP, @SpecialPrice, @UOMID, @UOMQty, @UOMPrice,@ComboId,  
@ExciseDuty, @PurchasePriceBeforeExciseAmount, @ExciseID,@VAT,@Promotion)    



