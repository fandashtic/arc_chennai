CREATE procedure sp_consolidate_BatchProducts_FMCG(@Client_ID int,
						@Batch_Code int,
						@Batch_Number nvarchar(50),
						@ForumCode nvarchar(50),
						@GRN_ID int,
						@Expiry datetime,
						@Quantity Decimal(18,6),
						@PurchasePrice Decimal(18,6),
						@PurchaseTax nvarchar(50),
						@SalePrice Decimal(18,6),
						@SaleTax nvarchar(50),
						@QuantityReceived Decimal(18,6),
						@Flags int,
						@Damage Decimal(18,6),
						@DamageReason nvarchar(255),
						@PKD datetime,
						@ClaimedAlready Decimal(18,6),
						@Free Decimal(18,6),
						@StockTransferID int,
						@BatchReference int)
as
Declare @PURCHASE_TAX Decimal(18,6)
Declare @SALE_TAX Decimal(18,6)
Declare @GRN_NO int
Declare @DAMAGEREASONID int
Declare @Product_Code nvarchar(20)

Select @Product_Code = Product_Code From Items Where Alias = @ForumCode
Select @PURCHASE_TAX = Tax_code From Tax Where Tax_Description = @PurchaseTax
Select @SALE_TAX = Tax_Code From Tax Where Tax_Description = @SaleTax
Select @GRN_NO = GRNID From GRNAbstract 
Where OriginalGRN = @GRN_ID and ClientID = @Client_ID
Select @DAMAGEREASONID = MessageID From StockAdjustmentReason
Where Message = @DamageReason
SET @PURCHASE_TAX = ISNULL(@PURCHASE_TAX, 0)
SET @SALE_TAX = ISNULL(@SALE_TAX, 0)

Update Batch_Products Set Batch_Number = @Batch_Number, Product_Code = @Product_Code,
GRN_ID = @GRN_NO, Expiry = @Expiry, Quantity = @Quantity, PurchasePrice = @PurchasePrice,
PurchaseTax = @PURCHASE_TAX, SalePrice = @SalePrice, TaxCode = @SALE_TAX, 
QuantityReceived = @QuantityReceived, Flags = @Flags, Damage = @Damage,
DamagesReason = @DAMAGEREASONID, PKD = @PKD, ClaimedAlready = @ClaimedAlready,
Free = @Free, StockTransferID = @StockTransferID, BatchReference = @BatchReference
Where OriginalBatch = @Batch_Code and Client_ID = @Client_ID

If @@RowCount = 0
Begin
	Insert into Batch_Products(Client_ID,
				   OriginalBatch,
				   Batch_Number,
				   Product_Code,
				   GRN_ID,
				   Expiry,
				   Quantity,
				   PurchasePrice,
				   PurchaseTax,
				   SalePrice,
				   TaxCode,
				   QuantityReceived,
				   Flags,
				   Damage,
				   DamagesReason,
				   PKD,
				   ClaimedAlready,
				   Free,
				   StockTransferID,
				   BatchReference)
Values(
				   @Client_ID,
				   @Batch_Code,
				   @Batch_Number,
				   @Product_Code,
				   @GRN_NO,
				   @Expiry,
				   @Quantity,
				   @PurchasePrice,
				   @PURCHASE_TAX,
				   @SalePrice,
				   @SALE_TAX,
				   @QuantityReceived,
				   @Flags,
				   @Damage,
				   @DAMAGEREASONID,
				   @PKD,
				   @ClaimedAlready,
				   @Free,
				   @StockTransferID,
				   @BatchReference)
End
