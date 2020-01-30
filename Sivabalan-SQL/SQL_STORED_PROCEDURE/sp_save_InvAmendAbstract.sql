Create PROCEDURE sp_save_InvAmendAbstract(@INVNO INT,
@INVDATE DATETIME,
@CUSTOMER NVARCHAR(15),
@USERNAME NVARCHAR(50),
@GROSSVALUE Decimal(18,6),
@DISPER Decimal(18,6),
@DISVALUE Decimal(18,6),
@NETVALUE Decimal(18,6),
@REFERENCE NVARCHAR(255),
@CREDIT_TERM INT,
@ADDN_DISCOUNT Decimal(18,6),
@FREIGHT Decimal(18,6),
@OLDREFERENCE nvarchar(255),
@NEWINVOICE nvarchar(50),
@FLAGS int,
@BILLINGADDRESS nvarchar(255),
@SHIPPINGADDRESS nvarchar(255),
@MEMO1 nvarchar(255),
@MEMO2 nvarchar(255),
@MEMO3 nvarchar(255),
@PAYMENTDATE datetime,
@SALESMAN2 nvarchar(255),
@PAYMENTMODE int = 0,
@DocReference nvarchar(255) = N'',
@SalesmanID int = 0,
@WriteOff Decimal(18, 6),
@AdjustmentValue Decimal(18, 6),@TaxOnECP int = 0,
@InvSchemeID Integer = 0, @InvSchemeDisc Decimal(18,6) = 0, @InvSchemeVal Decimal(18,6) = 0,
@ExciseDuty Decimal(18,6) = 0, @gPriceExciseDuty Decimal(18,6) = 0, @gDiscExciseDuty Decimal(18,6) = 0,
@VatTaxAmount Decimal(18,6) = 0, @SONumber nVarchar(255) = N'',
@VanNumber NVarChar(100) = N'',
@DeliveryStatus Int = 0,
@BtID int = -1,
@CatGroup nVarchar(1000) = '',
@DeliveryDate datetime,
@InvoiceSchemeID nVarchar(510) = '',
@MultiSchemeDetail nVarchar(2000) = '',
@Reason Nvarchar(255),
@RegisterStatus Int)
AS
DECLARE @DocumentID int
DECLARE @MemoLabel1 nvarchar(255)
DECLARE @MemoLabel2 nvarchar(255)
DECLARE @MemoLabel3 nvarchar(255)
DECLARE @BeatID int
DECLARE @OrigStatus int
DECLARE @PaymentDetails int
Declare @GSTIN nvarchar(30)
Declare @GSTFlag int
Declare @GSTDocID int
Declare @GSTFullDocID nvarchar(250)
Declare @CGCustomerName nvarchar(150)

--Select @OrigStatus = Status From InvoiceAbstract Where InvoiceID = @INVNO
Declare @InvoiceReasonID as Int
Set @InvoiceReasonID = (Select Top 1 Isnull(ID,0) From InvoiceReasons Where Reason = @Reason And [Type] = 'Invoice Amendment')

Declare @FromStateCode int
Declare @ToStateCode int

Select Top 1 @FromStateCode = isnull(ShippingStateID,0) From Setup
Select @ToStateCode = isnull(BillingStateID,0) --, @GSTIN = GSTIN
From Customer Where CustomerID = @CUSTOMER

--When beat is deactivate even if the deactivated beat is set to customer already (before deactivate)
--then the Beat id is stored as 0. If beat is activate then that beat id only stored.
IF @BtID = -1
select @BeatID = ISNULL((Select TOP 1 BeatID From Beat Where Active=1 And BeatID In (select BeatID from Beat_Salesman where CustomerID = @CUSTOMER)), 0)
Else
Set @BeatID = @BtID

Select @GSTFlag = isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'

SELECT @MemoLabel1 = MemoLabel1, @MemoLabel2 = MemoLabel2, @MemoLabel3 = MemoLabel3 from Setup
Select @DocumentID=DocumentID, @GSTDocID = GSTDocID, @GSTFullDocID = GSTFullDocID, @OrigStatus = Status,
@CGCustomerName = AlternateCGCustomerName, @GSTIN = GSTIN
From invoiceabstract where InvoiceID=@INVNO

