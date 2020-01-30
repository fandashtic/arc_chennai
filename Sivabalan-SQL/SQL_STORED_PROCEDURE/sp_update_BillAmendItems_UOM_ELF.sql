CREATE procedure sp_update_BillAmendItems_UOM_ELF(@Bill_ID int,             
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
     @Promotion int =0,      
     @Surcharge Decimal(18,6) =0,  
     @PurchasePrice Decimal(18,6) =0               
)            
as            
    
Declare @GRNID int  
if(@ComboId=-123)          
insert into BillDetail (BillID, Product_Code, Quantity, PurchasePrice, Amount,            
TaxSuffered, TaxAmount, TaxCode, Discount, Batch, Expiry, PKD, PTS, PTR, ECP,             
SpecialPrice, UOM, UOMQty, UOMPrice, ExciseDuty,PurchasePriceBeforeExciseAmount,ExciseID,VAT,promotion,      
Surcharge)                      
values (@Bill_ID, @Product_Code, @Qty, @Price, @Amount, @TaxSuffered, @TaxAmount, @TaxCode,            
@Discount, @Batch, @Expiry, @PKD, @PTS, @PTR, @ECP, @SpecialPrice, @UOMID, @UOMQty, @UOMPrice,          
@ExciseDuty, @PurchasePriceBeforeExciseAmount, @ExciseID,@VAT,@Promotion,      
@Surcharge)                      
else          
insert into BillDetail (BillID, Product_Code, Quantity, PurchasePrice, Amount,            
TaxSuffered, TaxAmount, TaxCode, Discount, Batch, Expiry, PKD, PTS, PTR, ECP,             
SpecialPrice, UOM, UOMQty, UOMPrice,ComboID, ExciseDuty,PurchasePriceBeforeExciseAmount,ExciseID,VAT,Promotion)            
values (@Bill_ID, @Product_Code, @Qty, @Price, @Amount, @TaxSuffered, @TaxAmount, @TaxCode,            
@Discount, @Batch, @Expiry, @PKD, @PTS, @PTR, @ECP, @SpecialPrice, @UOMID, @UOMQty, @UOMPrice,@ComboId,          
@ExciseDuty, @PurchasePriceBeforeExciseAmount, @ExciseID,@VAT,@Promotion)            
Select @GRNID = GRNID from BillAbstract Where BillId=@Bill_ID        

--Purchase price is updated in amendment in elf for the particular item
Update Batch_Products Set PurchasePrice=@PurchasePrice  
Where GRN_ID=@GRNID AND Product_Code=@Product_Code   
And IsNull(Batch_Number,'')=IsNull(@Batch,'') And IsNull(Expiry,0)=IsNull(@Expiry,0) And IsNull(PKD,0)=IsNull(@PKD,0) AND Quantity > 0  
  
  


