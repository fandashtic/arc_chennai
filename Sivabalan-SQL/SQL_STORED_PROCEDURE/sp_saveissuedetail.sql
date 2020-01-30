CREATE Procedure sp_saveissuedetail(
	@IssueID int,
	@Product_Code NVARCHAR(15),
	@Product_Specification1 NVARCHAR(255), 
	@SpareCode nvarchar(15),
	@Batch_Number nvarchar(50), 
	@UOM int, 
	@UOMQTY Decimal(18,6),
	@Warranty int,
	@WarrantyNo nvarchar(50), 	
	@DateofSale Datetime,
	@SalePrice Decimal(18,6),
	@SelectedPrice Decimal(18,6), 
	@TaxSuffered Decimal (18,6), 
	@BaseQty int, -- Issued UOM Base qty
	@FreeRow int,
	@Track_Batch int,
	@Track_Inventory int, 
	@Capture_price int,
	@UOMPrice Decimal(18,6),	
	@UOMConvertor Decimal(18,6),
	@CustomerID nvarchar(15), @JobcardID int, @JCSerialNo int,
				      @OpeningDate datetime = Null,
				      @BackDatedTransaction int = 0)
AS
DECLARE @QUANTITY Decimal(18,6) 
DECLARE @SALETAXCODE int
DECLARE @SALETAXPERCENTAGE int
DECLARE @BATCHTAXSUFFERED Decimal (18,6)
DECLARE @LOCALITY int
DECLARE @TOTAL_QUANTITY Decimal(18,6)
DECLARE @MRP Decimal(18,6)
DECLARE @BATCH_CODE int 
DECLARE @CUSTOMERTYPE int
DECLARE @RETVAL Decimal(18,6)
DECLARE @COST Decimal(18,6) 
DECLARE @PENDINGQTY Decimal(18,6)
DECLARE @DIFF Decimal(18,6)
/* JobCardSpares 
	if there is JCSerialNo 
		Updation take into action till the pending quantity, 
		excess will be inserted 
	else Inserts new row   */
If @JCSerialNo > 0  
begin 
	Select @PENDINGQTY =  PendingQty from JobcardSpares Where SerialNo = @JCSerialNo
	If (@PENDINGQTY > @BaseQty)  
		Update JobCardSpares Set PendingQty = PendingQty - @BaseQty, SpareStatus = 0
		where  SerialNo = @JCSerialNo
	else
	begin
		Update JobCardSpares Set PendingQty = 0, SpareStatus = 1
		where  SerialNo = @JCSerialNo

		Set @PENDINGQTY = @PENDINGQTY - @BaseQty
		If @PENDINGQTY > 0 
		begin
			Set @UOMQty = @PENDINGQTY/@UOMConvertor
			Insert into JobCardSpares (JobCardID, Product_Code, Product_Specification1, SpareCode,  
			UOM, Qty, PendingQty, SpareStatus, Warranty, WarrantyNo, DateofSale) values 
			(@JobcardID, @Product_code, @Product_Specification1, @SpareCode, @UOM, @UOMQty, 
			0, 1, @Warranty, @WarrantyNO, @DateofSale) 
		end 	
	end 
end 
else
begin
	Insert into JobCardSpares (JobCardID, Product_Code, Product_Specification1, SpareCode,  
	UOM, Qty, PendingQty, SpareStatus, Warranty, WarrantyNo, DateofSale) values
	(@JobcardID, @Product_code, @Product_Specification1, @SpareCode, @UOM, @UOMQty, 
	0, 1, @Warranty, @WarrantyNO, @DateofSale) 
end 
/* Batch wise Stock reduction */
Select @LOCALITY = IsNull(Locality,1), @CUSTOMERTYPE = CustomerCategory from customer 
	Where CustomerID = @CustomerID 
SELECT @SALETAXCODE = Sale_Tax FROM Items WHERE Product_code = @SpareCode
IF @LOCALITY = 1
	begin SELECT @SALETAXPERCENTAGE = Percentage FROM Tax WHERE  Tax_Code = @SALETAXCODE end 
ELSE
	begin SELECT @SALETAXPERCENTAGE = ISNULL(CST_Percentage, 0) FROM Tax WHERE  Tax_Code = @SALETAXCODE end 

