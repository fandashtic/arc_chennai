CREATE PROCEDURE sp_get_bookstock_Adjutment_MUOM(@PRODUCT_CODE nvarchar(15),            
      @TRACK_BATCH int, @BillID Int = 0)                 
AS            
Declare @PriceOpt int             
Declare @CategoryID int             
Declare @TaxCode int             
Declare @TaxSuffered Decimal(18,6)            
Declare @GRNIDs nVarChar(255)

Select @CategoryID = CategoryID, @TaxCode = IsNull(TaxSuffered,0)             
From Items Where Product_Code = @Product_code            

Select @GRNIDs = GRNID From BillAbstract Where BillID = @BillID

Select GRNID = Convert(Int,ItemValue) Into #tmpGRNs From dbo.sp_SplitIn2Rows(@GRNIDs,',')
            
IF @TRACK_BATCH = 1            
BEGIN            
IF @BillID > 0
 Select Batch_Number, Expiry, SUM(Quantity), PurchasePrice, IsNull(Free, 0),            
 IsNull(TaxSuffered,0), PKD as PKD,PTS,PTR,ECP,Company_Price,  
 IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0),MRPPerPack,Isnull(TOQ,0) TOQ
,"GRNTaxID" = GRNTaxID, "TaxType"= Case When IsNull(TaxType,0) = 5 Then IsNull(GSTTaxType,0) Else IsNull(TaxType,0) End
 From Batch_Products             
 where Product_Code= @PRODUCT_CODE AND Quantity > 0 And IsNull(Damage, 0) = 0 And GRN_ID in (Select GRNID From #tmpGRNs)
 Group By Batch_Number, Expiry, PurchasePrice, PKD, IsNull(Free, 0), IsNull(TaxSuffered,0),      
 PTS,PTR,ECP,Company_Price,  
 IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0),MRPPerPack,Isnull(TOQ,0) ,GRNTaxID, TaxType, GSTTaxType
 Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code) 
Else
 Select Batch_Number, Expiry, SUM(Quantity), PurchasePrice, IsNull(Free, 0),            
 IsNull(TaxSuffered,0), PKD as PKD,PTS,PTR,ECP,Company_Price,  
 IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0),MRPPerPack,Isnull(TOQ,0) TOQ
,"GRNTaxID" = GRNTaxID, "TaxType"= Case When IsNull(TaxType,0) = 5 Then IsNull(GSTTaxType,0) Else IsNull(TaxType,0) End
 From Batch_Products             
 where Product_Code= @PRODUCT_CODE AND Quantity > 0 And IsNull(Damage, 0) = 0            
 Group By Batch_Number, Expiry, PurchasePrice, PKD, IsNull(Free, 0), IsNull(TaxSuffered,0),      
 PTS,PTR,ECP,Company_Price,  
 IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0),MRPPerPack,Isnull(TOQ,0) ,GRNTaxID, TaxType, GSTTaxType
 Order By Isnull(Free, 0), IsNull(Expiry,'9999'), PKD, MIN(Batch_Code) 
END            
ELSE            
BEGIN            
If @BillID > 0
 Select N'', '', SUM(Quantity), PurchasePrice, IsNull(Free, 0),            
 IsNull(TaxSuffered,0), PKD as PKD,PTS,PTR,ECP,Company_Price,  
 IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0),MRPPerPack ,Isnull(TOQ,0) TOQ  
,"GRNTaxID"=GRNTaxID, "TaxType"= Case When IsNull(TaxType,0) = 5 Then IsNull(GSTTaxType,0) Else IsNull(TaxType,0) End
 From Batch_Products             
 where Product_Code= @PRODUCT_CODE AND Quantity > 0 And IsNull(Damage, 0) = 0 And GRN_ID in (Select GRNID From #tmpGRNs)
 Group By PurchasePrice, IsNull(Free, 0), IsNull(TaxSuffered,0),PKD,  
 PTS,PTR,ECP,Company_Price,    
 IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0),MRPPerPack ,Isnull(TOQ,0)  ,GRNTaxID, TaxType, GSTTaxType
 Order By Isnull(Free, 0), MIN(Batch_Code)      
Else
 Select N'', '', SUM(Quantity), PurchasePrice, IsNull(Free, 0),            
 IsNull(TaxSuffered,0), PKD as PKD,PTS,PTR,ECP,Company_Price,  
 IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0),MRPPerPack ,Isnull(TOQ,0) TOQ  
,"GRNTaxID"=GRNTaxID, "TaxType"= Case When IsNull(TaxType,0) = 5 Then IsNull(GSTTaxType,0) Else IsNull(TaxType,0) End
 From Batch_Products             
 where Product_Code= @PRODUCT_CODE AND Quantity > 0 And IsNull(Damage, 0) = 0            
 Group By PurchasePrice, IsNull(Free, 0), IsNull(TaxSuffered,0),PKD,  
 PTS,PTR,ECP,Company_Price,    
 IsNull(ApplicableOn,0),IsNull(PartOfPercentage,0),MRPPerPack ,Isnull(TOQ,0)  ,GRNTaxID, TaxType, GSTTaxType
 Order By Isnull(Free, 0), MIN(Batch_Code)      
END       
