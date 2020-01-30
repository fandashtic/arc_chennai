Create Function mERP_fn_Get_RFADamageDesc(
        @PRODUCT_CODE nVarchar(50),
        @BATCH_NUM nVarchar(100),
        @PURCAHSE_PRICE Decimal(18,6),
        @EXPIRY DateTime, 
        @DAMAGE INT,
        @TAXSUFFERED Decimal(18,6))
Returns nVarchar(2000)
Begin
DECLARE @REASON_TYPE INT 
SET @REASON_TYPE = Case @DAMAGE When 1 Then 3 When 2 Then 2 End 

DECLARE @tmpDmgReason Table (ReasonDesc nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Insert into @tmpDmgReason
Select Reason_Description 
From ReasonMaster, Batch_Products  
Where Product_Code  = @PRODUCT_CODE And 
Batch_Number = @BATCH_NUM AND 
PurchasePrice = @PURCAHSE_PRICE AND 
(Expiry = @Expiry OR Expiry IS NULL) AND
Damage = @DAMAGE AND 
taxSuffered = @TAXSUFFERED  AND 
Reason_SubType = @REASON_TYPE AND 
Reason_Type_ID = IsNull(Batch_Products.DamagesReason,0)
Group by Reason_Description


Declare @DamageDesc nVarchar(250)
Declare @DescList nVarchar(2000)
SET @DescList = '' 
Declare DamageReason Cursor FOR
Select ReasonDesc From @tmpDmgReason
Open DamageReason 
FETCH From DamageReason Into @DamageDesc
While @@FETCH_STATUS = 0 
Begin
  Set @DescList = @DescList + @DamageDesc + ', ' 
  FETCH From DamageReason Into @DamageDesc
End 
close DamageReason
Deallocate DamageReason

If Len(@DescList) > 0 
Set @DescList = SubString(@DescList,1, LEN(@DescList)-1)
Return @DescList

End
