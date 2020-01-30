CREATE PROCEDURE sp_put_InvoiceDocHeader_Pidilite  
 (@InvoiceID [int],   
  @InvoiceDate  [datetime],  
  @VendorID  [nvarchar](15),  
  @GrossValue  Decimal(18,6),  
  @DiscountPercentage  Decimal(18,6),  
  @AdditionalDiscount  Decimal(18,6),  
  @DiscountValue  Decimal(18,6),  
  @NetValue  Decimal(18,6),  
  @CreditTerm [int],  
  @TaxLocation  [nvarchar](50),  
  @Freight Decimal(18,6),  
  @DocumentID nvarchar(50),  
  @BillingAddress nvarchar(255),  
  @ShippingAddress nvarchar(255),  
  @Flags int,   
  @POSerialNumber Varchar(50),  
  @PODate Datetime,  
  @NetTaxAmount Decimal(18, 6),  
  @AdjustedAmount Decimal(18, 6),  
  @PaymentDate DateTime,  
  @AdjustmentDocReference varchar(255),  
  @NetAmountAfterAdjustment Decimal(18,6),  
  @AdditionalDiscountAmount Decimal(18, 6),
  @AddlDiscountPer Decimal(18, 6),  
  @AddlDiscountAmt Decimal(18, 6)  
 )  
  
AS   
DECLARE @Corrected_Code nvarchar(20)  
DECLARE @OriginalID nvarchar(20)  
  
select @OriginalID = VendorID FROM Vendors WHERE AlternateCode = @VendorID  
SET @Corrected_Code = ISNULL(@OriginalID, @VendorID)  
INSERT INTO [InvoiceAbstractReceived]   
  (  
  [Reference],  
  [InvoiceDate],  
  [VendorID],  
  [GrossValue],  
  [DiscountPercentage],  
 [AdditionalDiscount],  
  [DiscountValue],  
  [NetValue],  
  [CreditTerm],  
  [CreationTime],  
  [TaxLocation],  
 [Freight],  
 [DocumentID],  
 [BillingAddress],  
 [ShippingAddress],  
 InvoiceType,  
 ForumCode,  
 POSerialNumber,  
 PODate,  
 NetTaxAmount,  
 AdjustedAmount,  
 PaymentDate,  
 AdjustmentDocReference,  
 NetAmountAfterAdjustment,  
 AdditionalDiscountAmount,
 AddlDiscountPercentage,
 AddlDiscountAmount
 )   
   
VALUES   
 (  
 @InvoiceID,    
 @InvoiceDate,  
  @Corrected_Code,   
   @GrossValue,  
  @DiscountPercentage,  
 @AdditionalDiscount,  
  @DiscountValue,  
 @netvalue,  
 @CreditTerm,  
 getdate(),  
  @TaxLocation,  
 @freight,  
 @DocumentID,  
 @BillingAddress,  
 @ShippingAddress,  
 @Flags,  
 @VendorID,  
 @POSerialNumber,  
 @PODate,  
 @NetTaxAmount,  
 @AdjustedAmount,  
 @PaymentDate,  
 @AdjustmentDocReference,  
 @NetAmountAfterAdjustment,  
 @AdditionalDiscountAmount,
 @AddlDiscountPer,
 @AddlDiscountAmt
)  
SELECT @@IDENTITY  


