CREATE Procedure  sp_ser_saveinvoicedetail 
(@CustomerID nvarchar(15), @InvoiceID Int, 
@PRODUCT_CODE nvarchar(15), @Product_Specification1 nvarchar(50), 
@Type Int, @TASKID nvarchar(50), @SPARECODE nvarchar(15), @BATCH_CODE int, @Batch_Number nvarchar(128),
@WARRANTY Int, @WARRANTYNO nvarchar(50), @DATEOFSALE datetime, @Price decimal (18,6), 
@QUANTITY decimal(18,6), @UOM Int, @uomQty decimal(18,6), @UOMPrice decimal(18,6), 
@Tax_SufferedPercentage decimal(18,6), @TAXSUFFERED decimal(18,6), @SaleTax decimal(18,6), 
@SalesTaxAmount decimal(18,6), @ServiceTax_Percentage decimal(18,6),
@ServiceTax decimal(18,6), @AMOUNT decimal (18,6), @NETVALUE decimal(18,6), 
@EstimatedPrice decimal(18,6), @SaleID Int, @ItemDiscountPercentage decimal(18,6),
@ItemDiscountValue decimal(18,6), @FLAG int, @DoorDelivery int, 
@TaxCode as int, @TaxFlag as int, @IssueID as int, @JobID as varchar(15), @JobFree as int, 
@TaskTaxAbleAmt as decimal(18,6)= 0, @ClaimPrice as decimal(18,6) = 0, 
@VatExists int = 0, @CollectTaxSuffered int = 0, @IssueSerialNo Int = 0,@BackDated Int = 0)
as 
Declare @CSTPayable Decimal(18,6)
Declare @LSTPayable Decimal(18,6)
Declare @Locality Int
Declare @InvoiceDate DateTime
Declare @Free Int, @Cost Decimal(18,6)
Declare @Diff Decimal(18,6)
Set @LSTPayable = 0
Set @CSTPayable = 0

If (IsNull(@SPARECODE,'') <> '') and isnull(@UOMPrice, 0) > 0
Begin
	Select @Locality = IsNull(Locality,1) from Customer Where CustomerID = @CustomerID
	
	If @Locality = 2
	Begin 
		Set @CSTPayable = @SalesTaxAmount 
	End
	Else 
	Begin
		Set @LSTPayable = @SalesTaxAmount
	End 
End 

Declare @SerialNo as int 
/*Insert into Service invoice detail*/
Insert into ServiceInvoiceDetail (ServiceInvoiceID, PRODUCT_CODE, Product_Specification1, 
Type, TASKID, SPARECODE, BATCH_CODE, Batch_Number, WARRANTY, WARRANTYNO, DATEOFSALE, Price,
QUANTITY, UOM, uomQty, UOMPrice, Tax_SufferedPercentage, TAXSUFFERED, SaleTax, LSTPayable, 
CSTPAYABLE, ServiceTax_Percentage, ServiceTax, AMOUNT, NETVALUE, EstimatedPrice, SaleID,
ItemDiscountPercentage, ItemDiscountValue, FLAG, DoorDelivery, IssueID, JobID, JobFree, 
Claim_price, Vat_Exists, CollectTaxSuffered_Spares, Issue_Serial) Values 
(@InvoiceID, @PRODUCT_CODE, @Product_Specification1, 
@Type, @TASKID, @SPARECODE, @BATCH_CODE, @Batch_Number, @WARRANTY, @WARRANTYNO, @DATEOFSALE, 
@Price, @QUANTITY, @UOM, @uomQty, @UOMPrice, @Tax_SufferedPercentage, @TAXSUFFERED, @SaleTax, 
@LSTPayable, @CSTPAYABLE, @ServiceTax_Percentage, @ServiceTax, @AMOUNT, @NETVALUE, 
@EstimatedPrice, @SaleID, @ItemDiscountPercentage, @ItemDiscountValue, @FLAG, @DoorDelivery, 
@IssueID, @JobID, @JobFree, @ClaimPrice, @VatExists, @CollectTaxSuffered, @IssueSerialNo)

