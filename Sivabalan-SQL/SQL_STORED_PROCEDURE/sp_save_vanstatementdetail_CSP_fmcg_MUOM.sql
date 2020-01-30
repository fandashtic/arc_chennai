CREATE Procedure sp_save_vanstatementdetail_CSP_fmcg_MUOM(@DOCUMENT_ID int,  
          @ITEM_CODE NVARCHAR(15),  
          @BATCH_NUMBER NVARCHAR(255),   
          @SALE_PRICE Decimal(18,6),   
          @REQUIRED_QUANTITY Decimal(18,6),  
          @TRACK_BATCHES int,  
          @TRACK_INVENTORY int,  
          @TOTAL_AMOUNT Decimal(18,6),  
          @BFQTY Decimal(18,6),  
          @ORIG_BATCH int = 0,  
          @ORIG_PRICE Decimal(18,6) = 0,  
          @FreeRow int = 0,
		  @UOM int,  -- CHANGED FOR M_UOM  
          @UOMQTY Decimal(18,6),  
          @UOMPRICE Decimal(18,6),  

		  @DocSerial int = 0,   --VanTransferDetail DocSerial
		  @Serial int=0, 		--Serial No for VanTransferDetail items
		  @FromVan int=0,	    --From VanStatementID
		  @TrnType int=3) 		--3-VanStatementDetail  0-Godown to Van 
								--1- Van to Van  	    2-Van to Godown

AS  
DECLARE @BATCH_CODE int   
DECLARE @QUANTITY Decimal(18,6)  
DECLARE @RETVAL Decimal(18,6)  
DECLARE @TOTAL_QUANTITY Decimal(18,6)  
DECLARE @PENDING_QTY Decimal(18,6)  
DECLARE @COST Decimal(18,6)  

DECLARE @ID int  			  --get identity column of vanstatementdetail for updation

  
SELECT @COST = Purchase_Price FROM Items where Product_Code = @ITEM_CODE  
SET @PENDING_QTY = @REQUIRED_QUANTITY  
IF @TRACK_INVENTORY = 0  
BEGIN  
 SET @RETVAL = 1  
	   if @TrnType<>3   		  --Godown to van
	   begin
			Insert into VanTransferDetail
					(DocSerial, Product_Code, BatchCode, BatchNumber,
					 Quantity, Saleprice, Value,Serial,UOMID,UOMQty,UOMPrice)
			Values(
					@DocSerial, @ITEM_CODE, 0, @BATCH_NUMBER, 
					@REQUIRED_QUANTITY, @SALE_PRICE, @TOTAL_AMOUNT,@Serial,@UOM,@UOMQTY,@UOMPRICE)
		end
		if @TrnType<>2
		begin     	
			 INSERT INTO VanStatementDetail(DocSerial, Product_Code, Batch_Code, Batch_Number,   
			 Quantity, Pending, SalePrice, Amount, BFQty, PurchasePrice, UOM, UOMQty, UOMPrice,TransferQty,VanTransferID,TransferItemSerial)  
			 VALUES (@DOCUMENT_ID, @ITEM_CODE, 0, @BATCH_NUMBER, @REQUIRED_QUANTITY,   
			 @REQUIRED_QUANTITY, @SALE_PRICE, @TOTAL_AMOUNT, @BFQTY, @COST, @UOM, @UOMQTY, @UOMPRICE, @REQUIRED_QUANTITY, @DocSerial, @Serial)
		end

 GOTO ALL_SAID_AND_DONE  
END  
IF @TrnType=3 
Begin
	IF @BFQTY > 0   
	Update Batch_Products SET Quantity = Quantity + @BFQTY WHERE Batch_Code = @ORIG_BATCH  
End
IF @TRACK_BATCHES = 1  
 BEGIN  
	if (@TrnType=1 Or @TrnType=2)
		SELECT @TOTAL_QUANTITY = ISNULL(SUM(Pending), 0) FROM VanstatementDetail
		WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
		AND DocSerial=@FromVan AND ISNULL(SalePrice,0)=@ORIG_PRICE
	else
		 SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
		 WHERE Product_Code = @ITEM_CODE AND ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
		 AND ISNULL(SalePrice, 0) = @ORIG_PRICE AND (Expiry >= GetDate() OR Expiry IS NULL)   
		 And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
 
	if (@TrnType = 1 or @TrnType=2)    --Cursor for VanstatemntDetail
		DECLARE ReleaseStocks CURSOR KEYSET FOR
		SELECT Batch_Number, Batch_Code, Pending, PurchasePrice,[ID] FROM VanStatementDetail
		WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER 
		AND DocSerial=@FromVan AND ISNULL(Pending, 0) > 0 and ISNULL(SalePrice, 0) = @ORIG_PRICE 
	else
		 DECLARE ReleaseStocks CURSOR KEYSET FOR  
		 SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice,0 FROM Batch_Products  
		 WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER   
		 and ISNULL(SalePrice, 0) = @ORIG_PRICE AND ISNULL(Quantity, 0) > 0   
		 AND (Expiry >= GetDate() OR Expiry IS NULL)   
		 And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
