Create PROCEDURE sp_update_ImportItem_ITC(
@Product_Code nvarchar(30),             
@ProductName nvarchar(2000),               
@Description nvarchar(2000),              
@CategoryID int,             
@ManufacturerID nvarchar(15),             
@BrandID int,             
@UOM int,             
@Sale_Tax Decimal(18,6),             
@MRP Decimal(18,6),             
@Preferred_Vendor nvarchar(15),             
@StockNorm Decimal(18,6),             
@MinOrderQty Decimal(18,6),             
@ConversionFactor Decimal(18,6),             
@ConversionUnit int,             
@SaleID int,             
@company_price Decimal(18,6),             
@PTS Decimal(18,6),             
@PTR Decimal(18,6),             
@ECP Decimal(18,6),             
@Sale_Price Decimal(18,6),             
@Purchased_At int,             
@Purchase_Price Decimal(18,6),             
@TaxSuffered Decimal(18,6),             
@SoldAS  nvarchar(50),              
@ReportingUOM Decimal(18,6),             
@ReportingUnit Decimal(18,6),             
@TrackPKD int,             
@Track_Batches int,             
@Virtual_Track_Batches int,             
@Alias nvarchar(30),        
@TaxInclusive Decimal(18,6)= 0,        
@TaxInclusiveRate Decimal(18,6) = 0,        
@Hyperlink nVarchar(256) = N'',        
@AdhocAmount Decimal(18,6) = 0,      
@Vat int=0,      
@CollectTaxSuffered int=0,
@Version nVarchar(15) = N'',
@CaseUOM int =0 ,  
@CaseConversion Decimal(18,6)=0,  
@UserDefinedCode nVarchar(256)=N'',
@PFM Decimal(18,6)=0,
@MRPPerPack Decimal(18,6)=0,
@HealthcareItem Int =0,
@TOQ_Purchase int=0,
@TOQ_Sales int=0
--,@GSTProdCat Int = 0
--,@HSNNumber nVarChar(8) = ''
)                   
AS 
           
Declare @ORIG_ALIAS nvarchar(30)              
Declare @PriceOption Int      
Declare @ScreenCode nVarchar(100)
Declare @FlgBatch as Int,@FlgPKD as Int

--Declare @ModifyitemFlag int
--Declare @ModifyitemTaxSufferedFlag int

--Select @ModifyitemFlag = isNull(Flag,0) from tbl_merp_ConfigDetail where ScreenCode like 'ITM03' and ControlName like 'CboSaleTax'
--Select @ModifyitemTaxSufferedFlag = IsNull(Flag,0) from tbl_merp_ConfigDetail where ScreenCode like 'ITM03' and ControlName like 'cboTaxSuffered'

/* @MRP variable contains MRPPerPack value */

If @Version = 'CUG'
Begin

Select @ScreenCode = ScreenCode from tbl_mERP_ConfigAbstract 
Where ScreenName = 'Import Item Modify'


If IsNull((Select Flag from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'ItemName'),1) <> 0
UPDATE Items SET ProductName = @ProductName WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'Description'),1) <> 0
UPDATE Items SET Description = @Description WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'Category'),1) <> 0
UPDATE Items SET CategoryID = @CategoryID WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'Mfr'),1) <> 0
UPDATE Items SET ManufacturerID = @ManufacturerID WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'Brand'),1) <> 0
UPDATE Items SET BrandID = @BrandID WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'UOM'),1) <> 0
UPDATE Items SET UOM = @UOM WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'PurchasedAT'),1) <> 0
UPDATE Items SET Purchase_Price = @Purchase_Price WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'ECP'),1) <> 0
UPDATE Items SET Sale_Price = @Sale_Price WHERE Product_Code = @Product_Code

