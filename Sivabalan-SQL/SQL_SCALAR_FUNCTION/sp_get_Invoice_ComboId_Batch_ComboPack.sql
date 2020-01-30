CREATE Function sp_get_Invoice_ComboId_Batch_ComboPack   
    (@PRODUCT_CODE nvarchar(15),  
     @TRACK_BATCH int,      
     @CAPTURE_PRICE int,      
     @CUSTOMER_TYPE int,  
     @Batch_Number nvarchar(128),  
     @SALEPRICE Decimal(18,6),  
     @FREE Decimal(18,6),  
     @TAXSUFFERED Decimal(18,6),  
	 @CUSTOMERSUFFERSTAX Decimal(18,6),
     @GetDate Datetime = Getdate)      
Returns int   
AS      
Begin  
Declare @COMBO_COMPONENT_COMBOID as int   
  
-- @SalesPrice and @ECP Should Contain Only Unit Price (i.e Price of Single Quantity)  
-- Since Batch Products Will have PTS, PTR etc Prices for Base UOM and 1 Quantity  
  
  
  
IF @CAPTURE_PRICE = 1      
 BEGIN      
 IF @TRACK_BATCH = 1      
  BEGIN      
  IF @CUSTOMER_TYPE = 1       
  BEGIN      
  Select   
   @COMBO_COMPONENT_COMBOID = Max(ComboId)  
   From  
   Batch_Products  
  Where  
   Isnull(Batch_Number,N'') = @Batch_Number and   
   (Expiry >= @GetDate Or Expiry IS NULL) and  
   Isnull(PTS,0) = @SALEPRICE and   
   Isnull(FREE,0) = @Free and  
   (Isnull(TaxSuffered,0) = @TaxSuffered or @CUSTOMERSUFFERSTAX = 0) and  
   Product_Code= @Product_Code AND   
      Quantity > 0 And ISNULL(Damage, 0) = 0   
  END      
  ELSE IF @CUSTOMER_TYPE = 2       
  BEGIN      
  Select   
   @COMBO_COMPONENT_COMBOID = Max(ComboId)  
   From  
   Batch_Products  
  Where  
   Isnull(Batch_Number,N'') = @Batch_Number and   
   (Expiry >= @GetDate Or Expiry IS NULL) and  
   Isnull(PTR,0) = @SALEPRICE and   
   Isnull(FREE,0) = @Free and  
   (Isnull(TaxSuffered,0) = @TaxSuffered or @CUSTOMERSUFFERSTAX = 0) and   
   Product_Code= @Product_Code AND   
     Quantity > 0 And ISNULL(Damage, 0) = 0   
  
  END      
  ELSE IF @CUSTOMER_TYPE = 3       
  BEGIN      
  Select   
   @COMBO_COMPONENT_COMBOID = Max(ComboId)  
   From  
   Batch_Products  
  Where  
   Isnull(Batch_Number,N'') = @Batch_Number and   
   (Expiry >= @GetDate Or Expiry IS NULL) and  
   Isnull(Company_Price,0) = @SALEPRICE and   
   Isnull(FREE,0) = @Free and  
   (Isnull(TaxSuffered,0) = @TaxSuffered or @CUSTOMERSUFFERSTAX = 0) and   
   Product_Code= @Product_Code AND   
     Quantity > 0 And ISNULL(Damage, 0) = 0   
  
  END      
  ELSE IF @CUSTOMER_TYPE = 4       
  BEGIN      
  Select   
   @COMBO_COMPONENT_COMBOID = Max(ComboId)  
   From  
   Batch_Products  
  Where  
   Isnull(Batch_Number,N'') = @Batch_Number and   
   (Expiry >= @GetDate Or Expiry IS NULL) and  
   Isnull(ECP,0) = @SALEPRICE and   
   Isnull(FREE,0) = @Free and  
   (Isnull(TaxSuffered,0) = @TaxSuffered or @CUSTOMERSUFFERSTAX = 0)and   
   Product_Code= @Product_Code AND   
     Quantity > 0 And ISNULL(Damage, 0) = 0   
  
  END      
  END      
 ELSE      
    BEGIN      
  IF @CUSTOMER_TYPE = 1       
  BEGIN      
  Select   
   @COMBO_COMPONENT_COMBOID = Max(ComboId)  
   From  
   Batch_Products  
  Where  
   Isnull(PTS,0) = @SALEPRICE and   
   Isnull(FREE,0) = @Free and  
   (Isnull(TaxSuffered,0) = @TaxSuffered or @CUSTOMERSUFFERSTAX = 0) and   
   Product_Code= @Product_Code AND   
     Quantity > 0 And ISNULL(Damage, 0) = 0   
  
  END      
  ELSE IF @CUSTOMER_TYPE = 2       
  BEGIN      
  Select   
   @COMBO_COMPONENT_COMBOID = Max(ComboId)  
   From  
   Batch_Products  
  Where  
   Isnull(PTR,0) = @SALEPRICE and   
   Isnull(FREE,0) = @Free and  
   (Isnull(TaxSuffered,0) = @TaxSuffered or @CUSTOMERSUFFERSTAX = 0) and   
   Product_Code= @Product_Code AND   
     Quantity > 0 And ISNULL(Damage, 0) = 0   
  
  END      
  ELSE IF @CUSTOMER_TYPE = 3       
  BEGIN      
  Select   
   @COMBO_COMPONENT_COMBOID = Max(ComboId)  
   From  
   Batch_Products  
  Where  
   Isnull(Company_Price,0) = @SALEPRICE and   
   Isnull(FREE,0) = @Free and  
   (Isnull(TaxSuffered,0) = @TaxSuffered or @CUSTOMERSUFFERSTAX = 0) and   
   Product_Code= @Product_Code AND   
     Quantity > 0 And ISNULL(Damage, 0) = 0   
  
  END      
  ELSE IF @CUSTOMER_TYPE = 4       
  BEGIN      
  Select   
   @COMBO_COMPONENT_COMBOID = Max(ComboId)  
   From  
   Batch_Products  
  Where  
   Isnull(ECP,0) = @SALEPRICE and   
   Isnull(FREE,0) = @Free and  
   (Isnull(TaxSuffered,0) = @TaxSuffered or @CUSTOMERSUFFERSTAX = 0)and   
   Product_Code= @Product_Code AND   
     Quantity > 0 And ISNULL(Damage, 0) = 0   
  
  END      
  END      
 END      
ELSE      
 BEGIN      
 IF @TRACK_BATCH = 1      
 BEGIN      
  Select   
   @COMBO_COMPONENT_COMBOID = Max(ComboId)  
   From  
   Batch_Products  
  Where  
   Isnull(Batch_Number,N'') = @Batch_Number and   
   (Expiry >= @GetDate Or Expiry IS NULL) and  
   Isnull(FREE,0) = @Free and  
   (Isnull(TaxSuffered,0) = @TaxSuffered or @CUSTOMERSUFFERSTAX = 0) and   
   Product_Code= @Product_Code AND   
     Quantity > 0 And ISNULL(Damage, 0) = 0   
  
 END      
 ELSE      
 BEGIN      
  Select   
   @COMBO_COMPONENT_COMBOID = Max(ComboId)  
   From  
   Batch_Products  
  Where  
   Isnull(FREE,0) = @Free and  
   (Isnull(TaxSuffered,0) = @TaxSuffered or @CUSTOMERSUFFERSTAX = 0) and   
   Product_Code= @Product_Code AND   
      Quantity > 0 And ISNULL(Damage, 0) = 0   
  
 END      
END     
  
Return @COMBO_COMPONENT_COMBOID  
End  

