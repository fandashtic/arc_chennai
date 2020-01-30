
CREATE procedure sp_Modify_OpeningDetails ( @BatchCode int,
@Batch_Number nvarchar(255),
@Expiry datetime,
@PKD datetime,
@PTS Decimal(18,6),
@PTR Decimal(18,6),
@ECP Decimal(18,6),
@SpecialPrice Decimal(18,6),
@PurchasePrice Decimal(18,6),
@PriceOption int,
@TaxSuffered Decimal(18,6),
@LogonUser nvarchar(255),
@OldVat Int=0, @TaxCode Int=0, @TaxType Int=0,
@IsGRNBatch Int=0,@PFM DECIMAL(18,6) =0,@MRPFORTAX DECIMAL(18,6) =0) 	--Identifies whether the given batch is created thru GRN or not.
as
DECLARE @ProductCode nvarchar(15)
DECLARE @OpeningDate Datetime
DECLARE @DayBeforeOpDate Datetime
DECLARE @Is_Vat_Item Int
DECLARE @Locality Int
DECLARE @ApplicableOn Int
DECLARE @PartOff Decimal(18,6)
DECLARE @DocType Int
DECLARE @STIID Int
DECLARE @GRNID Int
DECLARE @TransDate datetime

-- --If Track Batch is set to No then Batch_Number is updated as Null
Declare @VirtualTrackBatches int
Declare @TrackPKD int
Declare @TempPKD varchar(50)
Declare @ItemCode varchar(255)

Select @ItemCode = Product_Code From Batch_Products Where  Batch_Code = @BatchCode

Select @VirtualTrackBatches = Virtual_Track_Batches, @TrackPKD = TrackPKD From Items
Where Product_Code = @ItemCode


If  @VirtualTrackBatches = 0
Set @Batch_Number = ''

If @TrackPKD = 0
Begin
Set @PKD = Null
Set @Expiry = Null
End
Set @ApplicableOn = 0
Set @PartOff = 0

If @TaxType = 2 		--CST
Select @ApplicableOn=CstApplicableOn, @PartOff=CstPartOff from Tax Where Tax_Code=@TaxCode
Else If @TaxType = 1 --LST
Select @ApplicableOn=LstApplicableOn, @PartOff=LstPartOff from Tax Where Tax_Code=@TaxCode

Insert into PriceChangeDetails (BatchCode, OldBatchNumber, OldExpiry, OldPKD, OldPTS,
OldPTR, OldECP, OldSpecialPrice, BatchNumber, Expiry, PKD, PTS, PTR, ECP, SpecialPrice,
ModifiedDate, OldTaxSuffered, TaxSuffered, UserName, OldApplicableOn, ApplicableOn, OldPartofPercentage, PartofPercentage, OldVat_Locality, Vat_Locality)
Select @BatchCode, Batch_Products.Batch_Number, Batch_Products.Expiry,
Batch_Products.PKD, Batch_Products.PTS, Batch_Products.PTR, Batch_Products.ECP,
Batch_Products.Company_Price, @Batch_Number, @Expiry, @PKD, @PTS, @PTR, @ECP,
@SpecialPrice, GetDate(), TaxSuffered, @TaxSuffered, @LogonUser,
Batch_Products.ApplicableOn, @ApplicableOn, Batch_Products.PartofPercentage, @PartOff, Batch_Products.Vat_Locality, @TaxType
From Batch_Products Where Batch_Products.Batch_Code = @BatchCode

Select Top 1 @OpeningDate = OpeningDate from Setup
Set @DayBeforeOpDate = DateAdd(Day,0-1,@OpeningDate)

