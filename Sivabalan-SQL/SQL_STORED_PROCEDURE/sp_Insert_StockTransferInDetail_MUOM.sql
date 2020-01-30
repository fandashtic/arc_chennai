CREATE procedure sp_Insert_StockTransferInDetail_MUOM (@DocSerial int,                            
     @Product_Code nvarchar(20),                            
     @BatchNumber nvarchar(255),                            
     @PTS Decimal(18,6),                            
     @PTR Decimal(18,6),                            
     @ECP Decimal(18,6),                            
     @SpecialPrice Decimal(18,6),                            
     @Rate Decimal(18,6),                            
     @Quantity Decimal(18,6),                            
     @Amount Decimal(18,6),                            
     @Expiry datetime,                            
     @PKD datetime,                            
     @Free Decimal(18,6),                            
     @TaxSuffered Decimal(18,6),                            
     @TaxAmount Decimal(18,6),                            
     @TotalAmount Decimal(18,6),@UOM int,@UOMQTY Decimal(18,6),@UOMPrice Decimal(18,6),@promotion int = 0,                          
     @OpeningDate datetime = Null,                          
     @BackDatedTransaction int = 0,                  
     @TaxID Int=0,  
     @Serial int =0,  
     @DocQty Decimal(18,6)=0,    
     @DocFree Decimal(18,6)=0,    
     @RecQty Decimal(18,6)=0,  
     @RejQty Decimal(18,6)=0,  
	 @TaxType int = 0,  
     @PFM decimal(18,6),
	 @MRPforTax decimal(18,6)
     , @MRPPerPack decimal(18,6)
	,@TOQ int
	,@GSTFlag Int
	,@CSTaxCode Int
	,@HSNNumber nVarChar(15)
	, @TaxSplitup nVarChar(Max) = ''
	, @MarginDetID Int = 0, @MarginPerc Decimal(18,6) = 0, @MarginOn Decimal(18,6) = 0, @MarginAddOn Decimal(18,6) = 0
)      
As                            
Declare @BatchCode int                  
DECLARE @GRNAPPLICABLEON int                      
Declare @GRNPARTOFF Decimal(18,6)                      
Declare @FreeTaxAmt Decimal(18,6)  
DECLARE @VAT int               
Declare @FreeTaxSuff Decimal(18,6), @FreeEcp Decimal(18,6)   
Declare @PriceOption Int  

Declare @PurchaseTOQ int
Declare @GSTTaxType Int

--Set @GSTTaxType = @TaxType
If @GSTFlag = 1
Begin
	If @TaxType = 5 or @TaxType = 6
	Begin
		Set @GSTTaxType = @TaxType
		Set @TaxType = 5
		
		If @GSTTaxType = 5
			Set @GSTTaxType = 1
		Else If @GSTTaxType = 6
			Set @GSTTaxType = 2
	End
	Else
	Begin
		Set @GSTTaxType = 0
	End
End

Select @MarginPerc = Percentage  From tbl_merp_margindetail  Where ID = @MarginDetID

	Create Table #tmpTaxCompSplitup(RowID int, TC1_TaxComponent_Code Decimal(18,6),TC2_Tax_percentage Decimal(18,6),
			TC3_CS_ComponentCode Decimal(18,6),TC4_ComponentType Decimal(18,6),TC5_ApplicableonComp Decimal(18,6),
			TC6_ApplicableOnCode Decimal(18,6),TC7_ApplicableUOM Decimal(18,6),TC8_PartOff Decimal(18,6),TC9_TaxAmt Decimal(18,6),
			TC10_FirstPoint Decimal(18,6), TC11_STCrFlag Decimal(18,6), TC12_STCrAmt Decimal(18,6), TC13_NetTaxAmt Decimal(18,6))

SELECT @GRNAPPLICABLEON = LstApplicableOn, @GRNPARTOFF = LstPartOff from Tax where Tax_Code= @TaxId    
SELECT @VAT = Vat from Items where Product_Code= @Product_Code                      
Select @PriceOption=Price_Option from ItemCategories where CategoryId =(select CategoryId from Items where Product_code =@Product_code)                            
SET @BatchNumber = Replace(@BatchNumber, CHAR(9), ',')                            
Exec sp_update_openingdetails_firsttime @PRODUCT_CODE                            
if @PriceOption = 0   
 select @PTS=PTS,@PTR=PTR,@ECP=ECP,@SpecialPrice=Company_Price from Items where Product_code=@Product_code  
                  
Insert into Batch_Products (Batch_Number, Product_Code, StockTransferID, Expiry, Quantity,                            
       PurchasePrice, SalePrice, PTS, PTR, ECP, QuantityReceived,                   
       Company_Price, PKD, Free,TaxSuffered,UOM,UOMQty,UOMPrice,                  
       GRNTaxID, GRNApplicableOn, GRNPartOff, ApplicableOn,PartOfPercentage, Vat_Locality, Serial,TaxType,PFM,MRPforTax,MRPPerPack,TOQ,GSTTaxType
       , MarginDetID, MarginPerc, MarginOn, MarginAddOn)  
       Values  (@BatchNumber, @Product_Code, @DocSerial, @Expiry, @Quantity,                  
       @Rate, @ECP, @PTS,@PTR, @ECP, @Quantity,                   
       @SpecialPrice, @PKD, 0, @TaxSuffered,@UOM,@UOMQty,@UOMPrice,                  
       @TaxID,@GRNAPPLICABLEON, @GRNPARTOFF,@GRNAPPLICABLEON, @GRNPARTOFF, 1, @Serial, @TaxType,@PFM,@MRPforTax,@MRPPerPack,@TOQ,@GSTTaxType
      ,@MarginDetID, @MarginPerc, @MarginOn, @MarginAddOn )  
Select @BatchCode = @@Identity                            
  
            
            
Set @FreeTaxAmt = 0                  
Set @FreeEcp =  0              
Set @FreeTaxSuff = 0  
                  
if @Promotion = 1 and @Free > 0                  
Begin                  
 Set @FreeTaxAmt = (@TaxAmount / (@Quantity + @Free)) * @Free                  
 Set @TaxAmount = @TaxAmount - @FreeTaxAmt       
 --For Free items if it is retailer promotion the   
 --ECP value should be stored in the batch products table  
 Set @FreeEcp = @ECP                 
 Set @FreeTaxSuff = @TaxSuffered                
End                  

--Select @PurchaseTOQ  = isnull(TOQ_Purchase,0) from items where product_code=@Product_Code
                          
Insert into StockTransferInDetail( DocSerial,                            
   Product_Code,                            
   Batch_Code,                            
   Batch_Number,                            
   PTS,                            
   PTR,                             
   ECP,                            
   SpecialPrice,                            
   Rate,                            
   Quantity,                            
   Amount,                            
   Expiry,                            
   PKD,                            
   TaxSuffered,                            
   TaxAmount,                            
   TotalAmount,UOM,UOMQty,UOMPrice,TaxCode,VAT,  
   Serial,QuantityReceived,QuantityRejected,DocumentQuantity,DocumentFreeQty,PFM,MRPforTax,MRPPerPack,TOQ
   ,CS_TaxCode, HSNNumber,TaxType ,GSTTaxType, MarginDetID, MarginPerc, MarginOn, MarginAddOn)                     
Values (                            
   @DocSerial,                            
   @Product_Code,                            
   @BatchCode,                            
   @BatchNumber,                            
   @PTS,                  
   @PTR,      
   @ECP,                   
   @SpecialPrice,                            
   @Rate,                            
   @Quantity,                            
   @Amount,                            
   @Expiry,                          
   @PKD,                            
   @TaxSuffered,                            
   @TaxAmount,                            
   @TotalAmount,                          
   @UOM,@UOMQty,@UOMPrice,@TaxID,@VAT,  
   @Serial,@RecQty,@RejQty,@DocQty,@DocFree,@PFM,@MRPforTax,@MRPPerPack,@TOQ, @CSTaxCode, @HSNNumber, @TaxType, @GSTTaxType
   ,@MarginDetID, @MarginPerc, @MarginOn, @MarginAddOn )              
                    
If @BackDatedTransaction = 1                        
Begin                         
 exec sp_update_opening_stock @Product_Code, @OpeningDate, @Quantity, 0, @Rate, 0, 0, @BatchCode
--Insert TaxSuffered in Opening Details  
Exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate , @Product_Code , @BatchCode ,0               
End                              

--------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------ Channel Wise PTR Calclulation--------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------
If IsNull(@BatchCode,0) > 0
Begin
	Insert Into BatchWiseChannelPTR (Batch_Code, ChannelMarginID, ChannelTypeCode, RegisterStatus, ChannelPTR)
	Select @BATCHCODE ,ID , ChannelTypeCode , RegFlag, "ChannelPTR" = @MarginAddOn + @MarginOn * MarginPerc /100 
	From tbl_mERP_ChannelMarginDetail Where MarginDetID =  @MarginDetID
End
--------------------------------------------------------------------------------------------------------------------------------------------------------
                    
