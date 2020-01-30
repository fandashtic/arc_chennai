CREATE procedure sp_update_MultipleGRN_BillItems(@Bill_ID int, @Product_Code as nvarchar(50),         
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
         @Promotion int = 0,    
			@ExciseDuty Decimal(18,6) = 0,    
			@PurchasePriceBeforeExciseAmount Decimal(18,6) = 0,    
			@ExciseID Int = 0,     
			@VAT int = 0)        
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
else
	Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @Product_Code, @Batch_Code, 1, 0

If @Promotion = 1         
Begin        
	Select @ECP = ECP From Batch_Products Where Batch_Code In (Select BatchReference From        
	Batch_Products Where Free = 1 And Batch_Code = @BATCH_CODE)        

	Update Batch_Products Set ECP = @ECP, TaxSuffered = @TaxSuffered,         
	Promotion = @Promotion        
	Where Free = 1 And Batch_code = @BATCH_CODE        
End        
Insert into BillDetail (BillID, Product_Code, Quantity, PurchasePrice,         
Amount, TaxSuffered, TaxAmount, TaxCode, Discount, Batch, Expiry, PKD, PTS, PTR, ECP,        
SpecialPrice, Promotion, ExciseDuty,PurchasePriceBeforeExciseAmount,ExciseID,VAT)        
values (@Bill_ID, @Product_Code, @Qty, @Price, @Amount, @TaxSuffered, @TaxAmount,         
@TaxCode, @Discount, @Batch, @Expiry, @PKD, @PTS, @PTR, @ECP, @SpecialPrice, @Promotion,    
@ExciseDuty, @PurchasePriceBeforeExciseAmount, @ExciseID,@VAT)        
        
IF @Free = 0         
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
  	
	update Batch_Products     
	set PurchasePrice = @DisPrice, TaxSuffered = @TaxSuffered, ExciseDuty = @ExciseDuty,     
	ExciseID = @ExciseID ,APPLICABLEON = @APPLICABLEON,PARTOFPERCENTAGE = @PARTOFF  
	where Batch_Code = @BATCH_CODE and Free = 0      
End    
Select @NEWVALUE = IsNull(PurchasePrice,0) * IsNull(Quantity,0) from Batch_Products Where Batch_Code = @Batch_Code
SET @ADJVALUE = @NEWVALUE - @OLDVALUE
--Updating Opening_Value in OpeningDetails table.
IF @ADJVALUE <> 0 
	Exec Sp_Update_Opening_Stock @Product_Code, @BillDate, 0, @Free, 0, 0, @ADJVALUE

--Updating TaxSuff Percentage in OpeningDetails
If @LOCALITY = 2 AND @VAT = 1
	Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @Product_Code, @Batch_Code, 0, 1
else
	Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @Product_Code, @Batch_Code, 0, 0






