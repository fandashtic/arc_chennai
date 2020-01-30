CREATE procedure sp_update_BillItems_UOM(@Bill_ID int, @Product_Code as nvarchar(50),       
         @Qty Decimal(18,6),       
         @Price Decimal(18,6),       
         @Amount Decimal(18,6),       
         @GRNID int,       
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
			@Promotion int =0)      
as      
DECLARE @CSP_SET int      
DECLARE @PURCHASEDAT int      
DECLARE @APPLICABLEON INT  
DECLARE @PARTOFF DECIMAL(18,6)  
DECLARE @LOCALITY INT  
DECLARE @BillDate DateTime
DECLARE @OLDVALUE DECIMAL(18,6)  
DECLARE @NEWVALUE DECIMAL(18,6)  
DECLARE @ADJVALUE DECIMAL(18,6)  
SET @OLDVALUE = 0
SET @NEWVALUE = 0
SET @ADJVALUE = 0
Select @OLDVALUE = IsNull(PurchasePrice,0) * IsNull(Quantity,0) from Batch_Products Where Batch_Code = @Batch_Code

SELECT @BillDate=BillDate From BillAbstract Where BillId=@Bill_ID
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
	SpecialPrice, UOM, UOMQty, UOMPrice,ExciseDuty,PurchasePriceBeforeExciseAmount,ExciseID,VAT,Promotion)      
	Values (@Bill_ID, @Product_Code, @Qty, @Price, @Amount, @TaxSuffered, @TaxAmount,       
	@TaxCode, @Discount, @Batch, @Expiry, @PKD, @PTS, @PTR, @ECP, @SpecialPrice, @UOMID,      
	@UOMQty, @UOMPrice, @ExciseDuty, @PurchasePriceBeforeExciseAmount, @ExciseID,@VAT,@Promotion)      
Else    
	Insert into BillDetail (BillID, Product_Code, Quantity, PurchasePrice,       
	Amount, TaxSuffered, TaxAmount, TaxCode, Discount, Batch, Expiry, PKD, PTS, PTR, ECP,      
	SpecialPrice, UOM, UOMQty, UOMPrice,ComboID,ExciseDuty,PurchasePriceBeforeExciseAmount,ExciseID,VAT,Promotion)      
	Values (@Bill_ID, @Product_Code, @Qty, @Price, @Amount, @TaxSuffered, @TaxAmount,       
	@TaxCode, @Discount, @Batch, @Expiry, @PKD, @PTS, @PTR, @ECP, @SpecialPrice, @UOMID,      
	@UOMQty, @UOMPrice,@ComboID, @ExciseDuty, @PurchasePriceBeforeExciseAmount, @ExciseID,@VAT,@Promotion)        


If @Free = 0       
Begin      
	Select @CSP_SET = Price_Option, @PURCHASEDAT = Purchased_At from ItemCategories, Items where      
	ItemCategories.CategoryID = Items.CategoryID and      
	Items.Product_Code = @Product_Code      
	      
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
   
	If @CSP_SET = 1       
	Begin      
		If @PURCHASEDAT = 1       
		Begin      
			Update Batch_Products Set PurchasePrice = @DisPrice,      
			TaxSuffered = @TaxSuffered, ExciseDuty = @ExciseDuty, ExciseID = @ExciseID,  
			APPLICABLEON = @APPLICABLEON,PARTOFPERCENTAGE = @PARTOFF --, PTS = @Price       
			Where Product_Code = @Product_Code and GRN_ID = @GRNID       
			and Batch_Code = @BATCH_CODE and Free = 0      
		End      
		Else If @PURCHASEDAT = 2       
		Begin      
			Update Batch_Products Set PurchasePrice = @DisPrice,      
			TaxSuffered = @TaxSuffered, ExciseDuty = @ExciseDuty, ExciseID = @ExciseID,  
			APPLICABLEON = @APPLICABLEON,PARTOFPERCENTAGE = @PARTOFF --, PTR = @Price       
			Where Product_Code = @Product_Code and GRN_ID = @GRNID       
			and Batch_Code = @BATCH_CODE and Free = 0      
		End   
	End      
	Else      
	Begin      
		If @PURCHASEDAT = 1      
		Begin      
			Update Batch_Products Set PurchasePrice = @DisPrice,      
			TaxSuffered = @TaxSuffered, ExciseDuty = @ExciseDuty, ExciseID = @ExciseID,  
			APPLICABLEON = @APPLICABLEON,PARTOFPERCENTAGE = @PARTOFF --, PTS = @Price      
			Where Product_Code = @Product_Code and GRN_ID = @GRNID and Free = 0      
		End      
		Else If @PURCHASEDAT = 2      
		Begin      
			Update Batch_Products Set PurchasePrice = @DisPrice,      
			TaxSuffered = @TaxSuffered, ExciseDuty = @ExciseDuty, ExciseID = @ExciseID,  
			APPLICABLEON = @APPLICABLEON,PARTOFPERCENTAGE = @PARTOFF --, PTR = @Price       
			Where Product_Code = @Product_Code and GRN_ID = @GRNID and Free = 0      
		End      
	End      
End      
Select @NEWVALUE = IsNull(PurchasePrice,0) * IsNull(Quantity,0) from Batch_Products Where Batch_Code = @Batch_Code
SET @ADJVALUE = @NEWVALUE - @OLDVALUE
--Updating Opening_Value in OpeningDetails table.
IF @ADJVALUE <> 0 
	Exec Sp_Update_Opening_Stock @Product_Code, @BillDate, 0, @Free, 0, 0, @ADJVALUE

--Updating TaxSuff Percentage in OpeningDetails
If @LOCALITY = 2 AND @VAT = 1
	Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @Product_Code, @Batch_Code, 0, 1
Else
	Exec Sp_Update_Opening_TaxSuffered_Percentage @BillDate, @Product_Code, @Batch_Code, 0, 0



