CREATE Procedure sp_save_AdjReturndetail_BT (@ADJUSTMENTID INT,        
	@ITEM_CODE NVARCHAR(15),        
	@BATCH_NUMBER NVARCHAR(255),         
	@RATE Decimal(18,6),         
	@REQUIRED_QUANTITY Decimal(18,6),        
	@REASONID INT,        
	@TRACK_BATCHES INT,        
	@BillID int,        
	@FreeRow Int = 0,        
	@OpeningDate datetime = Null,        
	@BackDatedTransaction int = 0,        
	@TaxSuffered decimal(18,6) ,         
	@Total_Value decimal(18,6),        
	@ApplicableOn Int =0,        
	@PartOff Decimal(18,6)=0, 
	@VAT int = 0, 
	@TaxAmount Decimal(18,6) = 0,                       
	@BatchPrice Decimal (18, 6)=0,  
	@BatchTax Decimal (18, 6)=0,   
	@BatchTaxApplicableOn Int=0,   
	@BatchTaxPartOff Decimal(18, 6)=0,
	@SerialNo int = 0)  
AS        
DECLARE @BATCH_CODE INT         
DECLARE @QUANTITY Decimal(18,6)        
DECLARE @RETVAL Decimal(18,6)        
DECLARE @TOTAL_QUANTITY Decimal(18,6)        
DECLARE @DIFF Decimal(18,6)        
        
IF @TRACK_BATCHES = 1        
BEGIN        
	SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity),0) FROM Batch_Products         
	WHERE Product_Code = @ITEM_CODE AND Batch_Number = @BATCH_NUMBER         
	AND ISNULL(PurchasePrice,0) = @BatchPrice And isnull(Free, 0) = @FreeRow        
	And Quantity > 0 And IsNull(Damage, 0) = 0 And IsNull(TaxSuffered,0) = @BatchTax    
	And IsNull(ApplicableOn,0) = @BatchTaxApplicableOn And IsNull(PartOfPercentage,0) = @BatchTaxPartOff       
	    
	DECLARE ReleaseStocks CURSOR KEYSET FOR        
	SELECT Batch_Number, Batch_Code, Quantity FROM Batch_Products        
	WHERE Product_Code = @ITEM_CODE and Batch_Number = @BATCH_NUMBER         
	and ISNULL(PurchasePrice, 0) = @BatchPrice And isnull(Free, 0) = @FreeRow        
	And Quantity > 0 And IsNull(Damage, 0) = 0 And IsNull(TaxSuffered,0) = @BatchTax        
	And IsNull(ApplicableOn,0) = @BatchTaxApplicableOn And IsNull(PartOfPercentage,0) = @BatchTaxPartOff       
	    
END        
ELSE        
BEGIN        
	SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity),0) FROM Batch_Products         
	WHERE Product_Code = @ITEM_CODE and ISNULL(PurchasePrice, 0) = @BatchPrice         
	And isnull(Free, 0) = @FreeRow And Quantity > 0 And IsNull(Damage, 0) = 0        
	And IsNull(TaxSuffered,0) = @BatchTax     
	And IsNull(ApplicableOn,0) = @BatchTaxApplicableOn And IsNull(PartOfPercentage,0) = @BatchTaxPartOff       
	   
	    
	DECLARE ReleaseStocks CURSOR KEYSET FOR        
	SELECT Batch_Number, Batch_Code, Quantity FROM Batch_Products        
	WHERE Product_Code = @ITEM_CODE AND ISNULL(PurchasePrice, 0) = @BatchPrice         
	And isnull(Free, 0) = @FreeRow And Quantity > 0 And IsNull(Damage, 0) = 0         
	And IsNull(TaxSuffered,0) = @BatchTax    
	And IsNull(ApplicableOn,0) = @BatchTaxApplicableOn And IsNull(PartOfPercentage,0) = @BatchTaxPartOff            
END        
        
OPEN ReleaseStocks        
IF @TOTAL_QUANTITY < @REQUIRED_QUANTITY        
BEGIN        
	SET @RETVAL = 0        
	GOTO OVERNOUT        
END        
ELSE        
BEGIN        
	SET @RETVAL = 1        
END        
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY        
        
WHILE @@FETCH_STATUS = 0        
BEGIN        
	IF @QUANTITY >= @REQUIRED_QUANTITY        
	BEGIN        
		UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY        
		WHERE Batch_Code = @BATCH_CODE               
		INSERT INTO AdjustmentReturnDetail(AdjustmentID, Product_Code,         
		BatchNumber, BatchCode, Quantity, Rate,ReasonID, BillID, Tax, Total_Value,        
		TaxSuffApplicableOn,TaxSuffPartOff,VAT,TaxAmount, BatchPrice,BatchTax,BatchTaxApplicableOn,BatchTaxPartOff,
		SerialNo)  
		VALUES (@ADJUSTMENTID, @ITEM_CODE,@BATCH_NUMBER, @BATCH_CODE, @REQUIRED_QUANTITY,         
		@RATE,@REASONID, @BillID, @TaxSuffered, @Total_Value,        
		@ApplicableOn , @PartOff, @VAT ,@TaxAmount, @BatchPrice, @BatchTax, @BatchTaxApplicableOn, 
		@BatchTaxPartOff, @SerialNo)                        		    

		IF @BackDatedTransaction = 1         
		BEGIN        
			SET @DIFF = 0 - @REQUIRED_QUANTITY        
			exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @BatchPrice        
		END        
		GOTO OVERNOUT        
	END        
	ELSE        
	BEGIN  
		set @REQUIRED_QUANTITY = @REQUIRED_QUANTITY - @QUANTITY        
		UPDATE Batch_Products SET Quantity = 0 where Batch_Code = @BATCH_CODE        
		INSERT INTO AdjustmentReturnDetail(AdjustmentID, Product_Code, BatchNumber,         
		BatchCode, Quantity, Rate,ReasonID, BillID, Tax, Total_Value,        
		TaxSuffApplicableOn , TaxSuffPartOff,VAT,TaxAmount, BatchPrice,BatchTax, 
		BatchTaxApplicableOn, BatchTaxPartOff, SerialNo)                       
		VALUES (@ADJUSTMENTID, @ITEM_CODE, @BATCH_NUMBER,@BATCH_CODE, @QUANTITY,         
		@RATE,@REASONID, @BillID, @TaxSuffered, @Total_Value,        
		@ApplicableOn , @PartOff, @VAT,@TaxAmount, @BatchPrice, @BatchTax, 
		@BatchTaxApplicableOn, @BatchTaxPartOff, @SerialNo)                       

		SET @Total_Value = 0
		SET	@TaxAmount = 0
		IF @BackDatedTransaction = 1         
		BEGIN        
			SET @DIFF = 0 - @QUANTITY        
			exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @BatchPrice        
		END        
	END         
	FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY        
END        
OVERNOUT:        
CLOSE ReleaseStocks        
DEALLOCATE ReleaseStocks        
SELECT @RETVAL        