If Isnull((Select Flag From tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'),0) <> 1
Begin
	If IsNull((Select Flag from tbl_mERP_ConfigDetail 
	Where ScreenCode = @ScreenCode And ControlName = 'SaleTax'),1) <> 0 --and  @ModifyitemFlag = 1 
	UPDATE Items SET Sale_Tax = @Sale_Tax WHERE Product_Code = @Product_Code
End

--If IsNull((Select Flag from tbl_mERP_ConfigDetail 
--Where ScreenCode = @ScreenCode And ControlName = 'MRP'),1) <> 0
--UPDATE Items SET MRP = @MRP WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'PreferredVendor'),1) <> 0
UPDATE Items SET Preferred_Vendor = @Preferred_Vendor WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'StockNorm'),1) <> 0
UPDATE Items SET StockNorm = @StockNorm WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'LotSize'),1) <> 0
UPDATE Items SET MinOrderQty = @MinOrderQty WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'BatchTracked'),1) <> 0
UPDATE Items SET Track_Batches = @Track_Batches WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'ConversionFactor'),1) <> 0
UPDATE Items SET ConversionFactor = @ConversionFactor WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'ConversionUnit'),1) <> 0
UPDATE Items SET ConversionUnit = @ConversionUnit WHERE Product_Code = @Product_Code

--SaleID = FirstOrSecondSale
If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'FirstOrSecondSale'),1) <> 0
UPDATE Items SET SaleID = @SaleID WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'PurchasedAT'),1) <> 0
UPDATE Items SET Purchased_At = @Purchased_At WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'SpecialPrice'),1) <> 0
UPDATE Items SET Company_Price = @company_price WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'PTS'),1) <> 0
UPDATE Items SET PTS = @PTS WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'PTR'),1) <> 0
UPDATE Items SET PTR = @PTR WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'ECP'),1) <> 0
UPDATE Items SET ECP = @ECP WHERE Product_Code = @Product_Code

If Isnull((Select Flag From tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'),0) <> 1
Begin
	If IsNull((Select Flag from tbl_mERP_ConfigDetail 
	Where ScreenCode = @ScreenCode And ControlName = 'TaxSuffered'),1) <> 0  --and  @ModifyitemTaxSufferedFlag = 1 
	UPDATE Items SET TaxSuffered = @TaxSuffered WHERE Product_Code = @Product_Code
End

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'SoldAs'),1) <> 0
UPDATE Items SET SoldAs = @SoldAS WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'Alias'),1) <> 0
UPDATE Items SET Alias = @Alias WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'ReportingUOM'),1) <> 0
UPDATE Items SET ReportingUOM = @ReportingUOM WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'ReportingUnit'),1) <> 0
UPDATE Items SET ReportingUnit = @ReportingUnit WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'PkdTracked'),1) <> 0
UPDATE Items SET TrackPKD = @TrackPKD WHERE Product_Code = @Product_Code


--Virtual track batches = track batch(seen in code)
If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'BatchTracked'),1) <> 0
UPDATE Items SET Virtual_Track_Batches = @Virtual_Track_Batches WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'TaxInclusive'),1) <> 0
UPDATE Items SET TaxInclusive = @TaxInclusive WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'TaxInclusiveRate'),1) <> 0
UPDATE Items SET TaxInclusiveRate = @TaxInclusiveRate WHERE Product_Code = @Product_Code

--Not Needed
--If IsNull((Select Flag from tbl_mERP_ConfigDetail 
--Where ScreenCode = @ScreenCode And ControlName = 'Hyperlink'),-1) <> 1
--UPDATE Items SET Hyperlink = @Hyperlink WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'AdhocAmount'),1) <> 0
UPDATE Items SET AdhocAmount = @AdhocAmount WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'Vat'),1) <> 0
UPDATE Items SET Vat = @Vat WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'CollectTaxSuffered'),1) <> 0
UPDATE Items SET CollectTaxSuffered = @CollectTaxSuffered WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'PFM'),1) <> 0
UPDATE Items SET PFM = @PFM WHERE Product_Code = @Product_Code

UPDATE Items SET MRPPerPack = @MRPPerPack WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'HealthcareItem'),1) <> 0
UPDATE Items SET ASL = @HealthcareItem WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'TOQ_Purchase'),1) <> 0
UPDATE Items SET TOQ_Purchase = @TOQ_Purchase WHERE Product_Code = @Product_Code

If IsNull((Select Flag from tbl_mERP_ConfigDetail 
Where ScreenCode = @ScreenCode And ControlName = 'TOQ_Sales'),1) <> 0
UPDATE Items SET TOQ_Sales = @TOQ_Sales WHERE Product_Code = @Product_Code

