CREATE procedure [dbo].[sp_Save_RetailInvoiceDetail_return_FMCG_MUOM] (@INVOICE_ID int,          
          @ITEM_CODE NVARCHAR(30),          
          @BATCH_NUMBER NVARCHAR(255),           
          @SALE_PRICE Decimal(18,6),           
          @REQUIRED_QUANTITY Decimal(18,6),          
          @SALE_TAX Decimal(18,6),          
          @DISCOUNT_PER Decimal(18,6),           
          @DISCOUNT_AMOUNT Decimal(18,6),          
          @AMOUNT Decimal(18,6),            
          @TRACK_BATCHES int,          
          @BATCH_PRICE Decimal(18,6),          
          @STPAYABLE Decimal(18,6),          
		    @SCHEMEID int,          
    		 @PRIMARY_QUANTITY Decimal(18,6),          
          @SCHEME_COST Decimal(18,6),          
          @FLAG int,          
          @TAXCODE2 float,          
          @CSTPAYABLE Decimal(18,6),          
          @TAXSUFFERED Decimal(18,6) = 0,          
          @TAXSUFFERED2 Decimal(18,6) = 0,          
          @FreeRow Decimal(18,6) = 0,          
          @OpeningDate datetime = Null,          
          @BackDatedTransaction int = 0,        
 		    @UOM int,         
		    @UOMQty Decimal(18, 6),         
		    @UOMPrice Decimal(18, 6) )          
AS          
DECLARE @BATCH_CODE int           
DECLARE @COST Decimal(18,6)          
DECLARE @SALEID int          
DECLARE @MRP Decimal(18,6)          
DECLARE @TAXID int          
DECLARE @DIFF Decimal(18,6)          
DECLARE @LOCALITY int          
DECLARE @SECONDARY_SCHEME int          
DECLARE @InvType int        
DECLARE @PriceOption int        
DECLARE @EXPIRY datetime        
DECLARE @PKD_DATE datetime        
DECLARE @TAXSUFFERED_ORIG Decimal(18, 6)        
DECLARE @IS_VAT_ITEM Int
DECLARE @ADD_TAXSUFF_TO_OPDET int
Set @ADD_TAXSUFF_TO_OPDET = 0

select @InvType=InvoiceType from InvoiceAbstract nolock where InvoiceId=@INVOICE_ID        
select @PriceOption=Price_Option from items,itemcategories 
where items.categoryID=itemcategories.categoryID
And items.Product_Code = @ITEM_CODE
--5-salable return 6-damage        
        
Select @LOCALITY = IsNull(case InvoiceType When 2 Then 1 Else Locality End, 0) From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID *= Customer.CustomerID And InvoiceID = @INVOICE_ID          
IF @LOCALITY = 0 SET @LOCALITY = 1          
IF @LOCALITY = 1          
	SELECT @TAXID = Tax_Code FROM Tax WHERE Percentage = @SALE_TAX          
ELSE          
 	SELECT @TAXID = Tax_Code FROM Tax WHERE ISNULL(CST_Percentage, 0) = @TAXCODE2          
          
IF @TRACK_BATCHES = 1          
	begin        
	if @PriceOption=1        
		Begin          
		DECLARE ReleaseStocks CURSOR KEYSET FOR          
		SELECT Batch_Number, Batch_Code , PurchasePrice, expiry, PKD, TaxSuffered FROM Batch_Products          
		WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER           
		and ISNULL(SalePrice, 0) = @BATCH_PRICE And ISNULL(Damage, 0) = 0           
		AND (Expiry >= GetDate() OR Expiry IS NULL) And (isnull(Free, 0) = @FreeRow or @FreeRow = 1)    
		Order by Free Desc    
		End          
	else        
		begin        
		DECLARE ReleaseStocks CURSOR KEYSET FOR          
		SELECT Batch_Number, Batch_Code , PurchasePrice, expiry, PKD, TaxSuffered FROM Batch_Products          
		WHERE Product_Code = @ITEM_CODE and ISNULL(Batch_Number, N'') = @BATCH_NUMBER           
		And ISNULL(Damage, 0) = 0 AND (Expiry >= GetDate() OR Expiry IS NULL)     
		And (isnull(Free, 0) = @FreeRow or @FreeRow = 1) Order by Free Desc    
		end        
	end        
Else          
	Begin          
	if @PriceOption=1        
		begin          
		DECLARE ReleaseStocks CURSOR KEYSET FOR          
		SELECT Batch_Number, Batch_Code, PurchasePrice, expiry, PKD, TaxSuffered FROM Batch_Products          
		WHERE Product_Code = @ITEM_CODE AND ISNULL(SalePrice, 0) = @BATCH_PRICE           
		And ISNULL(Damage, 0) = 0 And (isnull(Free, 0) = @FreeRow or @FreeRow = 1) Order by Free Desc    
		end        
	else        
		begin        
		DECLARE ReleaseStocks CURSOR KEYSET FOR          
		SELECT Batch_Number, Batch_Code, PurchasePrice, expiry, PKD, TaxSuffered FROM Batch_Products          
		WHERE Product_Code = @ITEM_CODE        
		And ISNULL(Damage, 0) = 0 And (isnull(Free, 0) = @FreeRow or @FreeRow = 1) Order by Free Desc    
		end        
	end         
         
