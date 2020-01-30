CREATE PROCEDURE sp_consolidate_bill_abstract(@CLIENT_ID int,
					    @BILL_ID int,
					    @BILL_DATE datetime,
					    @CREATION_TIME datetime,
					    @VENDORID nvarchar(20),
					    @STATUS int,
					    @DOCUMENT_ID int,
					    @InvoiceReference nvarchar(255),
					    @BillReference int,
					    @NewGRNID int,
					    @DocumentReference int,
					    @VALUE Decimal(18,6),
					    @TaxAmount Decimal(18,6),
					    @AdjustmentAmount Decimal(18,6),
					    @Balance Decimal(18,6),
					    @UserName nvarchar(50),
					    @Discount Decimal(18,6),
					    @DiscountOption int)
AS
DECLARE @OLD_ID int
DECLARE @VENDOR_ID nvarchar(15)

SELECT @VENDOR_ID = VendorID FROM Vendors WHERE AlternateCode = @VENDORID
UPDATE  BillAbstract SET BillDate = @BILL_DATE, CreationTime = @CREATION_TIME,
	VendorID = @VENDOR_ID, Status = @STATUS, DocumentID = @DOCUMENT_ID, InvoiceReference = @InvoiceReference, BillReference = @BillReference,
	NewGRNID = @NewGRNID, DocumentReference = @DocumentReference, Value = @VALUE,
	TaxAmount = @TaxAmount, AdjustmentAmount = @AdjustmentAmount,
	Balance = @Balance, UserName = @UserName, Discount = @Discount,
	DiscountOption = @DiscountOption
WHERE   OriginalBill = @BILL_ID AND ClientID = @CLIENT_ID
IF @@ROWCOUNT = 0
BEGIN
	INSERT INTO BillAbstract(OriginalBill, BillDate, CreationTime, ClientID, 
	VendorID, Status, DocumentID, InvoiceReference, BillReference, NewGRNID, 
	DocumentReference, Value, TaxAmount, AdjustmentAmount, Balance, UserName,
	Discount, DiscountOption)
	VALUES(@BILL_ID, @BILL_DATE, @CREATION_TIME, @CLIENT_ID, @VENDOR_ID, @STATUS, 
	@DOCUMENT_ID, @InvoiceReference, @BillReference, @NewGRNID, @DocumentReference, 
	@VALUE, @TaxAmount, @AdjustmentAmount, @Balance, @UserName, @Discount,
	@DiscountOption)
	SELECT @@IDENTITY
END
ELSE
BEGIN
	SELECT @OLD_ID = BillID FROM BillAbstract WHERE OriginalBill = @BILL_ID
	Delete BillDetail WHERE BillID = @OLD_ID
	SELECT @OLD_ID
END