--If IsNull((Select Flag from tbl_mERP_ConfigDetail 
--Where ScreenCode = @ScreenCode And ControlName = 'CategorizationID'),1) <> 0
--UPDATE Items SET CategorizationID = @GSTProdCat WHERE Product_Code = @Product_Code

--If IsNull((Select Flag from tbl_mERP_ConfigDetail 
--Where ScreenCode = @ScreenCode And ControlName = 'HSNNumber'),1) <> 0
--UPDATE Items SET HSNNumber = @HSNNumber WHERE Product_Code = @Product_Code

-- If IsNull(Select Count(*) from tbl_mERP_ConfigDetail 
-- Where ScreenCode = @ScreenCode And Flag = 0,-1) > 0
UPDATE Items SET ModifiedDate = GetDate() WHERE Product_Code = @Product_Code
-- Case_UOM = @CaseUOM,  
-- Case_Conversion = @CaseConversion,  
-- UserDefinedCode = @UserDefinedCode  
End
Else
Begin
If Isnull((Select Flag From tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'),0) <> 1
Begin
UPDATE Items SET ProductName = @ProductName,          
   Description = @Description,              
   CategoryID = @CategoryID,              
   ManufacturerID = @ManufacturerID,              
   BrandID = @BrandID,              
   UOM = @UOM,              
   Purchase_Price = @Purchase_Price,     
   Sale_Price = @Sale_Price,              
   Sale_Tax = @Sale_Tax,              
   --MRP = @MRP,              
   Preferred_Vendor = @Preferred_Vendor,              
   StockNorm = @StockNorm,              
   MinOrderQty = @MinOrderQty,              
   Track_Batches = @Track_Batches,              
   ConversionFactor = @ConversionFactor,              
   ConversionUnit = @ConversionUnit,              
   SaleID = @SaleID,              
   Purchased_At = @Purchased_At,              
   Company_Price = @company_price,              
   PTS = @PTS,              
   PTR = @PTR,              
   ECP = @ECP,              
   TaxSuffered = @TaxSuffered,              
   SoldAs = @SoldAS,              
   Alias = @Alias,              
   ReportingUOM = @ReportingUOM,              
   ReportingUnit = @ReportingUnit,              
   TrackPKD = @TrackPKD,              
   Virtual_Track_Batches = @Virtual_Track_Batches,              
   ModifiedDate = GetDate(),        
   TaxInclusive = @TaxInclusive,        
   TaxInclusiveRate = @TaxInclusiveRate,        
   Hyperlink = @Hyperlink,        
   AdhocAmount = @AdhocAmount,      
   Vat = @Vat,      
   CollectTaxSuffered = @CollectTaxSuffered,  
   Case_UOM = @CaseUOM,  
   Case_Conversion = @CaseConversion,  
   UserDefinedCode = @UserDefinedCode,
   PFM = @PFM,
   MRPPerPack=@MRPPerPack,
  ASL =@HealthcareItem,
  TOQ_Purchase=@TOQ_Purchase,
  TOQ_Sales=@TOQ_Sales 
  --,CategorizationID = @GSTProdCat
  --,HSNNumber = @HSNNumber
WHERE Product_Code = @Product_Code
End
Else
Begin
UPDATE Items SET ProductName = @ProductName,          
   Description = @Description,              
   CategoryID = @CategoryID,              
   ManufacturerID = @ManufacturerID,              
   BrandID = @BrandID,              
   UOM = @UOM,              
   Purchase_Price = @Purchase_Price,              
   Sale_Price = @Sale_Price,              
   --Sale_Tax = @Sale_Tax,              
   --MRP = @MRP,              
   Preferred_Vendor = @Preferred_Vendor,              
   StockNorm = @StockNorm,              
   MinOrderQty = @MinOrderQty,              
   Track_Batches = @Track_Batches,              
   ConversionFactor = @ConversionFactor,              
   ConversionUnit = @ConversionUnit,              
   SaleID = @SaleID,              
   Purchased_At = @Purchased_At,              
   Company_Price = @company_price,              
   PTS = @PTS,              
   PTR = @PTR,              
   ECP = @ECP,              
   --TaxSuffered = @TaxSuffered,              
   SoldAs = @SoldAS,              
   Alias = @Alias,              
   ReportingUOM = @ReportingUOM,              
   ReportingUnit = @ReportingUnit,              
   TrackPKD = @TrackPKD,              
   Virtual_Track_Batches = @Virtual_Track_Batches,              
   ModifiedDate = GetDate(),        
   TaxInclusive = @TaxInclusive,        
   TaxInclusiveRate = @TaxInclusiveRate,        
   Hyperlink = @Hyperlink,        
   AdhocAmount = @AdhocAmount,      
   Vat = @Vat,      
   CollectTaxSuffered = @CollectTaxSuffered,  
   Case_UOM = @CaseUOM,  
   Case_Conversion = @CaseConversion,  
   UserDefinedCode = @UserDefinedCode,
   PFM = @PFM,
   MRPPerPack=@MRPPerPack,
  ASL =@HealthcareItem,
  TOQ_Purchase=@TOQ_Purchase,
  TOQ_Sales=@TOQ_Sales 
  --,CategorizationID = @GSTProdCat
  --,HSNNumber = @HSNNumber
WHERE Product_Code = @Product_Code
End
End
          
SELECT @ORIG_ALIAS = IsNull(Alias,N'') From Items Where Product_Code = @Product_Code              
IF @ORIG_ALIAS <> @Alias              
BEGIN              
Update StockTransferOutDetailReceived Set Product_Code = @Product_Code              
Where ForumCode = @Alias              
Update stock_request_detail_received Set Product_Code = @Product_Code              
Where ForumCode = @Alias              
END           
      
--To Update Prices for NonCSP Items     
If @Version = 'CUG'
Begin
	select @priceOption = IsNull(ItemCategories.price_option, 0) from items, ItemCategories       
	where items.CategoryId = ItemCategories.CategoryId  And items.Product_Code = @Product_Code      
	If @PriceOption = 0      
	Begin      
		If IsNull((Select Flag from tbl_mERP_ConfigDetail 
		Where ScreenCode = @ScreenCode And ControlName = 'PTS'),1) <> 0
		Update batch_products Set PTS = @PTS Where Product_code = @Product_Code And isnull(free,0) <> 1  

		If IsNull((Select Flag from tbl_mERP_ConfigDetail 
		Where ScreenCode = @ScreenCode And ControlName = 'PTR'),1) <> 0
		Update batch_products Set PTR = @PTR Where Product_code = @Product_Code And isnull(free,0) <> 1  

		If IsNull((Select Flag from tbl_mERP_ConfigDetail 
		Where ScreenCode = @ScreenCode And ControlName = 'ECP'),1) <> 0
		Update batch_products Set ECP = @ECP,SalePrice = @Sale_Price Where Product_code = @Product_Code And isnull(free,0) <> 1  

		Update batch_products Set MRPPerPack=@MRPPerPack Where Product_code = @Product_Code And isnull(free,0) <> 1  		
	End 
End
Else
Begin 
	select @priceOption = IsNull(ItemCategories.price_option, 0) from items, ItemCategories       
	where items.CategoryId = ItemCategories.CategoryId  And items.Product_Code = @Product_Code      
	If @PriceOption = 0      
	Begin      
		Update batch_products set SalePrice = @Sale_Price,PTS = @PTS,PTR = @PTR,ECP = @ECP       
		Where Product_code = @Product_Code And isnull(free,0) <> 1      

		Update batch_products Set MRPPerPack=@MRPPerPack Where Product_code = @Product_Code And isnull(free,0) <> 1  		
	End  
End 
  
If @Version = 'CUG'
Begin
	Select @FlgBatch = isNull(Flag,1) from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'BatchTracked'
	Select @FlgPKD = isNull(Flag,1) from tbl_mERP_ConfigDetail Where ScreenCode = @ScreenCode And ControlName = 'PkdTracked'
	If (@FlgPKD <> 0 And @FlgPKD <> 0)
	Begin
		if @TrackPKD = 0 and @Track_Batches = 0 and  @Virtual_Track_Batches = 0 
		Begin
		  exec dbo.sp_Update_TrackBatch_ITC @Product_Code
		End
	End 
End
Else
Begin
	if @TrackPKD = 0 and @Track_Batches = 0 and  @Virtual_Track_Batches = 0 
	Begin
	  exec dbo.sp_Update_TrackBatch_ITC @Product_Code
	End
End 
