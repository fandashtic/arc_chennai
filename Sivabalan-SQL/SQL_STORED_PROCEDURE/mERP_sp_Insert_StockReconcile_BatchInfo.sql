CREATE procedure mERP_sp_Insert_StockReconcile_BatchInfo(@ReconcileID int,                          
	    @Product_Code nvarchar(20),                          
	    @BatchNumber nvarchar(255),                          
	    @PTS Decimal(18,6),                          
	    @PTR Decimal(18,6),                          
	    @ECP Decimal(18,6),                          
	    @SpecialPrice Decimal(18,6),                          
	    @Rate Decimal(18,6),                          
	    @Quantity Decimal(18,6),                          
	    @Expiry datetime,                          
	    @PKD datetime,                          
	    @Free Decimal(18,6),                          
	    @TaxSuffered Decimal(18,6),                          
		@UOM int,
		@UOMQTY Decimal(18,6),
		@UOMPrice Decimal(18,6),
	    @OpeningDate datetime = Null,                        
	    @BackDatedTransaction int = 0,                
	    @TaxID Int=0,
	    @Serial int =0,
        @Damage int = 0,
		@TaxType Int=1 
)				
As                          
Begin
	Declare @BatchCode int                
	DECLARE @GRNAPPLICABLEON int                    
	Declare @GRNPARTOFF Decimal(18,6)                    
	Declare @FreeTaxAmt Decimal(18,6)
	DECLARE @VAT int             
	Declare @FreeTaxSuff Decimal(18,6), @FreeEcp Decimal(18,6) 
	Declare @PriceOption Int
	Declare @FreeBatch Int
	
	If @PTS = 0 And @PTR = 0 
	Begin
	   Set @FreeBatch = 1 
	End 
	Else 
	Begin
	   Set @FreeBatch = 0
	End 
	
	SELECT @GRNAPPLICABLEON = LstApplicableOn, @GRNPARTOFF = LstPartOff from Tax where Tax_Code= @TaxId                    
	SELECT @VAT = Vat from Items where Product_Code= @Product_Code                    
	Select @PriceOption=Price_Option from ItemCategories where CategoryId =(select CategoryId from Items where Product_code =@Product_code)                          
	SET @BatchNumber = Replace(@BatchNumber, CHAR(9), ',')                          
	Exec sp_update_openingdetails_firsttime @PRODUCT_CODE                          
	if @PriceOption = 0 
		select @PTS=PTS,@PTR=PTR,@ECP=ECP,@SpecialPrice=Company_Price from Items where Product_code=@Product_code
    
	Insert into Batch_Products (Batch_Number, Product_Code, StockReconID, Expiry, Quantity,                          
		   PurchasePrice, SalePrice, PTS, PTR, ECP, QuantityReceived,                 
		   Company_Price, PKD, Free,TaxSuffered,UOM,UOMQty,UOMPrice,                
		   GRNTaxID, GRNApplicableOn, GRNPartOff, ApplicableOn,PartOfPercentage,Vat_Locality,Serial, Damage, DamagesReason, TaxType)                                    
		   Values  (@BatchNumber, @Product_Code, @ReconcileID, @Expiry, @Quantity,                
		   @Rate, @ECP, @PTS,@PTR, @ECP, @Quantity,                 
		   @SpecialPrice, @PKD,@FreeBatch, @TaxSuffered,@UOM,@UOMQty,@UOMPrice,                
		   @TaxID,@GRNAPPLICABLEON, @GRNPARTOFF,@GRNAPPLICABLEON, @GRNPARTOFF,1,@Serial, @Damage, 0, @TaxType)                          
	Select @BatchCode = @@Identity                          
   
	                  
	If @BackDatedTransaction = 1                      
	Begin                       
	 exec sp_update_opening_stock @Product_Code, @OpeningDate, @Quantity, 0, @Rate, 0, 0, @BatchCode
	--Insert TaxSuffered in Opening Details
	Exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate , @Product_Code , @BatchCode ,0             
	End                            

	Declare @track_csp int, @purchased_at int
	select @track_csp = itemcategories.price_option,@purchased_at = items.purchased_at
	from itemcategories, items 	where itemcategories.categoryid = items.categoryid
	and items.product_code = @product_Code

	if @track_csp = 1 
	begin
		IF @PURCHASED_AT = 1 
		BEGIN
			update items set sale_price = @PTS, purchase_price = @rate,
       		PTS=@PTS,PTR=@PTR,ECP=@ECP,company_price = @SpecialPrice                    
			where items.product_code = @product_Code
		END
		ELSE
		BEGIN
			update items set sale_price = @PTR, purchase_price = @rate,
       		PTS=@PTS,PTR=@PTR,ECP=@ECP,company_price = @SpecialPrice                    
			where items.product_code = @product_Code
		END
	end
	                        
	Select @BatchCode                          

End
