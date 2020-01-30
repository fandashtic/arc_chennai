CREATE procedure sp_update_MultipleGRN_Bill(@GRN_ID nvarchar(1000), @Bill_Date datetime,      
@Vendor_ID nvarchar(15), @User_Name nvarchar(50),      
@Value Decimal(18,6), @Inv_Ref nvarchar(50), @NewGRNID nvarchar(255), @TaxAmount Decimal(18,6),       
@AdjustmentAmount as Decimal(18,6), @Discount Decimal(18,6), @DiscountOption int,       
@CreditTerm Integer, @PaymentDate DateTime,@Flags int=0, @TaxOnMRP INT = NULL, @AdjustmentValue Decimal(18,6) = 0,  
@ExciseDuty Decimal(18,6) = 0,@ED int = 0,@PPBED int = 0,@VATTaxAmount Decimal(18,6)=0,@TotalAmount Decimal(18,6) = 0,
@Remarks nVarChar(2000)='',@Old_BillID Int = 0, @TaxType Int = 1
,@GSTFlag Int = 0,@FromStateCode Int = 0 ,@ToStateCode Int = 0
,@GSTIN nVarChar(15)
,@ODNumber nVarChar(50)
)  
As       
declare @BillNo int      
DECLARE @DocumentID int
Declare @PaymentID Int
Declare @NewPaymentVal Int
Set @PaymentID = 0

Declare @IsGSTEnabled as Int
Select @IsGSTEnabled = Isnull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'

Declare @StateType Int
IF @GSTFlag = 1 
Begin
	Set @StateType = @TaxType
	Set @TaxType = 0
End
Else
Begin
	Set @StateType = 0
End

create table #Temp (grnid int)                
Exec ('Insert Into #Temp Select GRNID FROm GrnAbstract Where GRNID in (' + @GRN_ID + ')')      
      
If @Old_BillID = 0 
Begin
SELECT @DocumentID = DocumentID FROM DocumentNumbers WHERE DocType = 6      
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 6      
End
Else
Begin
SELECT @DocumentID = DocumentID , @PaymentID = PaymentID FROM BillAbstract Where BillID = @Old_BillID
End

/*When Credit Term value is zero, Select Top 1 Credit Term and Recalculate Payment Date [UAT Fix, Work around]*/
If @CreditTerm = 0 
Begin
  Select Top 1 @CreditTerm = IsNull(CreditID,0), @NewPaymentVal = [Value] From CreditTerm Where Active =1 And [Type] = 1 

  If @CreditTerm > 0 
  Begin   
    Set @PaymentDate = DateAdd(d, @NewPaymentVal, @Bill_Date) 
  End
End


--If @DiscountOption = 0  Set @DiscountOption = 2
      
Insert into BillAbstract (GRNID, BillDate, VendorID, UserName,       
Value, CreationTime, Status, InvoiceReference, DocumentID, NewGRNID, TaxAmount,      
AdjustmentAmount, Balance, Discount, DiscountOption, AdjustedAmount, CreditTerm, PaymentDate, Flags, TaxOnMRP, AdjustmentValue,  
ExciseDuty, DiscountBeforeExcise, PurchasePriceBeforeExcise,VATTaxAmount,Remarks, TaxDiscountFlag,TaxType
,GSTFlag,StateType,FromStatecode,ToStatecode,GSTIN,GSTEnableFlag, ODNumber)
Values (@GRN_ID, @Bill_Date,      
@Vendor_ID, @User_Name, @Value, GetDate(), 0, @Inv_Ref, @DocumentID, @NewGRNID, @TaxAmount,      
@AdjustmentAmount, @TotalAmount, @Discount, @DiscountOption, 0, @CreditTerm, @PaymentDate,@Flags, @TaxOnMRP, @AdjustmentValue,  
@ExciseDuty, @ED, @PPBED,@VATTaxAmount,@Remarks, @Flags, @TaxType
, @GSTFlag, @StateType, @FromStateCode, @ToStateCode, @GSTIN,@IsGSTEnabled,@ODNumber)
select @BillNo = @@IDENTITY

update GRNAbstract set GRNStatus = GRNStatus | 128, BillID = @BillNo, NewBillID = @DocumentID       
where GRNID in (select grnid from #Temp)  


If @Old_BillID > 0 
Begin
Update BillAbstract Set Status = Status | 128, Balance = 0 Where BillID = @Old_BillID
Update BillAbstract Set BillReference = @Old_BillID, DocumentReference = @DocumentID Where BillID = @BillNo
 If IsNull(@PaymentID,0) > 0
  Begin    
   Exec dbo.sp_Cancel_Payment @PaymentID        
   Exec dbo.sp_ChangeStatus_AdjRef_BillAmend @Old_BillID   
  End
End
       
Select @BillNo, @DocumentID
      
UPDATE Batch_Products SET TaxOnMRP = @TaxOnMRP WHERE Grn_ID in (select grnid from #Temp)
  
drop table #temp

