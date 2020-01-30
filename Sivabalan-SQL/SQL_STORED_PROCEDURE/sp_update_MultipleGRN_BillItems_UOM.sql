CREATE procedure sp_update_MultipleGRN_BillItems_UOM(@Bill_ID int, @Product_Code as nvarchar(50),       
         @Qty Decimal(18,6),       
         @Price Decimal(18,6),       
         @Amount Decimal(18,6),       
         @BATCH_CODE int,      
         @TaxSuffered Decimal(18,6),       
         @TaxAmount Decimal(18,6),       
         @Taxcode int,       
         @DisPrice Decimal(18,6),      
         @Discount Decimal(18,6),      
         @Free Decimal(18,6),      
         @Batch nvarchar(255),      
         @Expiry datetime,      
         @PKD datetime,      
         @PTS Decimal(18,6),      
         @PTR Decimal(18,6),      
         @ECP Decimal(18,6),      
         @SpecialPrice Decimal(18,6),      
         @UOMID Int,      
         @UOMQty Decimal(18,6),      
         @UOMPrice Decimal(18,6),    
         @ComboId int=-123,  
         @ExciseDuty Decimal(18,6) = 0,  
     	 @PurchasePriceBeforeExciseAmount Decimal(18,6) = 0,  
         @ExciseID Int = 0,  
    	 @VAT int = 0,  
	     @Promotion int = 0,
	     @DiscPerUnit Decimal(18,6)=0,
		 @PFM Decimal(18,6)=0,
	     @InvDiscPerc Decimal(18,6) = 0,
	     @InvDiscPerUnit Decimal(18,6) = 0,
	     @InvDiscAmt Decimal(18,6) = 0,
	     @OtherDiscPerc Decimal(18,6) = 0,
	     @OtherDiscPerUnit Decimal(18,6) = 0,
	     @OtherDiscAmt Decimal(18,6) = 0,
	     @DiscType Int = 0,
	     @NET_PTS Decimal(18,6) = 0,
	     @PTS_Margin Decimal(18,6)=0,@MRPForTax Decimal(18,6)=0,@MRPPerPack Decimal(18,6)=0,@TOQ int = 0
	     , @Serial Int = 0, @CS_TaxCode Int = 0, @TaxType Int = 0, @HSNNumber nVarChar(15)='', @TaxSplitup nVarChar(Max) = ''
	     ,@MarginDetID Int = 0, @MarginPerc Decimal(18,6) = 0, @MarginOn Decimal(18,6) = 0, @MarginAddOn Decimal(18,6) = 0
)      
as      
	DECLARE @APPLICABLEON INT  
	DECLARE @PARTOFF DECIMAL(18,6)  
	DECLARE @LOCALITY INT  
	DECLARE @BillDate DATETIME
	DECLARE @OLDVALUE DECIMAL(18,6)  
	DECLARE @NEWVALUE DECIMAL(18,6)  
	DECLARE @ADJVALUE DECIMAL(18,6)  
	SET @OLDVALUE = 0
	SET @NEWVALUE = 0
	SET @ADJVALUE = 0
	Select @OLDVALUE = IsNull(PurchasePrice,0) * IsNull(Quantity,0) from Batch_Products Where Batch_Code = @Batch_Code

	Select @BillDate=BillDate From BillAbstract Where BillId=@Bill_ID
	SELECT @LOCALITY = VE.LOCALITY FROM BILLABSTRACT AS BA   
	INNER JOIN VENDORS AS VE ON BA.VENDORID = VE.VENDORID WHERE BA.BILLID = @BILL_ID  

	--Updating TaxSuff Percentage in OpeningDetails
	If @LOCALITY = 2 AND @VAT = 1
		Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @Product_Code, @Batch_Code, 1, 1
	Else
		Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @Product_Code, @Batch_Code, 1, 0
	  
	If(@ComboId=-123)      
		Insert into BillDetail (BillID, Product_Code, Quantity, PurchasePrice,       
		Amount, TaxSuffered, TaxAmount, TaxCode, Discount, Batch, Expiry, PKD, PTS, PTR, ECP,      
		SpecialPrice, UOM, UOMQty, UOMPrice, ExciseDuty,PurchasePriceBeforeExciseAmount,ExciseID,VAT,Promotion,DiscPerUnit,OrgPTS,
		PFM, InvDiscPerc, InvDiscAmtPerUnit, InvDiscAmount, OtherDiscPerc, OtherDiscAmtPerUnit, OtherDiscAmount, DiscType, NetPTS, PTS_Margin,MRPForTAX,MRPPerPack,TOQ, Serial, CS_TaxCode, 
		HSNNumber, MarginDetID, MarginPerc, MarginOn, MarginAddOn)
		Values (@Bill_ID, @Product_Code, @Qty, @DisPrice, @Amount, @TaxSuffered, @TaxAmount,       
		@TaxCode, @Discount, @Batch, @Expiry, @PKD, @PTS, @PTR, @ECP, @SpecialPrice, @UOMID,      
		@UOMQty, @UOMPrice, @ExciseDuty, @PurchasePriceBeforeExciseAmount, @ExciseID,@VAT,@Promotion,@DiscPerUnit,@Price,
		@PFM,@InvDiscPerc, @InvDiscPerUnit, @InvDiscAmt, @OtherDiscPerc, @OtherDiscPerUnit, @OtherDiscAmt, @DiscType, @NET_PTS, @PTS_Margin,@MRPForTAX,@MRPPerPack,@TOQ, @Serial, @CS_TaxCode, @HSNNumber,@MarginDetID, @MarginPerc, @MarginOn, @MarginAddOn)      
	Else    
		Insert into BillDetail (BillID, Product_Code, Quantity, PurchasePrice,       
		Amount, TaxSuffered, TaxAmount, TaxCode, Discount, Batch, Expiry, PKD, PTS, PTR, ECP,      
		SpecialPrice, UOM, UOMQty, UOMPrice,ComboID, ExciseDuty,PurchasePriceBeforeExciseAmount,ExciseID,VAT,Promotion,DiscPerUnit,OrgPTS,
		PFM,  InvDiscPerc, InvDiscAmtPerUnit, InvDiscAmount, OtherDiscPerc, OtherDiscAmtPerUnit, OtherDiscAmount, DiscType, NetPTS, PTS_Margin,MRPForTAX,MRPPerPack,TOQ, Serial, CS_TaxCode, HSNNumber, MarginDetID, MarginPerc, MarginOn, MarginAddOn)
		Values (@Bill_ID, @Product_Code, @Qty, @DisPrice, @Amount, @TaxSuffered, @TaxAmount,       
		@TaxCode, @Discount, @Batch, @Expiry, @PKD, @PTS, @PTR, @ECP, @SpecialPrice, @UOMID,      
		@UOMQty, @UOMPrice,@ComboID, @ExciseDuty, @PurchasePriceBeforeExciseAmount, @ExciseID,@VAT,@Promotion,@DiscPerUnit,@Price,
		@PFM,@InvDiscPerc, @InvDiscPerUnit, @InvDiscAmt, @OtherDiscPerc, @OtherDiscPerUnit, @OtherDiscAmt, @DiscType, @NET_PTS, @PTS_Margin,@MRPForTAX,@MRPPerPack, @TOQ, @Serial, @CS_TaxCode, @HSNNumber,@MarginDetID, @MarginPerc, @MarginOn, @MarginAddOn )      

	If @Free = 0       
	Begin      
		IF @LOCALITY = 1  
			BEGIN   
			SELECT @APPLICABLEON = LSTAPPLICABLEON,@PARTOFF = LSTPARTOFF  
			FROM TAX WHERE TAX_CODE = @TAXCODE  
			END   
		ELSE  
			BEGIN   
			SELECT @APPLICABLEON = CSTAPPLICABLEON,@PARTOFF = CSTPARTOFF  
			FROM TAX WHERE TAX_CODE = @TAXCODE  
			END  
		
		Update Batch_Products Set PurchasePrice = @DisPrice,      
		TaxSuffered = @TaxSuffered, ExciseDuty = @ExciseDuty, ExciseID = @ExciseID,  
		APPLICABLEON = @APPLICABLEON,PARTOFPERCENTAGE = @PARTOFF,
		uomprice = @UOMPrice
		Where Batch_Code = @BATCH_CODE and Free = 0    
	End      
	Select @NEWVALUE = IsNull(PurchasePrice,0) * IsNull(Quantity,0) from Batch_Products Where Batch_Code = @Batch_Code
	SET @ADJVALUE = @NEWVALUE - @OLDVALUE
	--Updating Opening_Value in OpeningDetails table.
	IF @ADJVALUE <> 0 
		Exec Sp_Update_Opening_Stock @Product_Code, @BillDate, 0, @Free, 0, 0, @ADJVALUE, @Batch_Code
	  
	--Updating TaxSuff Percentage in OpeningDetails
	If @LOCALITY = 2 AND @VAT = 1
		Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @Product_Code, @Batch_Code, 0, 1
	Else
		Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @Product_Code, @Batch_Code, 0, 0