Set @SerialNo = @@Identity

/* Update ItemInformation */
update Item_information Set Product_Status = 0, LastServiceDate = Getdate(), 
LastModifiedDate = getdate()  
where Product_Code = @Product_Code and Product_Specification1 = @Product_Specification1

Select @SerialNo, @@RowCount 

If (IsNull(@SPARECODE,'') <> '' and @TaxCode > 0 and isnull(@UOMPrice, 0) > 0) 
Begin
	/* TaxFlag 
	0 to retrive tax component from Issue Tax Component 
	1 to retrive tax component from tax master
	 */
	Declare @TaxAbleAmt as decimal(18,6)
	If (@SalesTaxAmount > 0 and @SaleTax > 0 ) Set @TaxAbleAmt = ((@SalesTaxAmount * 100) / @SaleTax)
	If (@TaxFlag = 0) 
	Begin 
		Insert into ServiceInvoiceTaxComponents 
		(SerialNo,TaxType, TaxCode, TaxComponent_Code, Tax_Percentage, Rate_Percentage, Tax_Value)
		Select @SerialNo, 2, TaxCode, TaxComponent_Code, Tax_Percentage, Rate_Percentage, 
		((Rate_Percentage * @TaxAbleAmt)/100) From IssueTaxComponent t Where TaxCode = @TaxCode 
		and t.SerialNo in (Select d.SerialNo from IssueDetail d Where d.IssueId = @IssueID)
	End 
	else if (@TaxFlag = 1) 
	Begin 
		Insert into ServiceInvoiceTaxComponents 
		(SerialNo, TaxType, TaxCode, TaxComponent_Code, Tax_Percentage, Rate_Percentage, Tax_Value)
		Select @SerialNo, 2, Tax_Code, TaxComponent_Code, Tax_Percentage, sp_Percentage, 
		((sp_Percentage * @TaxAbleAmt)/100) From taxcomponents Where Tax_Code = @TaxCode
	End 
	
End 
Else If (IsNull(@SPARECODE,'') = '' and @TaxCode > 0 and isnull(@UOMPrice, 0) > 0)
Begin 	
	
	Insert into ServiceInvoiceTaxComponents 
	(SerialNo, TaxType, TaxCode, TaxComponent_Code, Tax_Percentage, Rate_Percentage, Tax_Value)
	Select @SerialNo, 1, ServiceTaxCode, ServiceTaxComponent_Code, Tax_Percentage, TaskRate_Percentage, 
	((TaskRate_Percentage * @TaskTaxAbleAmt)/100) From ServiceTaxComponents Where ServiceTaxCode = @TaxCode	
End 

/* 
03.05.05
@TaskTaxAbleAmt Will have Price After Trading Discount And Additional Discount
@SalesTaxAmount Will be the value After Saletax Credit 

*/
/*Back Dated Transaction */
If (isNull(@SpareCode,'')<>'' and isNull(@Quantity,0)<>0)
Begin
	Select @InvoiceDate = ServiceInvoiceDate from ServiceInvoiceAbstract where ServiceInvoiceID = @InvoiceID
	and dbo.sp_ser_StripDateFromTime(ServiceInvoicedate) < dbo.sp_ser_StripDateFromTime(Getdate())
	if @InvoiceDate is NULL 
		Set @BackDated = 0
	else
		Set @BackDated = 1
	if @BackDated = 1
	Begin
		Select @Free = isNull([Free],0),@Cost = isNull([PurchasePrice],0) from Batch_Products
		where Batch_Code = @Batch_Code and Product_Code = @SpareCode
		Set @Diff = 0 - @Quantity
		Exec sp_ser_update_opening_stock @SpareCode,@InvoiceDate,@Diff,@Free,@Cost
	End
End
