CREATE procedure sp_update_MultipleGRN_BillAmend_ELF(  
  @Old_Bill int,   
  @Vendor_ID nvarchar(15),        
  @BillDate datetime,   
  @UserName nvarchar(50),   
  @Value Decimal(18,6),   
  @TaxAmount Decimal(18,6),         
  @AdjustmentAmount Decimal(18,6),   
  @Discount Decimal(18,6),   
  @DiscountOption int,        
  @Inv_No as Varchar(50),   
  @CreditTerm int,   
  @PaymentDate DateTime,  
  @Flags int=0,     
  @TaxOnMRP INT = NULL,   
  @AdjustmentValue Decimal(18,6) = 0,    
  @ExciseDuty Decimal(18,6) = 0,  
  @ED int = 0,  
  @PPBED int = 0,  
  @VATTaxAmount Decimal(18,6)=0,  
  @TotalAmount Decimal(18,6)=0,
  @ProductDiscount Decimal(18,6) = 0,
  @Surcharge Decimal(18,6) = 0            
  )        
as        
Declare @GRN_ID as varchar(50)        
Declare @NewGRN_ID as varchar(50)        
Declare @Bill_No as int        
Declare @OldDocID as int        
Declare @DocumentID as int        
Declare @PaymentID Int        
    
SELECT @DocumentID = DocumentID FROM Billabstract where BillId=@Old_Bill      
Select  @GRN_ID = GRNID ,   
 @OldDocID = DocumentID,        
 @NewGRN_ID = NewGRNID,        
 @PaymentID = PaymentID        
From BillAbstract         
Where BillID = @Old_Bill        
    
Create Table #Temp (grnid Int)                  
Exec ('Insert Into #Temp Select GRNID FROm GrnAbstract Where GRNID in (' + @GRN_ID + ')')        
    
Insert into BillAbstract (GRNID, BillDate, VendorID, UserName, Value,         
CreationTime, Status, InvoiceReference, BillReference, NewGRNID,         
DocumentReference, DocumentID, TaxAmount, AdjustmentAmount, Balance,        
Discount, DiscountOption, CreditTerm, PaymentDate,Flags, TaxOnMRP, AdjustmentValue,    
ExciseDuty, DiscountBeforeExcise, PurchasePriceBeforeExcise,VATTaxAmount,
ProductDiscount, Surcharge)          
Values        
(@GRN_ID, @BillDate, @Vendor_ID, @UserName, @Value, GetDate(), 0, @Inv_No,         
@Old_Bill, @NewGRN_ID, @OldDocID, @DocumentID, @TaxAmount, @AdjustmentAmount,         
@TotalAmount, @Discount, @DiscountOption,  @CreditTerm , @PaymentDate,@Flags,@TaxOnMRP,    
@AdjustmentValue,@ExciseDuty, @ED, @PPBED,@VATTaxAmount,
@ProductDiscount,@Surcharge)          
        
        
Select @Bill_No = @@IDENTITY        
        
If @PaymentID Is Not Null     
Begin    
 Exec dbo.sp_Cancel_Payment @PaymentID        
 Exec dbo.sp_ChangeStatus_AdjRef_BillAmend @Old_Bill    
End    
Update BillAbstract Set Status = Status | 128, Balance = 0 Where BillID = @Old_Bill        
Update GRNAbstract Set BillID = @Bill_No, NewBillID = @DocumentID Where GRNID in (Select grnid From #Temp)        
Select @Bill_No, @DocumentID        
UPDATE Batch_Products SET TaxOnMRP = @TaxOnMRP WHERE Grn_ID in (Select grnid From #Temp)        
  
Drop Table #temp            