Select @DocType = IsNull(DocType,0) From Batch_Products Where Batch_Code=@BatchCode
Select @STIID = IsNull(StockTransferId,0) From Batch_Products Where Batch_Code=@BatchCode
IF @IsGRNBatch = 1
Begin
Select @GRNID = IsNull(GRN_ID, 0) From Batch_Products Where Batch_Code=@BatchCode
Select @TransDate = GRNDate From GRNAbstract Where GRNID = @GRNID
End
Else IF @STIID > 0
Begin
Select @TransDate = DocumentDate From StockTransferInAbstract Where DocSerial = @STIID
End
Else
Begin
If (@DocType = 1) OR (@DocType = 3) OR (@DocType = 4)	--Sales Return and Retail Invoice
Select @TransDate = InvoiceDate From InvoiceAbstract Where InvoiceID in (Select Min(InvoiceID) From InvoiceDetail Where Batch_Code = @BatchCode)
Else If (@DocType = 2) OR (@DocType = 5)					--Stock Adjustment Damages
Select @TransDate = AdjustmentDate From StockAdjustmentAbstract Where AdjustmentID in (Select Min(SerialNo) From StockAdjustment Where Batch_Code = @BatchCode)
Else 																	--Opening Details (@DocType = 6)
Select @TransDate = @DayBeforeOpDate
End


Select @ProductCode=Product_Code, @Locality=IsNull(Vat_Locality,0) from Batch_Products where Batch_Code=@BatchCode
--Updating TaxSuff Percentage in OpeningDetails
If @OldVat = 1 and @Locality = 2
Exec Sp_Update_Opening_TaxSuffered_Percentage @TransDate, @ProductCode, @BatchCode, 1, 1, 1
Else
Exec Sp_Update_Opening_TaxSuffered_Percentage @TransDate, @ProductCode, @BatchCode, 1, 0, 1

If @PriceOption = 1
Begin
Update Batch_Products Set Batch_Number = @Batch_Number,
Expiry = @Expiry, PKD = @PKD, PTS = @PTS, PTR = @PTR, ECP = @ECP,
Company_Price = @SpecialPrice, SalePrice = @ECP,PFM=@PFM,MRPFORTAX= @MRPFORTAX,
TaxSuffered = @TaxSuffered, ApplicableOn=@ApplicableOn, PartOfPercentage=@PartOff,
Vat_Locality = @TaxType
Where Batch_Code = @BatchCode

Update DDD Set DDD.Batch_Number = @Batch_Number From DandDDetail DDD
Join DandDAbstract DDA On DDA.ID = DDD.ID And DDA.ClaimStatus in (1,2)
Where DDD.Batch_code = @BatchCode
End
else
Begin
Update Batch_Products Set Batch_Number = @Batch_Number,
Expiry = @Expiry, PKD = @PKD,	TaxSuffered = @TaxSuffered,
ApplicableOn=@ApplicableOn, PartOfPercentage=@PartOff, Vat_Locality = @TaxType
Where Batch_Code = @BatchCode

Update DDD Set DDD.Batch_Number = @Batch_Number From DandDDetail DDD
Join DandDAbstract DDA On DDA.ID = DDD.ID And DDA.ClaimStatus in (1,2)
Where DDD.Batch_code = @BatchCode
End
--Updating TaxSuff Percentage in OpeningDetails
Select @Is_Vat_Item=IsNull(Vat,0) from Items Where Product_Code=@ProductCode
If @Is_Vat_Item = 1 and @TaxType = 2
Exec Sp_Update_Opening_TaxSuffered_Percentage @TransDate, @ProductCode, @BatchCode, 0, 1, 1
Else
Exec Sp_Update_Opening_TaxSuffered_Percentage @TransDate, @ProductCode, @BatchCode, 0, 0, 1

Select @TempPKD = IsNull(Cast(PKD as varchar),'') From Batch_Products
Where product_code=@itemcode
And IsNull(batch_number,N'')=N''
And Batch_Code=@BatchCode

If @TempPKD <> ''
Begin
Select @TempPKD = Case When Len(DatePart(MM , GetDate())) = 1  Then  '0' + Cast( DatePart(MM , GetDate()) as varchar)
Else Cast( DatePart(MM , GetDate()) as varchar)  End
+ '/' + Cast(DatePart(YYYY, GetDate()) as varchar)

Update batch_products set batch_number =  @TempPKD
Where product_code=@ItemCode
And IsNull(batch_number,N'')=N''
And Batch_Code=@BatchCode

Update DDD Set DDD.Batch_Number = @TempPKD From DandDDetail DDD
Join DandDAbstract DDA On DDA.ID = DDD.ID And DDA.ClaimStatus in (1,2)
Where ddd.product_code=@ItemCode
And IsNull(ddd.batch_number,N'')=N''
And ddd.Batch_Code=@BatchCode
End


TheEnd:

