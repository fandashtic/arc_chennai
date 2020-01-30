CREATE PROCEDURE [sp_put_InvoiceDocFooter](            
@ForumCode [nvarchar](15),            
@Quantity  Decimal(18,6),            
@SalePrice  Decimal(18,6),            
@TaxCode  [float],            
@DiscountPercentage  Decimal(18,6),            
@DiscountValue  Decimal(18,6),            
@Amount  Decimal(18,6),            
@PTR Decimal(18, 6),            
@MRP Decimal(18, 6),            
@Batch_Number nvarchar(100),            
@PKD nvarchar(10),            
@Expiry nvarchar(10),            
@PTS Decimal(18, 6),             
@FreePTS Decimal(18,6),            
@FreePTR Decimal(18,6),            
@FreeMRP Decimal(18,6),            
@InvoiceID  [int],            
@TaxApplicableOn int = 1,          
@TaxPartOff  Decimal(18,6) = 100,          
@TaxSuffApplicableOn int = 1,          
@TaxSuffPartOff  Decimal(18,6) = 100,          
@ItemMRP Decimal(18,6) = 0,          
@Company_Price Decimal(18,6) = 0,          
@ExciseDutyPerc Decimal(18,6) = 0,          
@ExciseAmount Decimal(18,6) = 0          
 )            
AS             
Declare @Product_Code nvarchar(20)            
Declare @PkdDate DateTime    
Declare @ExpDate Datetime
SET DATEFORMAT DMY    
Set @PkdDate=@PKD    
Set @ExpDate=@Expiry
INSERT INTO [InvoiceDetailReceived]             
(             
ForumCode,            
[Quantity],            
[SalePrice],            
[TaxCode],            
[DiscountPercentage],            
[DiscountValue],            
[Amount],            
PTR,            
MRP,            
Batch_Number,            
PKD,            
Expiry,            
PTS,            
[InvoiceID],            
FreePTS,            
FreePTR,            
FreeMRP,            
TaxApplicableOn,          
TaxPartOff,          
TaxSuffApplicableOn,          
TaxSuffPartOff,          
ItemMRP,          
Company_Price,        
ExciseDuty,        
ExcisePercentage          
)                       
VALUES             
(             
@ForumCode,            
@Quantity,            
@SalePrice,            
@TaxCode,            
@DiscountPercentage,            
@DiscountValue,            
@Amount,            
@PTR,            
@MRP,            
@Batch_Number,            
@PkdDate,            
@ExpDate,            
@PTS,            
@InvoiceID,            
@FreePTS,            
@FreePTR,            
@FreeMRP,            
@TaxApplicableOn,          
@TaxPartOff,          
@TaxSuffApplicableOn,          
@TaxSuffPartOff,          
@ItemMRP,          
@Company_Price,        
@ExciseAmount,      
@ExciseDutyPerc      
)          
Select @Product_Code = Product_Code From Items Where Alias = @ForumCode            
If @Product_Code Is Not Null            
Begin            
	Update  InvoiceDetailReceived Set Product_Code = @Product_Code             
	Where InvoiceID = @InvoiceID And ForumCode = @ForumCode            
End
--end

