CREATE procedure sp_ser_savedirectinvoicedetail_fmcg 
(@CustomerID nvarchar(15), @InvoiceID Int, 
@PRODUCT_CODE nvarchar(15), @Product_Specification1 nvarchar(50), 
@Type Int, @DoorDelivery int = null, @TASKID nvarchar(50) = Null, 
@ServiceTax_Percentage decimal(18,6) = Null, @ServiceTax decimal(18,6) = Null, 
@TaskType int = Null, @AMOUNT decimal (18,6) = Null, @NETVALUE decimal(18,6) = Null, 
@Price decimal (18,6) = Null,
@PersonnelID nvarchar(15) = Null, @StartDate datetime = Null, @StartTime datetime = Null, 
@EndDate datetime = Null, @EndTime datetime = Null,
@AddPercentage decimal(18,6) = 0, @TrdPercentage decimal(18,6) = 0, @BounceJCID int = 0, 
@SPARECODE nvarchar(15) = null, @Batch_Number nvarchar(128) = Null,
@WARRANTY Int = null, @WARRANTYNO nvarchar(50) = Null, @DATEOFSALE datetime = Null, 
@BaseQty decimal(18,6) = Null, @UOM Int = Null, 
@UOMPrice decimal(18,6) = Null, @UOMConversion decimal(18,6) = Null,  
@Tax_SufferedPercentage decimal(18,6) = Null, @TAXSUFFERED decimal(18,6) = Null, 
@SaleTaxPercentage decimal(18,6) = null, @SalesTaxAmount decimal(18,6) = null, 
@TaxAbleAmount Decimal(18,6) = Null,
@ItemDiscountPercentage decimal(18,6) = Null, @ItemDiscountValue decimal(18,6) = Null, 
@SaleID Int = Null, @FLAG int = Null, 
@SelectedPrice Decimal (18,6) = Null, 
@FreeRow int = null,
@Track_Batch int = Null,
@Track_Inventory int = Null, 
@Capture_price int = null,
@OpeningDate datetime = Null,
@BackDatedTransaction int = 0, 
@VatExists int = 0, 
@CollectTaxSuffered int = 0)
as

DECLARE @TaxCode Int
DECLARE @CSTPayable Decimal(18,6)
DECLARE @LSTPayable Decimal(18,6)
DECLARE @Locality Int

DECLARE @QUANTITY Decimal (18,6)  /* Stock Related */
DECLARE @TOTAL_QUANTITY Decimal (18,6) 
DECLARE @BATCH_CODE int 
DECLARE @RETVAL decimal(18,6)
DECLARE @COST decimal(18,6) 
DECLARE @DIFF decimal(18,6)
DECLARE @REFERENCEBATCH int

DECLARE @SerialNo int
DECLARE @UOMQty decimal (18,6)
DECLARE @ClaimPrice decimal (18,6) 
Set @LSTPayable = 0
Set @CSTPayable = 0

DECLARE @JobCardID int 
Select @JobcardId = JobcardId from ServiceInvoiceAbstract 
Where ServiceInvoiceId = @InvoiceID

If @Type = 0    
begin   
  /*Insert into Service invoice detail (Item Information) */  
  Insert into ServiceInvoiceDetail   
  (ServiceInvoiceID, PRODUCT_CODE, Product_Specification1, Type, DoorDelivery) Values   
  (@InvoiceID, @PRODUCT_CODE, @Product_Specification1, @Type, @DoorDelivery)
  Set @SerialNo = @@Identity  
  Set @RETVAL =  @@Identity  
  /*JobCard detail -- JobType = 1 for Minor*/
  Insert into JobCarddetail (JobCardID, PRODUCT_CODE, Product_Specification1, Type, JobType) 
  Values (@JobCardID, @PRODUCT_CODE, @Product_Specification1, @Type, 1)

  GOTO ALL_SAID_AND_DONE
end    /* If @Type = 0 */

Select @Locality = IsNull(Locality,1) from Customer Where CustomerID = @CustomerID

If @Locality = 2 begin Set @CSTPayable = @SalesTaxAmount end
Else begin Set @LSTPayable = @SalesTaxAmount end 

