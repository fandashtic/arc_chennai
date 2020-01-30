CREATE procedure sp_update_BillAmend(@Old_Bill int, @Vendor_ID nvarchar(15),  
@BillDate datetime, @UserName nvarchar(50), @Value Decimal(18,6), @TaxAmount Decimal(18,6),   
@AdjustmentAmount Decimal(18,6), @Discount Decimal(18,6), @DiscountOption int,  
@Inv_No as nvarchar(50), @CreditTerm int, @PaymentDate DateTime,@Flags int=0, @TaxOnMRP INT = NULL, @AdjustmentValue Decimal(18,6) = 0,
@ExciseDuty Decimal(18,6) = 0,@ED int = 0,@PPBED int = 0)  
as  
declare @GRN_ID as int  
declare @NewGRN_ID as int  
--declare @Inv_No as nvarchar(50)  
declare @Bill_No as int  
declare @OldDocID as int  
DECLARE @DocumentID as int  
declare @TotalAmount as Decimal(18,6)  
Declare @PaymentID Int  
SELECT @DocumentID = DocumentID FROM Billabstract where BillId=@Old_Bill
set @TotalAmount = @Value + @TaxAmount + @AdjustmentAmount  
select  @GRN_ID = GRNID , --@Inv_No = InvoiceReference,   
 @OldDocID = DocumentID,  
 @NewGRN_ID = NewGRNID,  
 @PaymentID = PaymentID  
from BillAbstract  where BillID = @Old_Bill  
  
insert into BillAbstract (GRNID, BillDate, VendorID, UserName, Value,   
CreationTime, Status, InvoiceReference, BillReference, NewGRNID,   
DocumentReference, DocumentID, TaxAmount, AdjustmentAmount, Balance,  
Discount, DiscountOption, CreditTerm, PaymentDate,Flags, TaxOnMRP,  AdjustmentValue,
ExciseDuty, DiscountBeforeExcise, PurchasePriceBeforeExcise) values  
(@GRN_ID, @BillDate, @Vendor_ID, @UserName, @Value, GetDate(), 0, @Inv_No,   
@Old_Bill, @NewGRN_ID, @OldDocID, @DocumentID, @TaxAmount, @AdjustmentAmount,   
@TotalAmount, @Discount, @DiscountOption,  @CreditTerm , @PaymentDate,@Flags,@TaxOnMRP, 
@AdjustmentValue,@ExciseDuty, @ED, @PPBED)  
  
select @Bill_No = @@IDENTITY  
  
If @PaymentID Is Not Null 
Begin
exec dbo.sp_Cancel_Payment @PaymentID  
exec dbo.sp_ChangeStatus_AdjRef_BillAmend @Old_Bill
End
update BillAbstract set Status = Status | 128, Balance = 0 where BillID = @Old_Bill  
  
update GRNAbstract set BillID = @Bill_No, NewBillID = @DocumentID where GRNID =  @GRN_ID  
  
select @Bill_No, @DocumentID  
  
UPDATE Batch_Products SET TaxOnMRP = @TaxOnMRP WHERE Grn_ID = @GRN_ID  


