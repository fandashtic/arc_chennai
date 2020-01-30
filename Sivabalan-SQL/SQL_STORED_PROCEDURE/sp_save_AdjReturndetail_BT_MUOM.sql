Create Procedure sp_save_AdjReturndetail_BT_MUOM (@ADJUSTMENTID INT,                
 @ITEM_CODE NVARCHAR(15),                
 @BATCH_NUMBER NVARCHAR(255),                 
 @RATE Decimal(18,6),                 
 @REQUIRED_QUANTITY Decimal(18,6),                
 @REASONID INT,                
 @TRACK_BATCHES INT,    
 @BillID int,                
 @FreeRow int = 0,                
 @OpeningDate datetime = Null,                
 @BackDatedTransaction int = 0,                
 @TaxSuffered decimal(18,6) ,                 
 @Total_Value decimal(18,6),              
 @UOM INT =0,              
 @UOMQTY Decimal(18,6)=0,              
 @UOMPrice Decimal(18,6)=0,            
 @ApplicableOn Int =0,            
 @PartOff Decimal(18,6)=0,@VAT Int = 0,  
 @TaxAmount Decimal(18,6) = 0,                           
 @BatchPrice Decimal (18, 6)=0,    
 @BatchTax Decimal (18, 6)=0,     
 @BatchTaxApplicableOn Int=0,     
 @BatchTaxPartOff Decimal(18, 6)=0,  
 @SerialNo int=0,
 @MRPPerPACK Decimal(18, 6)=0,
 @TaxOnQty int= 0
,@BillOrgID Int =0
,@GRNTaxID Int = 0
,@CSTaxID Int = 0
,@GRNTaxType Int = 0
,@GSTFlag Int = 0
,@HSNNumber nVarChar(15) = ''
, @TaxSplitup nVarChar(Max) = ''
)    
AS                
DECLARE @BATCH_CODE INT                 
DECLARE @QUANTITY Decimal(18,6)                
DECLARE @RETVAL Decimal(18,6)                
DECLARE @TOTAL_QUANTITY Decimal(18,6)                
DECLARE @DIFF Decimal(18,6)                
--DECLARE @MRPPERPACK Decimal(18,6)

Declare @GRNIDs nVarChar(255)
Select @GRNIDs = GRNID From BillAbstract Where BillID = @BillOrgID
Select GRNID = Convert(Int,ItemValue) Into #tmpGRNs From dbo.sp_SplitIn2Rows(@GRNIDs,',')

Create Table #tmpTaxCompSplitup(
					RowID int, TC1_TaxComponent_Code Decimal(18,6),TC2_Tax_percentage Decimal(18,6),
					TC3_CS_ComponentCode Decimal(18,6),TC4_ComponentType Decimal(18,6),TC5_ApplicableonComp Decimal(18,6),
					TC6_ApplicableOnCode Decimal(18,6),TC7_ApplicableUOM Decimal(18,6),TC8_PartOff Decimal(18,6),TC9_TaxAmt Decimal(18,6),
					TC10_FirstPoint Decimal(18,6), TC11_STCrFlag Decimal(18,6), TC12_STCrAmt Decimal(18,6), TC13_NetTaxAmt Decimal(18,6))
          