IF @TRACK_INVENTORY = 0
BEGIN
	SET @RETVAL = 1
	Set @UOMqty = @BaseQty/@UOMConvertor
	Insert into IssueDetail (IssueID, Product_Code, Product_Specification1, 
	SpareCode, Batch_Code, Batch_Number, Warranty, WarrantyNo, DateofSale, 
	UOM, UOMQty, SalePrice, TaxSuffered_Percentage, SaleTax_Percentage, 
	IssuedQty, UOMPrice, TaxID)
	Values  
	(@IssueID, @Product_Code, @Product_Specification1, @SpareCode, 0, @Batch_Number, 
	@Warranty, @WarrantyNo, @DateofSale, @UOM, @UOMQty, @SalePrice, @TaxSuffered, 
	@SALETAXPERCENTAGE, @BaseQty, @UOMPrice, @SALETAXCODE)
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
				WHERE Product_Code = @SpareCode AND ISNULL(Batch_Number, N'') = @Batch_Number
				AND ISNULL(Company_Price, 0) = @SelectedPrice AND 
				(Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0 
				And isnull(Free, 0) = @FreeRow
			Else
				SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
				WHERE Product_Code = @SpareCode AND 
				ISNULL(Batch_Number, N'') = @Batch_Number AND 
				ISNULL(ECP, 0) = @SelectedPrice AND (Expiry >= GetDate() OR Expiry IS NULL) 
				And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
	
	
			IF @CUSTOMERTYPE = 3
			BEGIN
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, ECP, TaxSuffered
				FROM Batch_Products
				WHERE Product_Code = @SpareCode and ISNULL(Batch_Number, N'') = @Batch_Number 
				and ISNULL(Company_Price, 0) = @SelectedPrice AND ISNULL(Quantity, 0) > 0 
				AND (Expiry >= GetDate() OR Expiry IS NULL) 
				And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			END
			Else
			BEGIN
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, ECP, TaxSuffered
				FROM Batch_Products
				WHERE Product_Code = @SpareCode 
				and ISNULL(Batch_Number, N'') = @Batch_Number 
				and ISNULL(ECP, 0) = @SelectedPrice AND ISNULL(Quantity, 0) > 0 
				AND (Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0
				And isnull(Free, 0) = @FreeRow
			END
		END
		ELSE
		BEGIN   
			IF @CUSTOMERTYPE = 3
				SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
				WHERE Product_Code = @SpareCode AND ISNULL(Company_Price, 0) = @SelectedPrice 
				And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			else
				SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
				WHERE Product_Code = @SpareCode AND ISNULL(ECP, 0) = @SelectedPrice 
				And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
		
			IF @CUSTOMERTYPE = 3
			BEGIN
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, ECP, TaxSuffered
				FROM Batch_Products
				WHERE Product_Code = @SpareCode AND ISNULL(Company_Price, 0) = @SelectedPrice 
				AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 
				And isnull(Free, 0) = @FreeRow
			END
			else
			BEGIN
				DECLARE ReleaseStocks CURSOR KEYSET FOR
				SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, ECP, TaxSuffered
				FROM Batch_Products
				WHERE Product_Code = @SpareCode AND ISNULL(ECP, 0) = @SelectedPrice 
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
			WHERE Product_Code = @SpareCode AND 
			ISNULL(Batch_Number, N'') = @Batch_Number AND 
			ISNULL(ECP, 0) = @SelectedPrice AND (Expiry >= GetDate() OR Expiry IS NULL) 
			And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			
			DECLARE ReleaseStocks CURSOR KEYSET FOR
			SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, ECP, TaxSuffered
			FROM Batch_Products
			WHERE Product_Code = @SpareCode 
			and ISNULL(Batch_Number, N'') = @Batch_Number 
			and ISNULL(ECP, 0) = @SelectedPrice AND ISNULL(Quantity, 0) > 0 
			AND (Expiry >= GetDate() OR Expiry IS NULL) And ISNULL(Damage, 0) = 0
			And isnull(Free, 0) = @FreeRow
		END  
		ELSE   
		BEGIN  
			SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products 
			WHERE Product_Code = @SpareCode  
			And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow
			
			DECLARE ReleaseStocks CURSOR KEYSET FOR
			SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice, ECP, TaxSuffered
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
FETCH FROM ReleaseStocks into @Batch_Number, @BATCH_CODE, @QUANTITY, @COST, @MRP, @BATCHTAXSUFFERED

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @QUANTITY >= @BaseQty
	BEGIN 
		Set @UOMqty = @BaseQty/@UOMConvertor
		Insert into IssueDetail (IssueID, Product_Code, Product_Specification1, 
		SpareCode, Batch_Code, Batch_Number, Warranty, WarrantyNo, DateofSale, 
		UOM, UOMQty, SalePrice, TaxSuffered_Percentage, SaleTax_Percentage, 
		IssuedQty, UOMPrice, TaxID)
		Values  
		(@IssueID, @Product_Code, @Product_Specification1, @SpareCode, @Batch_Code, 
		@Batch_Number, @Warranty,
		@WarrantyNo, @DateofSale, @UOM, @UOMQty, @SalePrice, @BATCHTAXSUFFERED, 
		@SaleTaxPercentage, @BaseQty,@UOMPrice, @SaleTaxCode)

	        UPDATE Batch_Products SET Quantity = Quantity - @BaseQty
	        WHERE Batch_Code = @BATCH_CODE

		IF @@ROWCOUNT = 0
		BEGIN
			SET @RETVAL = 1
			GOTO OVERNOUT
		END
		IF @BackDatedTransaction = 1 
		BEGIN
			SET @DIFF = 0 - @BaseQty
			exec sp_ser_update_opening_stock @SpareCode, @OpeningDate, @DIFF, @FreeRow, @COST
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
		IssuedQty, UOMPrice, TaxID)
		Values  
		(@IssueID, @Product_Code, @Product_Specification1, @SpareCode, @Batch_Code, 
		@Batch_Number, @Warranty,
		@WarrantyNo, @DateofSale, @UOM, @UOMQty, @SalePrice, @BATCHTAXSUFFERED, 
		@SaleTaxPercentage, @Quantity,@UOMPrice, @SaleTaxCode)

		UPDATE Batch_Products SET Quantity = 0 where Batch_Code = @BATCH_CODE
		IF @@ROWCOUNT = 0
		BEGIN
			SET @RETVAL = 1
			GOTO OVERNOUT
		END	
		IF @BackDatedTransaction = 1 
		BEGIN
			SET @DIFF = 0 - @QUANTITY
			exec sp_ser_update_opening_stock @SpareCode, @OpeningDate, @DIFF, @FreeRow, @COST
		END
	END 
    FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST,  @MRP, @BATCHTAXSUFFERED
END
OVERNOUT:
CLOSE ReleaseStocks
DEALLOCATE ReleaseStocks

ALL_SAID_AND_DONE:
	

SELECT @RETVAL