SET @PaymentDetails = cast((Select PaymentDetails From InvoiceAbstract Where InvoiceId = @INVNO) as int)
IF Exists (select DocumentID from collections Where (IsNull(Status,0) & 64) = 0 And DocumentID = @PaymentDetails)
BEGIN
exec sp_Cancel_Collection @PaymentDetails
if exists(Select ReferenceID From AdjustmentReference Where InvoiceID = @INVNO and TransactionType = 0)
Begin
Update DebitNote Set Status = 128, Balance = 0
Where DebitID In (Select ReferenceID From AdjustmentReference
Where InvoiceID = @INVNO And DocumentType = 5 and TransactionType = 0)
Update CreditNote Set Status = 128, Balance = 0
Where CreditID In (Select ReferenceID From AdjustmentReference
Where InvoiceID = @INVNO And DocumentType = 2 and TransactionType = 0)
Update AdjustmentReference Set Status = 128 Where InvoiceID = @InvNO and TransactionType = 0
End
END

INSERT INTO InvoiceAbstract(InvoiceType,
InvoiceDate,
CustomerID,
UserName,
GrossValue,
DiscountPercentage,
DiscountValue,
NetValue,
InvoiceReference,
ReferenceNumber,
CreditTerm,
Status,
CreationTime,
AdditionalDiscount,
Freight,
NewReference,
NewInvoiceReference,
DocumentID,
Flags,
BillingAddress,
ShippingAddress,
MemoLabel1,
MemoLabel2,
MemoLabel3,
Memo1,
Memo2,
Memo3,
PaymentDate,
Balance,
SalesmanID,
BeatID,
Salesman2,
PaymentMode,
DocReference,
RoundOffAmount,
AdjustmentValue,TaxOnMRP,
SchemeID, SchemeDiscountPercentage, SchemeDiscountAmount, ClaimedAmount, ClaimedAlready,
ExciseDuty,SalePriceBeforeExcise,DiscountBeforeExcise,VatTaxAmount, SONumber,
VanNumber,DeliveryStatus,GroupID,DeliveryDate, InvoiceSchemeID, MultipleSchemeDetails, TaxDiscountFlag,AmendReasonId,
FromStateCode,ToStateCode,GSTIN,GSTFlag,GSTDocID,GSTFullDocID,AlternateCGCustomerName)
VALUES (3,
@INVDATE,
@CUSTOMER,
@USERNAME,
@GROSSVALUE,
@DISPER,
@DISVALUE,
@NETVALUE,
@INVNO,
@OLDREFERENCE,
@CREDIT_TERM,
@OrigStatus,
GetDate(),
@ADDN_DISCOUNT,
@FREIGHT,
@REFERENCE,
@NEWINVOICE,
@DocumentID,
@FLAGS,
@BILLINGADDRESS,
@SHIPPINGADDRESS,
@MEMOLABEL1,
@MEMOLABEL2,
@MEMOLABEL3,
@MEMO1,
@MEMO2,
@MEMO3,
@PAYMENTDATE,
@NETVALUE + @WriteOff,
@SalesmanID,
@BeatID,
@SALESMAN2,
@PAYMENTMODE,
@DocReference,
@WriteOff,
@AdjustmentValue,@TaxOnECP,
@InvSchemeID, @InvSchemeDisc, @InvSchemeVal, 0, 0,
@ExciseDuty, @gPriceExciseDuty , @gDiscExciseDuty,@VatTaxAmount, @SONumber,
@VanNumber,@DeliveryStatus, @CatGroup,@DeliveryDate, @InvoiceSchemeID, @MultiSchemeDetail, @FLAGS,@InvoiceReasonID,
@FromStateCode, @ToStateCode,@GSTIN,@GSTFlag,@GSTDocID,@GSTFullDocID,@CGCustomerName)

UPDATE InvoiceAbstract SET CancelDate = Getdate(), Status = Status | 128, Balance = 0 WHERE InvoiceID = @INVNO
Update DispatchAbstract Set Status = Status | 192 Where InvoiceID = @INVNO
SELECT @@IDENTITY, @DocumentID