IF @TRACK_BATCHES = 1                
BEGIN                
 SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity),0) FROM Batch_Products                 
 Join #tmpGRNs GRN On GRN.GRNID = Batch_Products.GRN_ID
 WHERE Product_Code = @ITEM_CODE AND Batch_Number = @BATCH_NUMBER                 
 AND ISNULL(PurchasePrice,0) = @BatchPrice And Isnull(MRPPerPACK,0)=@MRPPerPACK And isnull(Free, 0) = @FreeRow                
 And Quantity > 0 And IsNull(Damage, 0) = 0 And IsNull(TaxSuffered,0) = @BatchTax                
 And IsNull(ApplicableOn,0) = @BatchTaxApplicableOn And IsNull(PartOfPercentage,0) = @BatchTaxPartOff      
                
 DECLARE ReleaseStocks CURSOR KEYSET FOR                
 SELECT Batch_Number, Batch_Code, Quantity FROM Batch_Products                
 Join #tmpGRNs GRN On GRN.GRNID = Batch_Products.GRN_ID 
 WHERE Product_Code = @ITEM_CODE and Batch_Number = @BATCH_NUMBER                 
 and ISNULL(PurchasePrice, 0) = @BatchPrice And Isnull(MRPPerPACK,0)=@MRPPerPACK  And isnull(Free, 0) = @FreeRow                
 And Quantity > 0 And IsNull(Damage, 0) = 0 And IsNull(TaxSuffered,0) = @BatchTax               
 And IsNull(ApplicableOn,0) = @BatchTaxApplicableOn And IsNull(PartOfPercentage,0) = @BatchTaxPartOff                   
END                
ELSE                
BEGIN                
 SELECT @TOTAL_QUANTITY = ISNULL(SUM(Quantity),0) FROM Batch_Products                 
 Join #tmpGRNs GRN On GRN.GRNID = Batch_Products.GRN_ID 
 WHERE Product_Code = @ITEM_CODE and ISNULL(PurchasePrice, 0) = @BatchPrice And Isnull(MRPPerPACK,0)=@MRPPerPACK                 
 And isnull(Free, 0) = @FreeRow And Quantity > 0 And IsNull(Damage, 0) = 0                
 And IsNull(TaxSuffered,0) = @BatchTax      
 And IsNull(ApplicableOn,0) = @BatchTaxApplicableOn And IsNull(PartOfPercentage,0) = @BatchTaxPartOff                   
    
 DECLARE ReleaseStocks CURSOR KEYSET FOR                
 SELECT Batch_Number, Batch_Code, Quantity FROM Batch_Products                
 Join #tmpGRNs GRN On GRN.GRNID = Batch_Products.GRN_ID 
 WHERE Product_Code = @ITEM_CODE AND ISNULL(PurchasePrice, 0) = @BatchPrice And Isnull(MRPPerPACK,0)=@MRPPerPACK                 
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
  --Select @MRPPERPACK=MRPPerPack from Batch_Products WHERE Batch_Code = @BATCH_CODE  
  INSERT INTO AdjustmentReturnDetail(AdjustmentID, Product_Code,       
  BatchNumber, BatchCode, Quantity, Rate,ReasonID, BillID, Tax, Total_Value,UOM,UOMQty,UOMPrice,            
  TaxSuffApplicableOn,TaxSuffPartOff,VAT,TaxAmount, BatchPrice, BatchTax, BatchTaxApplicableOn, BatchTaxPartOff,   
  SerialNo,MRPPerPack,TAXONQTY
  ,BillOrgID,   Tax_Code, CS_TaxCode, GSTTaxType, GSTFlag, HSNNumber)                        
  VALUES (@ADJUSTMENTID, @ITEM_CODE,@BATCH_NUMBER, @BATCH_CODE, @REQUIRED_QUANTITY,              
  @RATE,@REASONID, @BillID, @TaxSuffered, @Total_Value,@UOM,@UOMQTY,@UOMPrice,            
  @ApplicableOn,@PartOff,@VAT,@TaxAmount, @BatchPrice, @BatchTax, @BatchTaxApplicableOn,   
  @BatchTaxPartOff, @SerialNo,@MRPPERPACK,@TaxOnQty
  ,@BillOrgID, @GRNTaxID, @CSTaxID, @GRNTaxType, @GSTFlag, @HSNNumber)        