Set @ClaimPrice = @price 
If ((@Type = 2) and (IsNUll(@SpareCode, '') = ''))  
begin
  /* Estimated Task Rate */	  
  if isnull(@ClaimPrice, 0)  = 0
  begin	
  	select @ClaimPrice = Rate from Task_Items Where TaskId = @TaskID and Product_code = @PRODUCT_CODE
  end	

  Insert into ServiceInvoiceDetail   
  (ServiceInvoiceID, PRODUCT_CODE, Product_Specification1, Type, TaskID, Price, 
  ServiceTax_Percentage, ServiceTax, Amount, NetValue, EstimatedPrice, TaskType) Values   
  (@InvoiceID, @PRODUCT_CODE, @Product_Specification1, @Type, @TaskID, @Price, 
  @ServiceTax_Percentage, @ServiceTax, @Price, @NETVALUE, @ClaimPrice, @TaskType )	
  Set @SerialNo = @@Identity  

  DECLARE @TaskTaxAbleAmt decimal(18,6)
  Select @TaxCode = ServiceTaxCode from ServiceTaxMaster Where Percentage = @ServiceTax_Percentage 
  Set @TaskTaxAbleAmt = (@Price - (@Price * (@AddPercentage + @TrdPercentage) /100))
  if isnull(@Price, 0) > 0 
  begin	
  	Insert into ServiceInvoiceTaxComponents 
	(SerialNo, TaxType, TaxCode, TaxComponent_Code, Tax_Percentage, Rate_Percentage, Tax_Value)
  	Select @SerialNo, 1, ServiceTaxCode, ServiceTaxComponent_Code, Tax_Percentage, TaskRate_Percentage, 
  	((TaskRate_Percentage * @TaskTaxAbleAmt)/100) From ServiceTaxComponents 
  	Where ServiceTaxCode = @TaxCode 
  end

  /* Jobcard Allocation */
  Insert into Jobcardtaskallocation (JobCardID, PRODUCT_CODE, Product_Specification1, 
  Type, TASKID, PersonnelID, StartDate, StartTime, EndDate, EndTime, TaskStatus, 
  LastUpdatedTime, TaskType, Startwork) Values (@JobcardID, @PRODUCT_CODE, @Product_Specification1, 
  @Type, @TaskID, @PersonnelID, @StartDate, @StartTime, @EndDate, @EndTime, 2, 
  Getdate(), @TaskType, 1)

  /*JobCard detail*/
  Insert into JobCarddetail (JobCardID, PRODUCT_CODE, Product_Specification1, Type, TASKID, 
  TaskType, JobCardID_Bounced) Values (@JobCardID, @PRODUCT_CODE, @Product_Specification1, 
  @Type, @TaskID, @TaskType, @BounceJCID)

  Set @RETVAL = @SerialNo
  GOTO ALL_SAID_AND_DONE
end 

/* Spares */
Select @TaxCode = Tax_Code from Tax 
Where (Case @Locality when 2 then CST_Percentage else Percentage end)= @SaleTaxPercentage