If @Free=0 
Begin
	Create Table #tmpTaxCompSplitup(RowID int, TC1_TaxComponent_Code Decimal(18,6),TC2_Tax_percentage Decimal(18,6),
			TC3_CS_ComponentCode Decimal(18,6),TC4_ComponentType Decimal(18,6),TC5_ApplicableonComp Decimal(18,6),
			TC6_ApplicableOnCode Decimal(18,6),TC7_ApplicableUOM Decimal(18,6),TC8_PartOff Decimal(18,6),TC9_TaxAmt Decimal(18,6),
			TC10_FirstPoint Decimal(18,6), TC11_STCrFlag Decimal(18,6), TC12_STCrAmt Decimal(18,6), TC13_NetTaxAmt Decimal(18,6))
	
	Insert into #tmpTaxCompSplitup
	Exec sp_SplitIn2Matrix @TaxSplitup

	Insert Into GSTBillTaxComponents(BillID,Product_Code,SerialNo,TaxType,Tax_Code,Tax_Component_Code,Tax_Percentage,Tax_Value,
			FirstPoint)
	Select @Bill_ID,@Product_Code,@Serial,@TaxType,@TaxCode,Cast(TC1_TaxComponent_code as int),TC2_Tax_percentage,TC9_TaxAmt,
			Cast(TC10_FirstPoint as int)
	From #tmpTaxCompSplitup
	
	Drop table #tmpTaxCompSplitup
End


