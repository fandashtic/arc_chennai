CREATE procedure sp_update_Bill(@GRN_ID int, @Bill_Date datetime,  
@Vendor_ID nvarchar(15), @User_Name nvarchar(50),  
@Value Decimal(18,6), @Inv_Ref nvarchar(50), @NewGRNID int, @TaxAmount Decimal(18,6),   
@AdjustmentAmount as Decimal(18,6), @Discount Decimal(18,6), @DiscountOption int,   
@CreditTerm Integer, @PaymentDate DateTime,@Flags int=0, @TaxOnMRP INT = NULL, @AdjustmentValue Decimal(18,6) = 0,
@ExciseDuty Decimal(18,6) = 0,@ED int = 0,@PPBED int = 0) as   
declare @BillNo int  
DECLARE @DocumentID int  
DECLARE @TotalAmount Decimal(18,6)  
  
SELECT @DocumentID = DocumentID FROM DocumentNumbers WHERE DocType = 6  
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 6  
  
SET @TotalAmount = @Value + @TaxAmount + @AdjustmentAmount  
insert into BillAbstract (GRNID, BillDate, VendorID, UserName,   
Value, CreationTime, Status, InvoiceReference, DocumentID, NewGRNID, TaxAmount,  
AdjustmentAmount, Balance, Discount, DiscountOption, AdjustedAmount, CreditTerm, PaymentDate,Flags, TaxOnMRP, AdjustmentValue,
ExciseDuty, DiscountBeforeExcise, PurchasePriceBeforeExcise)  
values (@GRN_ID, @Bill_Date,  
@Vendor_ID, @User_Name, @Value, GetDate(), 0, @Inv_Ref, @DocumentID, @NewGRNID, @TaxAmount,  
@AdjustmentAmount, @TotalAmount, @Discount, @DiscountOption, 0, @CreditTerm, @PaymentDate,@Flags, @TaxOnMRP, @AdjustmentValue,
@ExciseDuty, @ED, @PPBED)   
select @BillNo = @@IDENTITY  
  
update GRNAbstract set GRNStatus = GRNStatus | 128, BillID = @BillNo, NewBillID = @DocumentID   
where GRNID = @GRN_ID  
   
select @BillNo, @DocumentID  
  
UPDATE Batch_Products SET TaxOnMRP = @TaxOnMRP WHERE Grn_ID = @GRN_ID  