SELECT @SALEID = SaleID, @COST = Purchase_Price, @MRP = MRP FROM Items           
WHERE Product_Code = @ITEM_CODE          
SET @COST = @COST          
IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST * @REQUIRED_QUANTITY        
set @SCHEME_COST = @SCHEME_COST * (-1)        
OPEN ReleaseStocks          
FETCH FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @COST, @EXPIRY,@PKD_DATE,@TAXSUFFERED_ORIG         
        
if @InvType=5         
	begin          
	IF Exists (Select * from Batch_Products Where Batch_Code = @Batch_Code And IsNull(DocType,0) = 3 And IsNull(DocID,0) = 0 AND IsNull(QuantityReceived,0)=0)
		Begin 
		Set @ADD_TAXSUFF_TO_OPDET = 1
		Update Batch_Products Set Quantity = Quantity + @REQUIRED_QUANTITY, 
		QuantityReceived = @REQUIRED_QUANTITY, DocId=@INVOICE_ID
		WHERE Batch_Code = @BATCH_CODE  
		End 
	Else
		Begin
		UPDATE Batch_Products SET Quantity = Quantity + @REQUIRED_QUANTITY          
		WHERE Batch_Code = @BATCH_CODE          
		End
	end        
else if @InvType=6        
	begin        
	INSERT INTO Batch_Products(Product_Code, Batch_Number, Expiry, Quantity,           
	PurchasePrice, SalePrice , Damage,PKD, TaxSuffered, DocType, DocID,uom,uomprice,uomqty)         
	VALUES(@ITEM_CODE, @BATCH_NUMBER, @EXPIRY,           
	@REQUIRED_QUANTITY, @COST, @SALE_PRICE,          
	2,  @PKD_DATE, @TAXSUFFERED_ORIG, 6, @INVOICE_ID,@UOM,@UOMPRICE,@UOMQTY)  
	select  @BATCH_CODE=@@Identity  
	end        
        
INSERT INTO InvoiceDetail(InvoiceID, Product_Code, Batch_Code, Batch_Number,           
Quantity, SalePrice, TaxCode, DiscountPercentage, DiscountValue, Amount,           
PurchasePrice, STPayable, SaleID, MRP, TaxID, FlagWord, TaxCode2, CSTPayable,           
TaxSuffered, TaxSuffered2, UOM , UOMQty , UOMPrice)           
VALUES (@INVOICE_ID, @ITEM_CODE, @BATCH_CODE, @BATCH_NUMBER, @REQUIRED_QUANTITY,           
@SALE_PRICE,@SALE_TAX, @DISCOUNT_PER, @DISCOUNT_AMOUNT, @AMOUNT,           
@COST * @REQUIRED_QUANTITY, @STPAYABLE, @SALEID, @MRP, @TAXID, @FLAG, @TAXCODE2,           
@CSTPAYABLE, @TAXSUFFERED, @TAXSUFFERED2, @UOM , @UOMQty ,  @UOMPrice )          
          
IF @BackDatedTransaction = 1           
BEGIN          
	SET @DIFF = 0 + @REQUIRED_QUANTITY          
	exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @COST          

	IF @ADD_TAXSUFF_TO_OPDET = 1
	Begin
		--Updating TaxSuff Percentage in OpeningDetails
		Select @IS_VAT_ITEM=IsNull(Vat,0) From Items Where Product_Code=@Item_Code
		If @LOCALITY = 2 AND @IS_VAT_ITEM = 1
			Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @OpeningDate, @Item_Code, @Batch_Code, 0, 1
		Else
			Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @OpeningDate, @Item_Code, @Batch_Code
	End
	Set @ADD_TAXSUFF_TO_OPDET = 0
END          
          
IF @SCHEMEID <> 0          
BEGIN          
	Select @SECONDARY_SCHEME = IsNull(SecondaryScheme,0) from Schemes Where SchemeID = @SCHEMEID        
	Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags)        
	Values(@ITEM_CODE, @PRIMARY_QUANTITY, @REQUIRED_QUANTITY,           
	@SALE_PRICE * @REQUIRED_QUANTITY, @SCHEME_COST, @SCHEMEID, @INVOICE_ID, 0, @REQUIRED_QUANTITY, @SECONDARY_SCHEME)          
END          
Select 1          
OvernOut:          
CLOSE ReleaseStocks          
DEALLOCATE ReleaseStocks