IF @TRACK_INVENTORY = 0
BEGIN	
  Set @UOMqty = @BaseQty/IsNUll(@UOMConversion, 1)
  If isnull(@ClaimPrice, 0) = 0 
  begin
	Select @ClaimPrice = ISNULL(Sale_Price, 0) from Items where Product_Code = @SpareCode
  end	
	
  Insert into ServiceInvoiceDetail   
  (ServiceInvoiceID, PRODUCT_CODE, Product_Specification1, Type, TaskID, SpareCode,
  Batch_Code, Batch_Number, Warranty, WarrantyNo, DateofSale, Price, Quantity, UOM, UOMQty, 
  UOMPrice, Tax_SufferedPercentage, TaxSuffered, SaleTax, LSTPayable, CSTPayable, 
  Amount, NetValue, EstimatedPrice, SaleID, ItemDiscountPercentage, ItemDiscountValue, Flag, 
  Claim_Price, Vat_Exists, CollectTaxSuffered_Spares) Values   
  (@InvoiceID, @PRODUCT_CODE, @Product_Specification1, @Type, @TaskID, @SpareCode, 
  0, @Batch_Number, @Warranty, @WarrantyNo, @DateofSale, @Price, @BaseQty, @UOM, @UOMQty,
  @UOMPrice, @Tax_SufferedPercentage, @TAXSUFFERED, @SaleTaxPercentage, @LSTPayable, @CSTPayable, 
  @AMOUNT, @NETVALUE, @ClaimPrice, @SaleID, @ItemDiscountPercentage, @ItemDiscountValue, @Flag, 
  @ClaimPrice, @VatExists, @CollectTaxSuffered)	
  Set @SerialNo = @@Identity

  /*JobCard detail*/
  Insert into JobCarddetail (JobCardID, PRODUCT_CODE, Product_Specification1, Type, TASKID, 
  SPARECODE, QUANTITY, UOM, uomQty, WARRANTY, WARRANTYNO, DATEOFSALE) Values 
  (@JobCardID, @PRODUCT_CODE, @Product_Specification1, @Type, @TaskID, 
  @SpareCode, @BaseQty, @UOM, @UOMQty, @Warranty, @WarrantyNo, @DateofSale)

  /*TaxType = 2 for spare tax type */ 
  if Isnull(@SaleTaxPercentage, 0) > 0
  begin		
  	Insert into ServiceInvoiceTaxComponents
  	(SerialNo, TaxType, TaxCode, TaxComponent_Code, Tax_Percentage, Rate_Percentage, Tax_Value)
  	Select @SerialNo, 2, Tax_Code, TaxComponent_Code, Tax_Percentage, sp_Percentage, 
  	((sp_Percentage * @TaxAbleAmount)/100) From taxcomponents 
	Where Tax_Code = @TAXCODE and 
	Isnull(LST_Flag, 0) = (Case Isnull(@Locality, 0) when 2 then 0 else 1 end)		
  end
  SET @RETVAL = @SerialNo
  GOTO ALL_SAID_AND_DONE
