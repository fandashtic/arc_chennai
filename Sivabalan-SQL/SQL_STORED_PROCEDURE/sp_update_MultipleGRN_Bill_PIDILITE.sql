CREATE procedure sp_update_MultipleGRN_Bill_PIDILITE(@GRN_ID varchar(50), @Bill_Date datetime,        
@Vendor_ID nvarchar(15), @User_Name nvarchar(50),        
@Value Decimal(18,6), @Inv_Ref nvarchar(50), @NewGRNID varchar(50), @TaxAmount Decimal(18,6),         
@AdjustmentAmount as Decimal(18,6), @Discount Decimal(18,6), @DiscountOption int,         
@CreditTerm Integer, @PaymentDate DateTime,@Flags int=0, @TaxOnMRP INT = NULL, @AdjustmentValue Decimal(18,6) = 0,    
@ExciseDuty Decimal(18,6) = 0,@ED int = 0,@PPBED int = 0,@VATTaxAmount Decimal(18,6)=0,@TotalAmount Decimal(18,6) = 0,
@OctroiAmount Decimal(18,6) = 0,@Freight Decimal(18,6) = 0,@AdditionalDiscountPer Decimal(18,6) = 0,
@AdditionalDiscountAmt Decimal(18,6) = 0,@ProductDiscount Decimal(18,6) = 0)    
As         
declare @BillNo int        
DECLARE @DocumentID int        
--DECLARE @TotalAmount Decimal(18,6)        
    
create table #Temp (grnid int)                  
Exec ('Insert Into #Temp Select GRNID FROm GrnAbstract Where GRNID in (' + @GRN_ID + ')')        
        
SELECT @DocumentID = DocumentID FROM DocumentNumbers WHERE DocType = 6        
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 6        
        
--SET @TotalAmount = @Value + @TaxAmount + @AdjustmentAmount        
insert into BillAbstract (GRNID, BillDate, VendorID, UserName,         
Value, CreationTime, Status, InvoiceReference, DocumentID, NewGRNID, TaxAmount,        
AdjustmentAmount, Balance, Discount, DiscountOption, AdjustedAmount, CreditTerm, PaymentDate,Flags, TaxOnMRP, AdjustmentValue,    
ExciseDuty, DiscountBeforeExcise, PurchasePriceBeforeExcise,VATTaxAmount,
OctroiAmount,Freight,AddlDiscountPercentage,AddlDiscountAmount,ProductDiscount)        
values (@GRN_ID, @Bill_Date,        
@Vendor_ID, @User_Name, @Value, GetDate(), 0, @Inv_Ref, @DocumentID, @NewGRNID, @TaxAmount,        
@AdjustmentAmount, @TotalAmount, @Discount, @DiscountOption, 0, @CreditTerm, @PaymentDate,@Flags, @TaxOnMRP, @AdjustmentValue,    
@ExciseDuty, @ED, @PPBED,@VATTaxAmount,
@OctroiAmount,@Freight,@AdditionalDiscountPer,@AdditionalDiscountAmt,@ProductDiscount)        
         
select @BillNo = @@IDENTITY        
        
update GRNAbstract set GRNStatus = GRNStatus | 128, BillID = @BillNo, NewBillID = @DocumentID         
where GRNID in (select grnid from #Temp)    
         
select @BillNo, @DocumentID        
        
UPDATE Batch_Products SET TaxOnMRP = @TaxOnMRP WHERE Grn_ID in (select grnid from #Temp)        
    
drop table #temp          