If @Free > 0                             
Begin                            
Insert into Batch_Products (Batch_Number, Product_Code, StockTransferID, Expiry, Quantity,                            
       PurchasePrice, SalePrice, PTS, PTR, ECP, QuantityReceived,                   
       Company_Price, PKD, Free,TaxSuffered, BatchReference,                  
       UOM,UOMQTY,UOMPrice,                  
       GRNTaxID, GRNApplicableOn, GRNPartOff, ApplicableOn, PartOfPercentage,Vat_Locality,Serial,PFM,MRPforTax,MRPPerPack,TOQ,GSTTaxType)                                      
     Values (@BatchNumber, @Product_Code, @DocSerial, @Expiry, @Free,                   
       0, 0, 0, 0, @FreeECP, @Free,                   
       0, @PKD, 1, @FreeTaxSuff, @BatchCode,                  
       @UOM,@UOMQTY,0,                  
       @TaxID,@GRNAPPLICABLEON,@GRNPARTOFF,@GRNAPPLICABLEON,@GRNPARTOFF,1,@Serial,@PFM,@MRPforTax,@MRPPerPack,@TOQ,@GSTTaxType)                            
Select @BatchCode = @@Identity                            
                            
Insert into StockTransferInDetail( DocSerial,                            
     Product_Code,                            
     Batch_Code,                            
     Batch_Number,                            
     PTS,                            
     PTR,                             
     ECP,                            
     SpecialPrice,                            
     Rate,                            
     Quantity,                            
     Amount,                            
     Expiry,                            
     PKD,                            
     TaxSuffered,                          
     TaxAmount,                            
     TotalAmount,UOM,UOMQty,UOMPrice,Promotion,TaxCode,VAT,  
  Serial,QuantityReceived,QuantityRejected,DocumentQuantity,DocumentFreeQty,PFM,MRPforTax,MRPPerPack,TOQ
  ,CS_TaxCode, HSNNumber,TaxType ,GSTTaxType)                     
Values (                            
     @DocSerial,                            
     @Product_Code,                            
     @BatchCode,                            
     @BatchNumber,                            
     0,                            
     0,                             
     0,                            
     0,                            
     0,                            
     @Free,                            
     0,                            
     @Expiry,                            
     @PKD,                            
     @TaxSuffered,                            
     @FreeTaxAmt,              
    0,@UOM,@UOMQty,0,@promotion,@TaxID,@VAT,  
  @Serial,0,0,0,0,@PFM,@MRPforTax,@MRPPerPack,@TOQ, @CSTaxCode, @HSNNumber, @TaxType, @GSTTaxType)              
 If @BackDatedTransaction = 1                        
 Begin                         
  exec sp_update_opening_stock @Product_Code, @OpeningDate, @Free, 1, 0, 0, 0, @BatchCode
--Insert TaxSuffered in Opening Details  
  Exec Sp_Update_Opening_TaxSuffered_Percentage @OpeningDate , @Product_Code , @BatchCode ,0    
 End                      
End  
  
declare @track_csp int, @purchased_at int  
select @track_csp = itemcategories.price_option,@purchased_at = items.purchased_at  
from itemcategories, items  where itemcategories.categoryid = items.categoryid  
and items.product_code = @product_Code  
  
if @track_csp = 1   
begin  
 IF @PURCHASED_AT = 1   
 BEGIN  
  update items set sale_price = @PTS, purchase_price = @rate,  
        PTS=@PTS,PTR=@PTR,ECP=@ECP,company_price = @SpecialPrice,PFM=@PFM  
	, MRPPerPack = @MRPPerPack                    
        where items.product_code = @product_Code  
 END  
 ELSE  
 BEGIN  
  update items set sale_price = @PTR, purchase_price = @rate,  
        PTS=@PTS,PTR=@PTR,ECP=@ECP,company_price = @SpecialPrice,PFM=@PFM                       
	, MRPPerPack = @MRPPerPack
        where items.product_code = @product_Code  
 END  
end  

If @TaxSplitup<> ''
Begin
	
	Insert into #tmpTaxCompSplitup
	Exec sp_SplitIn2Matrix @TaxSplitup

	Insert Into GSTSTITaxComponents(STIID,Product_Code,SerialNo,TaxType,Tax_Code,Tax_Component_Code,Tax_Percentage,Tax_Value,
			FirstPoint)
	Select @DocSerial,@product_Code,@Serial,@GSTTaxType,@TaxID,Cast(TC1_TaxComponent_code as int),TC2_Tax_percentage,TC9_TaxAmt,
			Cast(TC10_FirstPoint as int)
	From #tmpTaxCompSplitup
	
	Drop table #tmpTaxCompSplitup
End
                          
Select 1                            

