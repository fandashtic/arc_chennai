CREATE Procedure sp_Insert_ConversionDetail_MUOM (@DocSerial int,
						@ItemCode nvarchar(50),
						@OldBatchCode int,
						@Quantity Decimal(18,6),
						@ConversionType int)
As
Declare @Batch nvarchar(255)
Declare @Expiry datetime
Declare @PKD datetime
Declare @PTS Decimal(18,6)
Declare @PTR Decimal(18,6)
Declare @ECP Decimal(18,6)
Declare @SpecialPrice Decimal(18,6)
Declare @PurPrice Decimal(18,6)
Declare @SalePrice Decimal(18,6)
Declare @TaxSuffered Decimal(18,6)
Declare @NewBatchCode int
Declare @Free Decimal(18,6)
Declare @UOM Int
Declare @ApplicableOn Int
Declare @PartOff Decimal(18,6)

If @ConversionType = 2
Begin
	Set @PTS = 0
	Set @PTR = 0
	Set @ECP = 0
	Set @SpecialPrice = 0
	Set @PurPrice = 0
	Set @Free = 1
	Set @SalePrice = 0
	Set @TaxSuffered = 0
	Set @ApplicableOn = 0
	Set @PartOff = 0

	Select @Batch = Batch_Number, @Expiry = Expiry, @PKD = PKD 
	From Batch_Products
	Where Batch_Code = @OldBatchCode
End
Else
Begin
	Select @Batch = Batch_Number, @Expiry = Expiry, @PKD = PKD, @PTS = PTS, 
	@PTR = PTR, @ECP = ECP, @SpecialPrice = Company_Price,
	@PurPrice = PurchasePrice, @SalePrice = SalePrice, @TaxSuffered = TaxSuffered, @ApplicableOn = ApplicableOn, @PartOff = PartofPercentage 
	From Batch_Products Where Batch_Code = (Select BatchReference From Batch_Products 
	Where Batch_Code = @OldBatchCode)
	Set @Free = 0
End
Select @UOM = UOM From Items Where Product_Code = @ItemCode
Insert into Batch_Products (	Batch_Number, 
				Product_Code, 
				Expiry, 
				Quantity,
				PurchasePrice,
				PurchaseTax,
				SalePrice,
				TaxCode,
				PTS,
				PTR,
				ECP,
				QuantityReceived,
				Company_Price,
				Flags,
				OriginalBatch,
				Client_ID,
				Damage,
				DamagesReason,
				PKD,
				ClaimedAlready,
				Free,
				StockTransferID,
				BatchReference,
				GRN_ID,
				TaxSuffered,
			    UOM,
				UOMQty,
				UOMPrice,
				ApplicableOn, PartofPercentage)
Select 			Batch_Number,
				@ItemCode,
				Expiry,
				@Quantity,
				@PurPrice,
				PurchaseTax,
				@SalePrice,
				TaxCode,
				@PTS,
				@PTR,
				@ECP,
				0,
				@SpecialPrice,
				Flags,
				OriginalBatch,
				Client_ID,
				Damage,
				DamagesReason,
				PKD,
				ClaimedAlready,
				@Free,
				StockTransferID,
				@OldBatchCode, 
				GRN_ID, 
				@TaxSuffered, 
				@UOM, 
				@Quantity, 
				@PurPrice, @ApplicableOn, @PartOff 
From Batch_Products Where Batch_Code = @OldBatchCode
Select @NewBatchCode = @@Identity
Update Batch_Products Set Quantity = Quantity - @Quantity 
Where Batch_Code = @OldBatchCode And Quantity - @Quantity >= 0
If @@ROWCOUNT > 0
Begin
	Insert into ConversionDetail Values(@DocSerial, 
					@ItemCode,
					@OldBatchCode,
					@NewBatchCode,
					@Quantity,
					@Batch,
					@Expiry,
					@PKD,
					@PurPrice,
					@PTS,
					@PTR,
					@ECP,
					@SpecialPrice,
					@TaxSuffered)
	Select 1
End
Else
Begin
	Select 0
End


