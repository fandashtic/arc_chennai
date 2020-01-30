Create Procedure sp_Insert_StockTransferOutDetail_CSP_MUOM ( @DocumentID int,          
 @ItemCode nvarchar(15),          
 @BatchNumber nvarchar(255),          
 @Rate Decimal(18,6),          
 @ReqQuantity Decimal(18,6),          
 @TrackBatches int,          
 @TrackInventory int,          
 @Amount Decimal(18,6),          
 @FreeRow Int,          
 @TaxSuffered Decimal(18,6),          
 @TaxAmount Decimal(18,6),          
 @Total Decimal(18,6),          
 @UOM Int,          
 @UOMQty Decimal(18,6),          
 @UOMPrice Decimal(18,6),              
 @OpeningDate datetime = Null,              
 @BackDatedTransaction int = 0,            
 @SchemeID Int = 0,            
 @Serial Int = 0,            
 @FreeSerial nvarchar(100) = Null,            
 @SchemeFree Int = 0,@TaxSuffApplicableOn Int = 0, @TaxSuffPartOff Decimal(18,6) = 0,@VAT Int = 0,@PFM decimal(18,6), @MRPFORTAX Decimal(18,6), @TaxType Int
,@BatchMRPPerPack Decimal(18,6) = 0,@TOQ int = 0
,@TaxID int = 0,@GSTFlag int = 0,@GSTCSTax int = 0, @GSTTaxType int = 0)          
As     
BEGIN     
	Declare @BatchCode int          
	Declare @Quantity Decimal(18,6)          
	Declare @RetVal Decimal(18,6)          
	Declare @TotalQuantity Decimal(18,6)          
	Declare @PTS Decimal(18,6)          
	Declare @PTR Decimal(18,6)          
	Declare @ECP Decimal(18,6)          
	Declare @SpecialPrice Decimal(18,6)          
	Declare @DIFF Decimal(18,6)  
	Declare @MRPPerPack Decimal(18,6)
	--Declare @SalesTOQ int        

	Declare @HSNNumber nvarchar(50)
	Declare @CategorizationID int

	Select @PTS = PTS, @PTR = PTR, @ECP = ECP, @SpecialPrice = Company_Price, @MRPPerPack = MRPPerPack
		,@HSNNumber = isnull(HSNNumber,''), @CategorizationID = isnull(CategorizationID,0)
	From Items, ItemCategories          
	Where Product_Code = @ItemCode And Items.CategoryID = ItemCategories.CategoryID          
	    
	select @TrackBatches=isnull(Track_Batches,0) from Items where Product_code=@ItemCode  
  
	If @TrackInventory = 0          
	Begin          
		 Set @RetVal = 1          
		 Insert into StockTransferOutDetail(DocSerial, Product_Code, Batch_Code,          
		 Batch_Number, PTS, PTR, ECP, SpecialPrice, Rate, Quantity, Amount, Free,          
		 TaxSuffered, TaxAmount, TotalAmount,UOM, UOMQty, UOMPrice, SchemeId , Serial , FreeSerial , SchemeFree,        
		 TaxSuffApplicableOn, TaxSuffPartOff ,VAT , PFM, MRPforTax, TaxType, MRPPerPack,TOQ
		 ,TaxID,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID, GSTTaxType)          
		 Values (@DocumentID, @ItemCode, 0, @BatchNumber, @PTS, @PTR, @ECP, @SpecialPrice,          
		 @Rate, @ReqQuantity, @Amount, @FreeRow, @TaxSuffered, @TaxAmount, @Total, @UOM, @UOMQty, @UOMPrice, @SchemeID , @Serial , @FreeSerial , @SchemeFree,        
		 @TaxSuffApplicableOn, @TaxSuffPartOff, @VAT, @PFM, @MRPforTax, @TaxType,@MRPPerPack,isnull(@TOQ,0)
		,@TaxID,@GSTFlag,@GSTCSTax,@HSNNumber,@CategorizationID, @GSTTaxType)          
		 Goto All_Said_And_Done          
	End          
	If @TrackBatches = 1          
	Begin          
		 Select @TotalQuantity = IsNull(Sum(Quantity), 0) From Batch_Products          
		 Where Product_Code = @ItemCode And IsNull(Batch_Number, N'') = @BatchNumber          
		 And IsNull(PurchasePrice, 0) = @Rate And (Expiry >= GetDate() Or Expiry is Null)          
		 And IsNull(Damage, 0) = 0  And IsNull(Free, 0) = @FreeRow          
		 And IsNull(TaxSuffered, 0) = @TaxSuffered          
		 And IsNull(ApplicableOn,0) = @TaxSuffApplicableOn      
		 And IsNull(PartOfPercentage,0) = @TaxSuffPartOff 
		 and isnull(MRPperPack,0) = @BatchMRPPerPack 
		 and isnull(GRNTaxID,0) = @TaxID    
		 and isnull(TaxType,0) = @TaxType
		 and isnull(GSTTaxType,0) = @GSTTaxType
		      
		 Declare ReleaseStocks Cursor Keyset For          
		 Select Batch_Number, Batch_Code, Quantity,          
		 PTS,PTR, ECP, Company_Price    
		 From Batch_Products          
		 Where Product_Code = @ItemCode And IsNull(Batch_Number, N'') = @BatchNumber          
		 And IsNull(PurchasePrice, 0) = @Rate And IsNull(Quantity, 0) > 0          
		 And IsNull(Damage, 0) = 0 And IsNull(Free, 0) = @FreeRow           
		 And IsNull(TaxSuffered, 0) = @TaxSuffered          
		 And IsNull(ApplicableOn,0) = @TaxSuffApplicableOn      
		 And IsNull(PartOfPercentage,0) = @TaxSuffPartOff      
		 and isnull(MRPperPack,0) = @BatchMRPPerPack
		 and isnull(GRNTaxID,0) = @TaxID
		 and isnull(TaxType,0) = @TaxType
		 and isnull(GSTTaxType,0) = @GSTTaxType      
	End          
	Else          
	Begin          
		 Select @TotalQuantity = IsNull(Sum(Quantity), 0) From Batch_Products          
		 Where Product_Code = @ItemCode And IsNull(PurchasePrice, 0) = @Rate           
		 And IsNull(Damage, 0) = 0 And IsNull(Free, 0) = @FreeRow          
		 And IsNull(TaxSuffered, 0) = @TaxSuffered          
		 And IsNull(ApplicableOn,0) = @TaxSuffApplicableOn      
		 And IsNull(PartOfPercentage,0) = @TaxSuffPartOff 
		 and isnull(MRPperPack,0) = @BatchMRPPerPack 
	     and isnull(GRNTaxID,0) = @TaxID    
		 and isnull(TaxType,0) = @TaxType
		 and isnull(GSTTaxType,0) = @GSTTaxType
		          
		 Declare ReleaseStocks Cursor Keyset For          
		 Select Batch_Number, Batch_Code, Quantity,           
		 PTS,PTR, ECP, Company_Price    
		 From Batch_Products          
		 Where Product_Code = @ItemCode And IsNull(PurchasePrice, 0) = @Rate          
		 And IsNull(Quantity, 0) > 0 And IsNull(Damage, 0) = 0 And IsNull(Free, 0) = @FreeRow          
		 And IsNull(TaxSuffered, 0) = @TaxSuffered          
		 And IsNull(ApplicableOn,0) = @TaxSuffApplicableOn      
		 And IsNull(PartOfPercentage,0) = @TaxSuffPartOff
		 and isnull(MRPperPack,0) = @BatchMRPPerPack      
		 and isnull(GRNTaxID,0) = @TaxID
		 and isnull(TaxType,0) = @TaxType
		 and isnull(GSTTaxType,0) = @GSTTaxType
      
	End          
	Open ReleaseStocks          
	If @TotalQuantity < @ReqQuantity          
	Begin          
		Set @RetVal = 0          
		Goto OvernOut          
	End          
	Else          
	Begin          
		Set @RetVal = 1          
	End          
	Fetch From ReleaseStocks into @BatchNumber, @BatchCode, @Quantity, @PTS, @PTR, @ECP,@SpecialPrice          
	While @@Fetch_Status = 0          
	Begin     
		Select @MRPPerPack = IsNull(MRPPerPack,0) From Batch_Products Where Batch_Code = @BatchCode   
		If @Quantity >= @ReqQuantity          
		Begin          
			Update Batch_Products Set Quantity = Quantity - @ReqQuantity          
			Where Batch_Code = @BatchCode          
		IF @@RowCount = 0          
		Begin          
			Set @RetVal = 1          
			Goto OvernOut          
		End          
		Insert into StockTransferOutDetail(DocSerial, Product_Code, Batch_Code,          
		Batch_Number, PTS, PTR, ECP, SpecialPrice, Rate, Quantity, Amount, Free,          
		TaxSuffered, TaxAmount, TotalAmount,UOM, UOMQty, UOMPrice, SchemeId , Serial , FreeSerial , SchemeFree,        
		TaxSuffApplicableOn, TaxSuffPartOff, VAT, PFM, MRPforTax,TaxType,MRPPerPack,TOQ
		,TaxID,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID, GSTTaxType)            
		Values (@DocumentID, @ItemCode, @BatchCode, @BatchNumber, @PTS, @PTR, @ECP,          
		@SpecialPrice, @Rate, @ReqQuantity, @Amount, @FreeRow, @TaxSuffered,           
		@TaxAmount, @Total, @UOM, @UOMQty, @UOMPrice, @SchemeID , @Serial , @FreeSerial , @SchemeFree,        
		@TaxSuffApplicableOn, @TaxSuffPartOff, @VAT, @PFM, @MRPforTax,@TaxType,@MRPPerPack,@TOQ
		,@TaxID,@GSTFlag,@GSTCSTax,@HSNNumber,@CategorizationID, @GSTTaxType)            
	          
		If @BackDatedTransaction = 1            
		Begin             
			Set @DIFF = 0 - @ReqQuantity            
			exec sp_update_opening_stock @ItemCode, @OpeningDate, @DIFF, @FreeRow, @Rate, 0, 0, @BatchCode
		End            
		GoTo OvernOut          
	End          
	Else          
	Begin          
		Select @MRPPerPack = IsNull(MRPPerPack,0) From Batch_Products Where Batch_Code = @BatchCode
		Set @ReqQuantity = @ReqQuantity - @Quantity          
	    Update Batch_Products Set Quantity = 0 Where Batch_Code = @BatchCode          
	    If @@RowCount = 0          
		Begin          
			Set @RetVal = 1          
			Goto OvernOut          
		End          
		Insert into StockTransferOutDetail(DocSerial, Product_Code, Batch_Code,          
		Batch_Number, PTS, PTR, ECP, SpecialPrice, Rate, Quantity, Amount, Free,          
		TaxSuffered, TaxAmount, TotalAmount,UOM, UOMQty, UOMPrice, SchemeId , Serial , FreeSerial , SchemeFree,        
		TaxSuffApplicableOn, TaxSuffPartOff, VAT, PFM, MRPforTax,TaxType,MRPPerPack,TOQ
		,TaxID,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID, GSTTaxType)            
		Values (@DocumentID, @ItemCode, @BatchCode, @BatchNumber, @PTS, @PTR, @ECP,          
		@SpecialPrice, @Rate, @Quantity, @Amount, @FreeRow, @TaxSuffered, @TaxAmount,           
		@Total, @UOM, @UOMQty, @UOMPrice, @SchemeID , @Serial , @FreeSerial , @SchemeFree,        
		@TaxSuffApplicableOn, @TaxSuffPartOff, @VAT, @PFM, @MRPforTax, @TaxType, @MRPPerPack,isnull(@TOQ,0)
		,@TaxID,@GSTFlag,@GSTCSTax,@HSNNumber,@CategorizationID, @GSTTaxType)              
		Set @Amount = 0          
		Set @TaxSuffered = 0          
		Set @TaxAmount = 0          
		Set @Total = 0          
		Set @UOMQty = 0          
		If @BackDatedTransaction = 1            
		Begin             
			Set @DIFF = 0 - @Quantity            
			exec sp_update_opening_stock @ItemCode, @OpeningDate, @DIFF, @FreeRow, @Rate, 0, 0, @BatchCode
		End            
	End          
	Fetch Next From ReleaseStocks into @BatchNumber, @BatchCode, @Quantity, @PTS, @PTR,@ECP, @SpecialPrice          
	End          
	OvernOut:          
	Close ReleaseStocks          
	Deallocate ReleaseStocks          
	All_Said_And_Done:          
	Select @RetVal  
END