If @TaxSplitup<> ''
Begin
	
	Insert into #tmpTaxCompSplitup
	Exec sp_SplitIn2Matrix @TaxSplitup

	Insert Into PRTaxComponents(AdjustmentID,Product_Code,SerialNo,TaxType,Tax_Code,Tax_Component_Code,Tax_Percentage,Tax_Value,
			FirstPoint)
	Select @ADJUSTMENTID,@ITEM_CODE,@SerialNo,@GRNTaxType,@GRNTaxID,Cast(TC1_TaxComponent_code as int),TC2_Tax_percentage,TC9_TaxAmt,
			Cast(TC10_FirstPoint as int)
	From #tmpTaxCompSplitup
	
	Delete From #tmpTaxCompSplitup
End
    
  IF @BackDatedTransaction = 1                 
  BEGIN                
   SET @DIFF = 0 - @REQUIRED_QUANTITY                
   exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @BatchPrice, 0, 0, @BATCH_CODE
  END                
     GOTO OVERNOUT                
 END                
 ELSE                
 BEGIN                
  set @REQUIRED_QUANTITY = @REQUIRED_QUANTITY - @QUANTITY                
  UPDATE Batch_Products SET Quantity = 0 where Batch_Code = @BATCH_CODE    

  --Select @MRPPERPACK=MRPPerPack from Batch_Products WHERE Batch_Code = @BATCH_CODE  
            
  INSERT INTO AdjustmentReturnDetail(AdjustmentID, Product_Code, BatchNumber,                 
  BatchCode, Quantity, Rate,ReasonID, BillID, Tax, Total_Value,UOM,UOMQty,UOMPrice,            
  TaxSuffApplicableOn,TaxSuffPartOff,VAT,TaxAmount, BatchPrice, BatchTax, BatchTaxApplicableOn,   
  BatchTaxPartOff, SerialNo,MRPPerPack
  ,BillOrgID,   Tax_Code, CS_TaxCode, GSTTaxType, GSTFlag, HSNNumber)                            
  VALUES (@ADJUSTMENTID, @ITEM_CODE, @BATCH_NUMBER,@BATCH_CODE, @QUANTITY,                 
  @RATE,@REASONID, @BillID, @TaxSuffered, @Total_Value,@UOM,@UOMQTY,@UOMPrice,            
  @ApplicableOn,@PartOff,@VAT,@TaxAmount, @BatchPrice, @BatchTax, @BatchTaxApplicableOn,  
  @BatchTaxPartOff, @SerialNo,@MRPPERPACK
  ,@BillOrgID, @GRNTaxID, @CSTaxID, @GRNTaxType, @GSTFlag, @HSNNumber)        

If @TaxSplitup<> ''
Begin
	
	Insert into #tmpTaxCompSplitup
	Exec sp_SplitIn2Matrix @TaxSplitup

	Insert Into PRTaxComponents(AdjustmentID,Product_Code,SerialNo,TaxType,Tax_Code,Tax_Component_Code,Tax_Percentage,Tax_Value,
			FirstPoint)
	Select @ADJUSTMENTID,@ITEM_CODE,@SerialNo,@GRNTaxType,@GRNTaxID,Cast(TC1_TaxComponent_code as int),TC2_Tax_percentage,TC9_TaxAmt,
			Cast(TC10_FirstPoint as int)
	From #tmpTaxCompSplitup
	
	Delete From #tmpTaxCompSplitup
End
  
  --After updating the first batch make total amount and tax value to Zero  
  --Uomqty also be chaged to zero  
  SET @Total_Value = 0    
  SET @TaxAmount = 0  
    set @UOMQTY = 0  
  
  IF @BackDatedTransaction = 1                 
  BEGIN                
   SET @DIFF = 0 - @QUANTITY                
   exec sp_update_opening_stock @ITEM_CODE, @OpeningDate, @DIFF, @FreeRow, @BatchPrice, 0, 0, @BATCH_CODE
  END                
 END                 
 FETCH NEXT FROM ReleaseStocks into @BATCH_NUMBER, @BATCH_CODE, @QUANTITY             
END                
OVERNOUT:                
CLOSE ReleaseStocks                
DEALLOCATE ReleaseStocks                

Drop Table #tmpTaxCompSplitup
Drop Table #tmpGRNs

SELECT @RETVAL             
