CREATE procedure [dbo].[sp_put_INVOICEDocFooter_Branch]  
(  
@InvoiceID int,  
@ItemCode nvarchar(20),  
@Batch_Number nvarchar(50),  
@Quantity Decimal(18, 6),  
@SalePrice Decimal(18, 6),   
@DiscountPercentage Decimal(18, 6),  
@DiscountValue Decimal(18, 6),  
@Amount Decimal(18, 6),  
@PTS Decimal(18, 6),  
@PTR Decimal(18, 6),  
@MRP Decimal(18, 6),  
@TaxCode Decimal(18, 6),  
@PurchasePrice Decimal(18, 6),  
@STPayable Decimal(18, 6),  
@FlagWord int,  
@SaleID int,  
@CSTPayable Decimal(18, 6),  
@TaxCode2 Decimal(18, 6),  
@TaxSuffered Decimal(18, 6),  
@TaxSuffered2 Decimal(18, 6),  
@TaxApplicableOn int = 0,        
@TaxPartOff  Decimal(18,6) = 0,        
@TaxSuffApplicableOn int = 0,        
@TaxSuffPartOff  Decimal(18,6) = 0,        
--@ItemMRP Decimal(18,6) = 0,       
--@Company_Price Decimal(18,6) = 0,        
@ExciseDutyPerc Decimal(18,6) = 0,        
@ExciseAmount Decimal(18,6) = 0,
@nSerial Int = 0        
)  
AS  
DECLARE @ItemId AS nvarchar(20)  
DECLARE @TAXID int    
DECLARE @LOCALITY int    
DECLARE @BATCHCODE INT  
DECLARE @EXCISETAXID int    
  
Declare @SPBED Decimal(18,6)

--To get ExciseTax code  
SELECT TOP 1 @EXCISETAXID = Tax_Code From ExciseTax Where Percentage = @ExciseDutyPerc  
IF (@EXCISETAXID >0) 
	Begin
		Select @SPBED=@SalePrice-@ExciseAmount			
	End
Else 
	Begin
		Select @SPBED=0
		Select @ExciseAmount=0
	End	

SELECT @ItemId = isnull(PRODUCT_CODE,@ItemCode) FROM ITEMS WHERE ALIAS = @ItemCode  
Select @LOCALITY = IsNull(case InvoiceType When 2 Then 1 Else Locality End, 0) From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID *= Customer.CustomerID And InvoiceID = @INVOICEID    
IF @LOCALITY = 0 SET @LOCALITY = 1    
IF @LOCALITY = 1    
 SELECT @TAXID = Tax_Code FROM Tax WHERE Percentage = @TAXCODE    
ELSE    
 SELECT @TAXID = Tax_Code FROM Tax WHERE ISNULL(CST_Percentage, 0) = @TAXCODE2    
SET @BATCHCODE = 0  
INSERT INTO INVOICEDETAIL  
(  
InvoiceID,  
Product_code,  
Batch_Number ,  
Quantity,  
SalePrice,  
DiscountPercentage,  
DiscountValue,  
Amount,  
PTS,  
PTR,  
MRP,  
TaxCode,  
PurchasePrice,  
STPayable,  
FlagWord,  
SaleID,  
CSTPayable,  
TaxCode2,  
TaxSuffered,  
TaxSuffered2,  
TaxID,  
batch_code,  
TaxApplicableOn,        
TaxPartOff,        
TaxSuffApplicableOn,        
TaxSuffPartOff,        
--ItemMRP,        
--Company_Price,      
ExciseDuty,      
ExciseID,
Serial,
SalePricebeforeExciseAmount  
)  
VALUES  
(  
@InvoiceID,  
@ItemId,  
@Batch_Number ,  
@Quantity,  
@SalePrice,  
@DiscountPercentage,  
@DiscountValue,  
@Amount,  
@PTS,  
@PTR,  
@MRP,  
@TaxCode,  
@PurchasePrice,  
@STPayable,  
@FlagWord,  
@SaleID,  
@CSTPayable,  
@TaxCode2,  
@TaxSuffered,  
@TaxSuffered2,  
@TaxID,  
@BATCHCODE,  
@TaxApplicableOn,        
@TaxPartOff,        
@TaxSuffApplicableOn,        
@TaxSuffPartOff,        
--@ItemMRP,        
--@Company_Price,      
@ExciseAmount,  
@ExciseTaxID,
@nSerial,
@SPBED  
)
