CREATE Procedure sp_get_Invoice_ComboId_Batch_CP  
    (@PRODUCT_CODE nvarchar(15),    
       @TRACK_BATCH int,        
          @CAPTURE_PRICE int,        
         @CUSTOMER_TYPE int,    
     @Batch_Number nvarchar(128),    
     @SALEPRICE Decimal(18,6),    
     @FREE Decimal(18,6),    
     @TAXSUFFERED Decimal(18,6),    
	 @CUSTOMERSUFFERSTAX Decimal(18,6),
     @GetDate Datetime = Getdate)         As  
Begin  
  
 Select dbo.sp_get_Invoice_ComboId_Batch_ComboPack       
  (@PRODUCT_CODE ,    
         @TRACK_BATCH ,       
         @CAPTURE_PRICE ,        
         @CUSTOMER_TYPE ,    
      @Batch_Number ,    
      @SALEPRICE ,    
      @FREE ,    
      @TAXSUFFERED ,    
	  @CUSTOMERSUFFERSTAX, 
      @GetDate)           
  
 End  