END
else 
BEGIN /* @TRACK_INVENTORY = 1 */ 
  IF @CAPTURE_PRICE = 1  
  BEGIN /* @CAPTURE_PRICE = 1  */ 
    IF @Track_Batch = 1
    BEGIN /* @Track_Batch = 1 */

	SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
	WHERE Product_Code = @SpareCode AND ISNULL(Batch_Number, '') = @Batch_Number
	AND ISNULL(SalePrice, 0) = @SelectedPrice AND 
	(Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0 
	And isnull(Free, 0) = @FreeRow

	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, BatchReference --, ECP, TaxSuffered
	FROM Batch_Products
	WHERE Product_Code = @SpareCode and ISNULL(Batch_Number, '') = @Batch_Number 
	and ISNULL(SalePrice, 0) = @SelectedPrice AND ISNULL(Quantity, 0) > 0 
	AND (Expiry >= GetDate() OR Expiry IS NULL) 
	And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow 

    END /* @Track_Batch = 1 */ 
    ELSE -- No Track Batch
    BEGIN   /* @Track_Batch = 0 */
	SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
	WHERE Product_Code = @SpareCode AND ISNULL(SalePrice, 0) = @SelectedPrice 
	And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow

	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, BatchReference --, ECP, TaxSuffered
	FROM Batch_Products
	WHERE Product_Code = @SpareCode AND ISNULL(SalePrice, 0) = @SelectedPrice 
	AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
	And isnull(Free, 0) = @FreeRow
    END /* @Track_Batch = 1 */
  END /* @CAPTURE_PRICE = 1  */ 
  else  
  BEGIN /* @CAPTURE_PRICE = 0  */ 
    IF @TRACK_BATCH = 1  
    BEGIN  /* @Track_Batch = 1 */
	SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
	WHERE Product_Code = @SpareCode AND 
	ISNULL(Batch_Number, '') = @Batch_Number AND 
	(Expiry >= GetDate() OR Expiry IS NULL) 
	And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
	
	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, BatchReference --, ECP, TaxSuffered
	FROM Batch_Products
	WHERE Product_Code = @SpareCode 
	AND ISNULL(Batch_Number, '') = @Batch_Number 
	AND ISNULL(Quantity, 0) > 0 
	AND (Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0
	And isnull(Free, 0) = @FreeRow
    END /* @Track_Batch = 1 */ 
    ELSE   
    BEGIN  /* @Track_Batch = 0 */
	SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
	WHERE Product_Code = @SpareCode  
	And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
	
	DECLARE ReleaseStocks CURSOR KEYSET FOR
	SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, BatchReference --, ECP, TaxSuffered
	FROM Batch_Products
	WHERE Product_Code = @SpareCode  
	AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
	And isnull(Free, 0) = @FreeRow
    END  /* @Track_Batch = 1     */
  END 	/* @CAPTURE_PRICE = 0   */ 
END    /* @TRACK_INVENTORY = 0 */

IF @TOTAL_QUANTITY < @BaseQty
BEGIN
	SET @RETVAL = 0
	DEALLOCATE ReleaseStocks	
	GOTO ALL_SAID_AND_DONE
END
ELSE
BEGIN
	SET @RETVAL = 1
END
DECLARE @BatchQty decimal(18,6)
DECLARE @SpareValue Decimal(18,6)
DECLARE @TaxSufferedValue decimal(18,6)
DECLARE @SaleTaxValue decimal(18,6)
DECLARE @SaleTaxCreditValue Decimal(18,6)

OPEN ReleaseStocks
FETCH FROM ReleaseStocks into @Batch_Number, @BATCH_CODE, @QUANTITY, @COST, @REFERENCEBATCH --, @MRP, @BATCHTAXSUFFERED

WHILE @@FETCH_STATUS = 0
BEGIN
    Set @TaxSufferedValue = 0
    Set @SpareValue = 0
    Set @SaleTaxValue = 0	
    Set @CSTPayable = 0
    Set @LSTPayable = 0
    Set @TaxAbleAmount = 0	
    Set @BatchQty = 0 	
    If @BaseQty = 0 GOTO OVERNOUT 	

	set @claimprice = @Price
	If IsNull(@FreeRow, 0) <> 0 and isnull(@ClaimPrice, 0) = 0 and  isnull(@CAPTURE_PRICE, 0) <> 0
	begin
		select @ClaimPrice = ISNULL(SalePrice, 0) from Batch_Products 
		Where Batch_Code = isnull(@REFERENCEBATCH, 0)
	end 
	else if isnull(@UOMPrice, 0) = 0 and isnull(@ClaimPrice, 0) = 0
	begin
		Select @ClaimPrice = ISNULL(Sale_Price, 0) FROM Items WHERE Product_code = @SpareCode
	end

    IF @QUANTITY >= @BaseQty 	
	set @BatchQty = @BaseQty 
    else 
	set @BatchQty = @QUANTITY 

    set @BASEQty = @BaseQty - @BatchQty	
        	/* Invoice Calculation */
 	  Set @UOMqty = @BatchQty / @UOMConversion
	  Set @SpareValue = @UOMqty * @UOMPrice
	  Set @ItemDiscountValue = @SpareValue * (@ItemDiscountPercentage / 100)
	  If @TAXSUFFERED > 0 Set @TaxSufferedValue =  @SpareValue * (@Tax_SufferedPercentage / 100) 
	  If @Flag = 1   /* ComputeTaxbeforeDiscount */	
	  begin 
		Set @TaxAbleAmount = (@Sparevalue + @TaxSufferedValue)
		Set @SaleTaxValue = (@Sparevalue + @TaxSufferedValue) * (@SaleTaxPercentage / 100)
	  	Set @SaleTaxCreditValue = 0 
	  end 
	  Else 
	  begin
		Set @TaxAbleAmount = (@Sparevalue + @TaxSufferedValue - @ItemDiscountValue - ((@Sparevalue - @ItemDiscountValue) * ((@AddPercentage + @TrdPercentage) / 100)))  
		Set @SaleTaxValue = (@Sparevalue + @TaxSufferedValue - @ItemDiscountValue) * 
		(@SaleTaxPercentage / 100)
	  	Set @SaleTaxCreditValue = @SaleTaxValue * ((@AddPercentage + @TrdPercentage) / 100)
	  end 	

	/* Net = Spare Amount + SaleTaxValue + TaxSuffereValue 
		- SaleTaxCredit - AddDiscValue - TrdDiscValue */
	  Set @NETVALUE = (@Sparevalue + @SaleTaxValue + @TaxSufferedValue 
			- @ItemDiscountValue - @SaleTaxCreditValue  
			- ((@Sparevalue - @ItemDiscountValue) * ((@AddPercentage + @TrdPercentage) / 100))) 

	  If @Locality = 2 
	  	Set @CSTPayable = @SaleTaxValue - @SaleTaxCreditValue
	  Else 
		Set @LSTPayable = @SaleTaxValue - @SaleTaxCreditValue

		/* Service Invoice Detail */
		Insert into ServiceInvoiceDetail   
		(ServiceInvoiceID, PRODUCT_CODE, Product_Specification1, Type, TaskID, SpareCode,
		Batch_Code, Batch_Number, Warranty, WarrantyNo, DateofSale, Price, Quantity, UOM, 
		UOMQty, UOMPrice, Tax_SufferedPercentage, TaxSuffered, SaleTax, 
		LSTPayable, CSTPayable, 
		Amount, NetValue, EstimatedPrice, SaleID, ItemDiscountPercentage, ItemDiscountValue, 
		Flag, Claim_Price, Vat_Exists, CollectTaxSuffered_Spares) Values   
		(@InvoiceID, @PRODUCT_CODE, @Product_Specification1, @Type, @TaskID, @SpareCode, 
		@BATCH_CODE, @Batch_Number, @Warranty, @WarrantyNo, @DateofSale, @Price, @BatchQty, @UOM, 
		@UOMQty, @UOMPrice, @Tax_SufferedPercentage, @TaxSufferedValue, @SaleTaxPercentage, 
		@LSTPayable, @CSTPayable, 
		@SpareValue, @NETVALUE, @ClaimPrice, @SaleID, @ItemDiscountPercentage, @ItemDiscountValue, 
		@Flag, @ClaimPrice, @VatExists, @CollectTaxSuffered)	

	  Set @SerialNo = @@Identity  

	  /*JobCard detail*/
	  Insert into JobCarddetail (JobCardID, PRODUCT_CODE, Product_Specification1, Type, 
	  TASKID, SPARECODE, QUANTITY, UOM, uomQty, WARRANTY, WARRANTYNO, DATEOFSALE) Values 
	  (@JobCardID, @PRODUCT_CODE, @Product_Specification1, @Type, @TaskID, @SpareCode, 
	  @BatchQty, @UOM, @UOMQty, @Warranty, @WarrantyNo, @DateofSale)

    	  /*TaxType = 2 for spare tax type */ 
	  if isnull(@SaleTaxPercentage, 0) > 0 
	  begin
	  	Insert into ServiceInvoiceTaxComponents (SerialNo, TaxType, TaxCode, TaxComponent_Code, 
	 	Tax_Percentage, Rate_Percentage, Tax_Value)
		Select @SerialNo, 2, Tax_Code, TaxComponent_Code, Tax_Percentage, sp_Percentage, 
		((sp_Percentage * @TaxAbleAmount)/100) From taxcomponents 
		Where Tax_Code = @TAXCODE and 
		Isnull(LST_Flag, 0) = (Case Isnull(@Locality, 0) when 2 then 0 else 1 end)
	  end

	UPDATE Batch_Products SET Quantity = Quantity - @BatchQty
	WHERE Batch_Code = @BATCH_CODE

  	  IF @@ROWCOUNT = 0
 	  BEGIN
		SET @RETVAL = 0
		GOTO OVERNOUT
	  END
	  IF @BackDatedTransaction = 1 
	  BEGIN
		SET @DIFF = 0 - @BatchQty
		exec sp_ser_update_opening_stock @SpareCode, @OpeningDate, @DIFF, @FreeRow, @COST
	  END
	  SET @RETVAL = @SerialNo	
    FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, @REFERENCEBATCH --,  @MRP, @BATCHTAXSUFFERED
END
OVERNOUT:
CLOSE ReleaseStocks
DEALLOCATE ReleaseStocks

ALL_SAID_AND_DONE:
	
SELECT @RETVAL

/* 
UOMPrice saved with Base price of the Selected item 
Price will hold the Sale price of the Selected Item 
*/