END  
ELSE  
 BEGIN  
	if (@TrnType=1 Or @TrnType=2)
		SELECT @TOTAL_QUANTITY = ISNULL(SUM(Pending), 0) FROM VanstatementDetail
		WHERE Product_Code = @ITEM_CODE AND DocSerial=@FromVan AND ISNULL(Saleprice, 0) = @ORIG_PRICE 
	Else
		 SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity), 0) FROM Batch_Products   
		 WHERE Product_Code = @ITEM_CODE AND ISNULL(SalePrice, 0) = @ORIG_PRICE   
		 And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
	if (@TrnType=1 or @TrnType=2)
		begin
			DECLARE ReleaseStocks CURSOR KEYSET FOR
			SELECT Batch_Number, Batch_Code, Pending, PurchasePrice,[ID] FROM VanStatementDetail
			WHERE Product_Code = @ITEM_CODE AND DocSerial=@FromVan AND ISNULL(Saleprice, 0) = @ORIG_PRICE 
			AND ISNULL(Pending, 0) > 0
		end
	else
		begin
			 DECLARE ReleaseStocks CURSOR KEYSET FOR  
			 SELECT Batch_Number, Batch_Code, Quantity, PurchasePrice,0 FROM Batch_Products  
			 WHERE Product_Code = @ITEM_CODE AND ISNULL(SalePrice, 0) = @ORIG_PRICE   
			 AND ISNULL(Quantity, 0) > 0 And ISNULL(Damage, 0) = 0 And isnull(Free, 0) = @FreeRow  
		end
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
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST, @ID  
  
WHILE @@FETCH_STATUS = 0  
BEGIN  
	IF @QUANTITY >= @REQUIRED_QUANTITY  
	BEGIN  
	      if @TrnType=1 	  --Van to Van (Updation for from van)
		    UPDATE VanStatementDetail SET Pending = Pending - @REQUIRED_QUANTITY
	        WHERE [ID]=@ID
		  else if @TrnType=2    --Van to Godown(only two updations)
		  begin	
	        UPDATE VanStatementDetail SET Pending = Pending - @REQUIRED_QUANTITY
	        WHERE [ID]=@ID
	        UPDATE Batch_Products SET Quantity = Quantity + @REQUIRED_QUANTITY
	        WHERE Batch_Code = @BATCH_CODE
		  End
		  Else					--type 0 and 3
		    UPDATE Batch_Products SET Quantity = Quantity - @REQUIRED_QUANTITY
	        WHERE Batch_Code = @BATCH_CODE

 IF @@ROWCOUNT = 0  
 BEGIN  
  SET @RETVAL = 1  
  GOTO OVERNOUT  
 END  
	    if @TrnType<>3   		  --Godown to van
		begin
			Insert into VanTransferDetail
					(DocSerial, Product_Code, BatchCode, BatchNumber,
					 Quantity, Saleprice, Value,Serial,UOMID,UOMQty,UOMPrice)
			Values(
					@DocSerial, @ITEM_CODE,  @BATCH_CODE, @BATCH_NUMBER, 
					@REQUIRED_QUANTITY, @SALE_PRICE,@TOTAL_AMOUNT,@Serial,@UOM,@UOMQTY,@UOMPRICE)
		end
		if @TrnType<>2
		begin     	
			 INSERT INTO VanStatementDetail(DocSerial, Product_Code, Batch_Code, Batch_Number,   
			 Quantity, Pending, SalePrice, Amount, BFQty, PurchasePrice, UOM, UOMQty, UOMPrice,TransferQty,VanTransferID,TransferItemSerial)
			 VALUES (@DOCUMENT_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @REQUIRED_QUANTITY,   
			 @PENDING_QTY, @SALE_PRICE, @TOTAL_AMOUNT, @BFQTY, @COST, @UOM, @UOMQTY, @UOMPRICE, @REQUIRED_QUANTITY, @DocSerial, @Serial)  
		end

     GOTO OVERNOUT  
 END  
    ELSE  
 BEGIN  
 set @REQUIRED_QUANTITY = @REQUIRED_QUANTITY - @QUANTITY  

 	If @TrnType=1 
		UPDATE VanStatementDetail SET Pending = 0 where [ID]=@ID
	Else if @TrnType=2
	Begin
		UPDATE VanStatementDetail SET Pending = 0 where [ID]=@ID
		UPDATE Batch_Products SET Quantity = Quantity + @Quantity where Batch_Code = @BATCH_CODE
    End
	Else
		UPDATE Batch_Products SET Quantity = 0 where Batch_Code = @BATCH_CODE

 IF @@ROWCOUNT = 0  
 BEGIN  
  SET @RETVAL = 1  
  GOTO OVERNOUT  
 END  
	if @TrnType<>3   		  --Godown to van
		begin
			Insert into VanTransferDetail
					(DocSerial, Product_Code, BatchCode, BatchNumber,
					 Quantity, Saleprice, Value,Serial,UOMID,UOMQty,UOMPrice)
			Values(
					@DocSerial, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, 
					@REQUIRED_QUANTITY, @SALE_PRICE,@TOTAL_AMOUNT,@Serial,@UOM,@UOMQTY,@UOMPRICE)
		end
	if @TrnType<>2
		begin     	
			 INSERT INTO VanStatementDetail(DocSerial, Product_Code, Batch_Code, Batch_Number,   
			 Quantity, Pending, SalePrice, Amount, BFQty, PurchasePrice, UOM, UOMQty, UOMPrice,TransferQty,VanTransferID,TransferItemSerial)  
			 VALUES (@DOCUMENT_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @QUANTITY, @PENDING_QTY,   
			 @SALE_PRICE, @TOTAL_AMOUNT, @BFQTY, @COST, @UOM, @UOMQTY, @UOMPRICE,@QUANTITY, @DocSerial, @Serial)
		end
 SET @TOTAL_AMOUNT = 0  

 SET @PENDING_QTY = 0  
 SET @BFQTY = 0  
 END   
    FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY, @COST,@ID
END  
OVERNOUT:  
CLOSE ReleaseStocks  
DEALLOCATE ReleaseStocks  
ALL_SAID_AND_DONE:  
SELECT @RETVAL  



