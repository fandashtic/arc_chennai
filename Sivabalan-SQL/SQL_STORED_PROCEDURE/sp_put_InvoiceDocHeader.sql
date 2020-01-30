CREATE PROCEDURE sp_put_InvoiceDocHeader
	(@InvoiceID [varchar](100), 
	 @InvoiceDate [datetime],
	 @VendorID [nvarchar](15),
	 @GrossValue Decimal(18,6),
	 @DiscountPercentage Decimal(18,6),
	 @AdditionalDiscount Decimal(18,6),
	 @DiscountValue Decimal(18,6),
	 @NetValue Decimal(18,6),
	 @CreditTerm [int],
	 @TaxLocation [nvarchar](50),
	 @Freight Decimal(18,6),
	 @DocumentID nvarchar(50),
	 @BillingAddress nvarchar(255),
	 @ShippingAddress nvarchar(255),
	 @Flags int, 
	 @POSerialNumber nvarchar(50),
	 @PODate Datetime,
	 @NetTaxAmount Decimal(18, 6),
	 @AdjustedAmount Decimal(18, 6),
	 @PaymentDate DateTime,
	 @AdjustmentDocReference nvarchar(255),
	 @NetAmountAfterAdjustment Decimal(18,6),
	 @AdditionalDiscountAmount Decimal(18, 6),
	 @Taxtype nvarchar(50),
	 @GSTFlag int = 0,
	 @StateType int = 0,
	 @FromStateCode int = 0,
	 @ToStateCode int = 0,
	 @GSTIN nvarchar(15) = '',
	 @ODNumber nvarchar(50) = ''
	)

AS 
Declare @Status Int

DECLARE @Corrected_Code nvarchar(20)
DECLARE @OriginalID nvarchar(20)

Declare @GSTEnable Int  
Declare @GSTEnableDate DateTime

Declare @PurchTaxtype int
Set @PurchTaxtype = 0

If IsNull(@Taxtype,'') <> ''
Begin
	Select @PurchTaxtype = isNull(TaxID,0) from tbl_merp_Taxtype where Taxtype = @Taxtype
End

Set @Status = 0
If (Select Count(*) From InvoiceAbstractReceived Where DocumentID = @DocumentID And IsNull(Status,0) & 33 <> 0 ) > 0
	Set @Status = 64 | 128
Else
	Update InvoiceAbstractReceived Set Status = IsNull(Status,0) | 64 | 128 Where DocumentID = @DocumentID

If IsNull(@ODNumber,'') = ''
	Set @ODNumber = @DocumentID

--If IsNull(@ODNumber,'') <> ''
--	Begin
--		If (Select Count(*) From InvoiceAbstractReceived Where ODNumber = @ODNumber And IsNull(Status,0) & 33 <> 0 ) > 0
--			Set @Status = 64 | 128
--		Else
--			Update InvoiceAbstractReceived Set Status = IsNull(Status,0) | 64 | 128 Where ODNumber = @ODNumber
--	End
--Else
--	Set @ODNumber = @DocumentID

Select @OriginalID = VendorID FROM Vendors WHERE AlternateCode = @VendorID
SET @Corrected_Code = ISNULL(@OriginalID, @VendorID)

Select @GSTEnable = Isnull(Flag,0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'GSTaxEnabled' 

Select Top 1  @GSTEnableDate = GSTDateEnabled From Setup

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
	AdditionalDiscountAmount,Status, Taxtype,
	GSTFlag,StateType,FromStatecode,ToStatecode,GSTIN,ODNumber
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
	@AdditionalDiscountAmount,@Status, @PurchTaxtype,
	@GSTFlag ,@StateType ,@FromStateCode, @ToStateCode, @GSTIN ,@ODNumber)
SELECT @@IDENTITY
--If @Taxtype <> '0'
if not exists(Select isNull(TaxID,0) from tbl_merp_Taxtype where Taxtype = @Taxtype)
BEGIN
	Update InvoiceAbstractReceived Set Status = 192 Where DocumentID = @DocumentID	
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)        
	Values('Invoice', 'Received Tax Type ' + @TaxType+ ' not exists in the Database',  cast(@DocumentID as varchar), getdate())     
END

  /* Checking  Valid VAT Invoice */
If (@Taxtype <> 'GST' And (@GSTFlag <> 0 Or @StateType <> 0 Or @FromStateCode <> 0 Or @ToStateCode <> 0))
Begin
	Update InvoiceAbstractReceived Set Status = 192 Where DocumentID = @DocumentID	
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)        
	Values('Invoice', 'InValid VAT information GSTFlag/StateType/FromStateCode/ToStateCode for the ' + @Taxtype +' Invoice.',  cast(@DocumentID as varchar), getdate())     
End
  /* Checking  Valid GST Invoice */
If (@Taxtype = 'GST' And (@GSTFlag <> 1 Or @StateType Not In(1,2) Or @FromStateCode Not in(Select Distinct StateID from StateCode) Or @ToStateCode Not In(Select Distinct StateID from StateCode)))
Begin
	Update InvoiceAbstractReceived Set Status = 192 Where DocumentID = @DocumentID	
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)        
	Values('Invoice', 'InValid GST information GSTFlag/StateType/FromStateCode/ToStateCode for the ' + @Taxtype +'  Invoice.',  cast(@DocumentID as varchar), getdate())     
End

IF @GSTEnable = 1 And @Taxtype <> 'GST' And @InvoiceDate > = @GSTEnableDate	
Begin	
	Update InvoiceAbstractReceived Set Status = 192 Where DocumentID = @DocumentID	
	Insert Into tbl_mERP_RecdErrMessages( TransactionType, ErrMessage, KeyValue, ProcessDate)        
	Values('Invoice', 'VAT Invoice Date must be lesser than the GST Enable Date for the Invoice.',  cast(@DocumentID as varchar), getdate())     	
End

