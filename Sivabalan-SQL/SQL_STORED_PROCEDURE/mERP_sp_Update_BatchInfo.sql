CREATE Procedure mERP_sp_Update_BatchInfo(
@GRNID Int,
@GRNSerial Int,
@BatchCode Int,
@OrgPTS Decimal(18,6),
@UOMPTS Decimal(18,6),
@NetPTS Decimal(18,6),
@PTR Decimal(18,6),
@ECP Decimal(18,6),
@Batch nVarchar(128),
@PKD DateTime,
@VAT Int,
@Locality Int,
@TaxID Int,
@TaxSuff Decimal(18,6),
@TaxPartOff Decimal(18,6),
@TaxApplicOn Int,
@DiscPer Decimal(18,6),
@DiscPerUnit Decimal(18,6),
@PFM Decimal(18,6)
)
As
Begin    
Declare @Product_Code nVarChar(15)
Declare @Free Int
DECLARE @GRNDate DATETIME
DECLARE @OLDVALUE DECIMAL(18,6)  
DECLARE @NEWVALUE DECIMAL(18,6)  
DECLARE @ADJVALUE DECIMAL(18,6)  

SET @OLDVALUE = 0
SET @NEWVALUE = 0
SET @ADJVALUE = 0

If Exists(Select Batch_Code From Batch_Products Where GRN_ID = @GRNID And Batch_Code = @BatchCode)
Begin

	Select @Product_Code = Product_Code , @Free = IsNull(Free,0), @OLDVALUE = IsNull(PurchasePrice,0) * IsNull(Quantity,0) from Batch_Products Where Batch_Code = @BatchCode
	Select @GRNDate = GRNDate From GRNAbstract Where GRNID = @GRNID

	--Updating TaxSuff Percentage in OpeningDetails
	If @LOCALITY = 2 AND @VAT = 1
		Exec Sp_Update_Opening_TaxSuffered_Percentage @GRNDate, @Product_Code, @BatchCode, 1, 1
	Else
		Exec Sp_Update_Opening_TaxSuffered_Percentage @GRNDate, @Product_Code, @BatchCode, 1, 0

	Update Batch_Products 
	Set OrgPTS = @OrgPTS,
	UOMPrice = @UOMPTS,
	PurchasePrice = @NetPTS,
	PTS = @NetPTS,
	PTR = @PTR,
	ECP = @ECP,
	Batch_Number = @Batch,
	PKD = @PKD,
	TaxSuffered = @TaxSuff,
	GRNTaxSuffered = @TaxSuff,
	GRNTaxID = @TaxID,
	GRNApplicableON = @TaxApplicOn,
	GRNPartOff = @TaxPartOff,
	ApplicableON = @TaxApplicOn,
	PartofPercentage = @TaxPartOff,
	PFM = @PFM
	Where GRN_ID = @GRNID And Batch_Code = @BatchCode

	Select @NEWVALUE = IsNull(PurchasePrice,0) * IsNull(Quantity,0) from Batch_Products Where Batch_Code = @BatchCode
	SET @ADJVALUE = @NEWVALUE - @OLDVALUE
	--Updating Opening_Value in OpeningDetails table.
	IF @ADJVALUE <> 0 
		Exec Sp_Update_Opening_Stock @Product_Code, @GRNDate, 0, @Free, 0, 0, @ADJVALUE, @BatchCode

	--Updating TaxSuff Percentage in OpeningDetails
	If @LOCALITY = 2 AND @VAT = 1
		Exec Sp_Update_Opening_TaxSuffered_Percentage @GRNDate, @Product_Code, @BatchCode, 0, 1
	Else
		Exec Sp_Update_Opening_TaxSuffered_Percentage @GRNDate, @Product_Code, @BatchCode, 0, 0

	If IsNull(@Free,0) = 0
	Update GRNDetail Set DiscPer = @DiscPer , DiscPerUnit = @DiscPerUnit Where GRNID = @GRNID And Serial = @GRNSerial

	Select 1
End
Else
Begin
	Select 0
End

End
