CREATE Procedure sp_ser_saveissuedetail(
	@IssueID int,
	@Product_Code NVARCHAR(15),
	@Product_Specification1 NVARCHAR(50), 
	@SpareCode nvarchar(15),
	@Batch_Number nvarchar(50), 
	@UOM int, 
	@UOMQTY Decimal (18,6),
	@Warranty int,
	@WarrantyNo nvarchar(50), 	
	@DateofSale Datetime,
	@SalePrice Decimal (18,6),
	@SelectedPrice Decimal (18,6), 
	@TaxSuffered Decimal (18,6), 
	@BaseQty decimal(18,6), -- Issued UOM Base qty
	@FreeRow int,
	@Track_Batch int,
	@Track_Inventory int, 
	@Capture_price int,
	@UOMPrice Decimal (18,6),	
	@UOMConvertor Decimal(18,6),
	@CustomerID nvarchar(15), 
	@JobcardID int, 
	@JCSerialNo int,
	@OpeningDate datetime = Null, 
        @PersonnelID nvarchar(50),
	@SelectedPurchasePrice Decimal (18,6), 
	@VatExist int, 
	@CollectTaxSuffered int)
AS
DECLARE @SerialNo int 
DECLARE @QUANTITY Decimal (18,6) 
DECLARE @SALETAXCODE int
DECLARE @SALETAXPERCENTAGE Decimal(18,6)
DECLARE @BATCHTAXSUFFERED Decimal (18,6)
DECLARE @REFERENCEBATCH int 
DECLARE @LOCALITY int
DECLARE @TOTAL_QUANTITY Decimal (18,6)
DECLARE @BATCH_CODE int 
DECLARE @CUSTOMERTYPE int
DECLARE @RETVAL decimal(18, 6)
DECLARE @COST decimal(18,6) 
DECLARE @PENDINGQTY Decimal (18,6)
/*
Opening details stock updation for back dated transaction 
has been done only after invoicing the issues
This variable is used for that.
DECLARE @DIFF decimal(18,6)
*/
DECLARE @ClaimPrice Decimal(18,6)
DECLARE @PTS Decimal(18,6)
DECLARE @PTR Decimal(18,6)
DECLARE @MRP Decimal(18,6)
/* JobCardSpares 
	if there is JCSerialNo and Basqt > pending existing 
		JCSerial Number will be updated to 
		Updation take into action till the pending quantity, 
		excess will be inserted 
	else Inserts new row   */
DECLARE @JCSPARESISSUEDQTY decimal(18,6)
DECLARE @JCSPARESISSUEID int 
DECLARE @FreeJOB int 
If @JCSerialNo > 0  
begin 
	Select @PENDINGQTY = PendingQty, @FreeJOB = IsNull(JobFree,0)
	from JobcardSpares Where SerialNo = @JCSerialNo
	If @FreeJOB = 1 
	begin
		Set @SalePrice = 0 
		Set @TaxSuffered = 0
		set @UOMPrice = 0
	end 
	If (@BaseQty <= @PENDINGQTY)  
	begin
		If (@BaseQty = @PENDINGQTY)
			Update JobCardSpares Set PendingQty = PendingQty - @BaseQty, 
			SpareStatus = 1 where  SerialNo = @JCSerialNo
		else 
			Update JobCardSpares Set PendingQty = PendingQty - @BaseQty, 
			SpareStatus = 0 where  SerialNo = @JCSerialNo
	end 
	else
	begin
		Select @JCSPARESISSUEDQTY = Sum(IssuedQty) from IssueDetail 
		Where ReferenceID = @JCSerialNo Group by ReferenceID
		Set @UOMQty = @BaseQty/@UOMConvertor
		If IsNull(@JCSPARESISSUEDQTY,0) > 0 		
		begin
			Update JobCardSpares Set Qty = IsNull(@JCSPARESISSUEDQTY,0), 
			PendingQty = 0, SpareStatus = 1 where  SerialNo = @JCSerialNo
			
			Insert into JobCardSpares (JobCardID, Product_Code, 
			Product_Specification1, SpareCode, UOM, Qty, PendingQty, 
			SpareStatus, Warranty, WarrantyNo, DateofSale, JobId, TaskID, JobFree) 
			Select JobCardID, Product_Code, Product_Specification1, SpareCode, 
			UOM, @UOMQty, 0, 1, @Warranty, @WarrantyNO, @DateofSale, JobId, 
			TaskID, JobFree From JobCardSpares Where SerialNo = @JCSerialNo 
			Set @JCSerialNo = @@Identity	
		end
		Else
		begin
			Update JobCardSpares Set Qty = @UOMQty, 
			PendingQty = 0, SpareStatus = 1 where SerialNo = @JCSerialNo
		end 
	end 	
	
end 
else
begin
	Insert into JobCardSpares (JobCardID, Product_Code, Product_Specification1, SpareCode,  
	UOM, Qty, PendingQty, SpareStatus, Warranty, WarrantyNo, DateofSale) values
	(@JobcardID, @Product_code, @Product_Specification1, @SpareCode, @UOM, @UOMQty, 
	0, 1, @Warranty, @WarrantyNO, @DateofSale) 
	Set @JCSerialNo = @@Identity	
end 
/* Batch wise Stock reduction */
Select @LOCALITY = IsNull(Locality,1), @CUSTOMERTYPE = CustomerCategory from customer 
	Where CustomerID = @CustomerID 

Set @SALETAXCODE = 0
Set @SALETAXPERCENTAGE = 0
If @SalePrice > 0  	
begin
	SELECT @SALETAXCODE = Sale_Tax FROM Items WHERE Product_code = @SpareCode
	SELECT @SALETAXPERCENTAGE = (Case @LOCALITY when 2 then 
		ISNULL(CST_Percentage, 0) else Isnull(Percentage, 0) end) 
	FROM Tax WHERE  Tax_Code = @SALETAXCODE 
end
IF @TRACK_INVENTORY = 0
BEGIN
	SELECT @COST = Purchase_Price, 
	@ClaimPrice = (Case @CUSTOMERTYPE when 3 then ISNULL(Company_Price, 0) else  isnull(ecp, 0) end),
	@PTS = IsNull(PTS, 0), @PTR = Isnull(PTR, 0), @MRP = IsNull(MRP, 0)
	FROM Items WHERE Product_code = @SpareCode	
	SET @RETVAL = 1
	Set @UOMqty = @BaseQty/@UOMConvertor
	Insert into IssueDetail (IssueID, Product_Code, Product_Specification1, 
	SpareCode, Batch_Code, Batch_Number, Warranty, WarrantyNo, DateofSale, 
	UOM, UOMQty, SalePrice, TaxSuffered_Percentage, SaleTax_Percentage, 
	IssuedQty, UOMPrice, TaxID, ReferenceID, PurchasePrice, PersonnelID, Claim_Price, 
	Vat_Exists, CollectTaxSuffered_Spares, PTS, PTR, MRP)
	Values  
	(@IssueID, @Product_Code, @Product_Specification1, 
	@SpareCode, 0, @Batch_Number, @Warranty, @WarrantyNo, @DateofSale, 
	@UOM, @UOMQty, (case  when Isnull(@Warranty, 0) <> 1 then @SalePrice else 0 end), @TaxSuffered, @SALETAXPERCENTAGE, 
	@BaseQty, @UOMPrice, @SALETAXCODE, @JCSerialNo, @Cost, @PersonnelID, @ClaimPrice, 
	@VatExist, @CollectTaxSuffered, Isnull(@PTS, 0), Isnull(@PTR, 0), Isnull(@MRP, 0))
	
	Set @SerialNo = @@Identity
	/*TaxType = 2 for spare tax type */ 
	if isnull(@UOMPrice, 0) > 0
	begin 
		Insert into IssueTaxComponent
		(SerialNo, TaxType, TaxCode, TaxComponent_Code, Tax_Percentage, Rate_Percentage, Tax_Value)
		Select @SerialNo, 2, Tax_Code, TaxComponent_Code, Tax_Percentage, sp_Percentage, 
		((sp_Percentage * @SalePrice) / 100) From taxcomponents 
		Where Tax_Code = @SALETAXCODE  and 
		Isnull(LST_Flag, 0) = (Case Isnull(@Locality, 0) when 2 then 0 else 1 end)
	end
	GOTO ALL_SAID_AND_DONE
END
else
BEGIN
	IF @CAPTURE_PRICE = 1  
	BEGIN
		IF @Track_Batch = 1
		BEGIN
			IF @CUSTOMERTYPE = 3   
				SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
				WHERE Product_Code = @SpareCode AND ISNULL(Batch_Number, '') = @Batch_Number
				AND ISNULL(Company_Price, 0) = @SelectedPrice 
				AND isnull(purchaseprice, 0) = isnull(@SelectedPurchasePrice, 0)
				AND (Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0 
				And isnull(Free, 0) = @FreeRow
			Else
				SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
				WHERE Product_Code = @SpareCode AND ISNULL(Batch_Number, '') = @Batch_Number 
				AND (Expiry >= GetDate() OR Expiry IS NULL) AND ISNULL(ECP, 0) = @SelectedPrice 
				AND Isnull(purchaseprice, 0) = Isnull(@SelectedPurchasePrice, 0) 
				And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			IF @CUSTOMERTYPE = 3
			BEGIN
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, 
				TaxSuffered, BatchReference, PTS, PTR, ECP
				FROM Batch_Products
				WHERE Product_Code = @SpareCode and ISNULL(Batch_Number, '') = @Batch_Number 
				AND ISNULL(Company_Price, 0) = @SelectedPrice 
				AND isnull(purchaseprice, 0) = isnull(@SelectedPurchasePrice, 0) 
				AND ISNULL(Quantity, 0) > 0 AND (Expiry >= GetDate() OR Expiry IS NULL) 
				And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			END
			Else
			BEGIN
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, 
				TaxSuffered, BatchReference, PTS, PTR, ECP
				FROM Batch_Products
				WHERE Product_Code = @SpareCode AND ISNULL(Batch_Number, '') = @Batch_Number 
				AND ISNULL(ECP, 0) = @SelectedPrice 
				AND isnull(purchaseprice, 0) = isnull(@SelectedPurchasePrice, 0) 
				AND ISNULL(Quantity, 0) > 0 AND (Expiry >= GetDate() OR Expiry IS NULL) 
				AND ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			END
		END
		ELSE
		BEGIN   
			IF @CUSTOMERTYPE = 3
				SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
				WHERE Product_Code = @SpareCode AND ISNULL(Company_Price, 0) = @SelectedPrice 
				AND isnull(purchaseprice, 0) = isnull(@SelectedPurchasePrice, 0) 
				AND ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			else
				SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
				WHERE Product_Code = @SpareCode AND ISNULL(ECP, 0) = @SelectedPrice 
				AND isnull(purchaseprice, 0) = isnull(@SelectedPurchasePrice, 0) 
				And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
		
			IF @CUSTOMERTYPE = 3
			BEGIN
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, 
				TaxSuffered, BatchReference, PTS, PTR, ECP
				FROM Batch_Products
				WHERE Product_Code = @SpareCode AND ISNULL(Company_Price, 0) = @SelectedPrice 
				AND isnull(purchaseprice, 0) = isnull(@SelectedPurchasePrice, 0) 
				AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
				And isnull(Free, 0) = @FreeRow
			END
			else
			BEGIN
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, 
				TaxSuffered, BatchReference, PTS, PTR, ECP
				FROM Batch_Products
				WHERE Product_Code = @SpareCode AND ISNULL(ECP, 0) = @SelectedPrice 
				AND isnull(purchaseprice, 0) = isnull(@SelectedPurchasePrice, 0) 
				AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
				And isnull(Free, 0) = @FreeRow
			END
		END 
	END
	else  --- No CSP 
	BEGIN
		IF @TRACK_BATCH = 1  
		BEGIN  
			SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
			WHERE Product_Code = @SpareCode AND ISNULL(Batch_Number, '') = @Batch_Number 
			AND (Expiry >= GetDate() OR Expiry IS NULL) 
			And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			
			DECLARE ReleaseStocks CURSOR KEYSET FOR
			SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, 
			TaxSuffered, BatchReference, PTS, PTR, ECP
			FROM Batch_Products
			WHERE Product_Code = @SpareCode AND ISNULL(Batch_Number, '') = @Batch_Number 
			AND ISNULL(Quantity, 0) > 0  AND (Expiry >= GetDate() OR Expiry IS NULL) 
			AND ISNULL(Damage, 0) = 0 AND isnull(Free, 0) = @FreeRow
		END  
		ELSE   
		BEGIN  
			SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
			WHERE Product_Code = @SpareCode  
			And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			
			DECLARE ReleaseStocks CURSOR KEYSET FOR
			SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, 
			TaxSuffered, BatchReference, PTS, PTR, ECP
			FROM Batch_Products
			WHERE Product_Code = @SpareCode  
			AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
			And isnull(Free, 0) = @FreeRow
		END  
	END
END	
OPEN ReleaseStocks
IF @TOTAL_QUANTITY < @BaseQty
BEGIN
	SET @RETVAL = 0
	GOTO OVERNOUT
END
ELSE
BEGIN
	SET @RETVAL = 1
END
FETCH FROM ReleaseStocks into @Batch_Number, @BATCH_CODE, @QUANTITY, @COST, 
	@BATCHTAXSUFFERED, @ReferenceBatch, @PTS, @PTR, @MRP

WHILE @@FETCH_STATUS = 0
BEGIN
	if IsNull(@VatExist, 0) <> 0 or IsNull(@CollectTaxSuffered, 0) = 0 set @BATCHTAXSUFFERED = 0
	set @claimprice = @SalePrice
	If IsNull(@FreeRow, 0) <> 0 and isnull(@ClaimPrice, 0) = 0 and  isnull(@CAPTURE_PRICE, 0) <> 0
	begin
		select @ClaimPrice = (Case @CUSTOMERTYPE when 3 then ISNULL(Company_Price, 0) else  isnull(ecp, 0) end)
		from Batch_Products Where Batch_Code = isnull(@ReferenceBatch, 0)
	end 
	else if isnull(@UOMPrice, 0) = 0 and isnull(@ClaimPrice, 0) = 0
	begin
		Select @ClaimPrice = (Case @CUSTOMERTYPE when 3 then ISNULL(Company_Price, 0) else  isnull(ecp, 0) end)
		FROM Items WHERE Product_code = @SpareCode
	end

    IF @QUANTITY >= @BaseQty
	BEGIN 
		Set @UOMqty = @BaseQty/@UOMConvertor
		Insert into IssueDetail (IssueID, Product_Code, Product_Specification1, 
		SpareCode, Batch_Code, Batch_Number, Warranty, WarrantyNo, DateofSale, 
		UOM, UOMQty, SalePrice, TaxSuffered_Percentage, SaleTax_Percentage, 
		IssuedQty, UOMPrice, TaxID, ReferenceID, PurchasePrice, PersonnelID, 
		Claim_price, Vat_Exists, CollectTaxSuffered_Spares, PTS, PTR, MRP)
		Values  
		(@IssueID, @Product_Code, @Product_Specification1, 
		@SpareCode, @Batch_Code, @Batch_Number, @Warranty, @WarrantyNo, @DateofSale, 
		@UOM, @UOMQty, (case  when isnull(@Warranty, 0) <> 1 then @SalePrice else 0 end), 
		@BATCHTAXSUFFERED, @SaleTaxPercentage, 
		@BaseQty,@UOMPrice, @SaleTaxCode, @JCSerialNo, @COST, @PersonnelID, 
		@ClaimPrice, @VatExist, @CollectTaxSuffered, Isnull(@PTS, 0), IsNull(@PTR, 0), 
		IsNull(@MRP, 0))

		Set @SerialNo = @@Identity
		/*TaxType = 2 for spare tax type */ 
		if isnull(@UOMPrice, 0) > 0
		begin
			Insert into IssueTaxComponent
			(SerialNo, TaxType, TaxCode, TaxComponent_Code, Tax_Percentage, Rate_Percentage, Tax_Value)
			Select @SerialNo, 2, Tax_Code, TaxComponent_Code, Tax_Percentage, sp_Percentage, 
			((sp_Percentage * @SalePrice) / 100) From taxcomponents 
			Where Tax_Code = @SALETAXCODE and 
			Isnull(LST_Flag, 0) = (Case Isnull(@Locality, 0) when 2 then 0 else 1 end)
		end

		UPDATE Batch_Products SET Quantity = Quantity - @BaseQty
		WHERE Batch_Code = @BATCH_CODE

		IF @@ROWCOUNT = 0
		BEGIN
			SET @RETVAL = 1
			GOTO OVERNOUT
		END
        GOTO OVERNOUT
	END
    ELSE
	BEGIN
		set @BASEQty = @BaseQty - @QUANTITY
		Set @UOMqty = @QUANTITY/@UOMConvertor
	        Insert into IssueDetail (IssueID, Product_Code, Product_Specification1, 
		SpareCode, Batch_Code, Batch_Number, Warranty, WarrantyNo, DateofSale, 
		UOM, UOMQty, SalePrice, TaxSuffered_Percentage, SaleTax_Percentage, 
		IssuedQty, UOMPrice, TaxID, ReferenceID, PurchasePrice, PersonnelID, 
		Claim_Price, Vat_Exists, CollectTaxSuffered_Spares, PTS, PTR, MRP)
		Values  
		(@IssueID, @Product_Code, @Product_Specification1, 
		@SpareCode, @Batch_Code, @Batch_Number, @Warranty, @WarrantyNo, @DateofSale, 
		@UOM, @UOMQty, (case  when Isnull(@Warranty, 0) <> 1 then @SalePrice else 0 end), 
		@BATCHTAXSUFFERED, @SaleTaxPercentage, 
		@Quantity, @UOMPrice, @SaleTaxCode, @JCSerialNo, @Cost, @PersonnelID, @ClaimPrice, 
		@VatExist, @CollectTaxSuffered, Isnull(@PTS, 0), IsNull(@PTR, 0), 
		IsNull(@MRP, 0))

		Set @SerialNo = @@Identity
		/*TaxType = 2 for spare tax type */ 
		if isnull(@UOMPrice, 0) > 0
		begin
			Insert into IssueTaxComponent
			(SerialNo, TaxType, TaxCode, TaxComponent_Code, Tax_Percentage, Rate_Percentage, Tax_Value)
			Select @SerialNo, 2, Tax_Code, TaxComponent_Code, Tax_Percentage, sp_Percentage, 
			((sp_Percentage * @SalePrice) / 100) From taxcomponents 
			Where Tax_Code = @SALETAXCODE and 
			Isnull(LST_Flag, 0) = (Case Isnull(@Locality, 0) when 2 then 0 else 1 end)
		end
		UPDATE Batch_Products SET Quantity = 0 where Batch_Code = @BATCH_CODE
		IF @@ROWCOUNT = 0
		BEGIN
			SET @RETVAL = 1
			GOTO OVERNOUT
		END	
	END 
    FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST,  
		@BATCHTAXSUFFERED, @ReferenceBatch, @PTS, @PTR, @MRP
END
OVERNOUT:
CLOSE ReleaseStocks
DEALLOCATE ReleaseStocks

ALL_SAID_AND_DONE:
SELECT @RETVAL



