Create Procedure sp_Save_InvoiceAbstract
(@INVOICETYPE INT,
@INVOICEDATE DATETIME ,
@CUSTOMERID NVARCHAR (15),
@GROSSVALUE Decimal(18,6),
@DISCOUNTPERCENTAGE Decimal(18,6),
@DISCOUNTVALUE Decimal(18,6),
@NETVALUE Decimal(18,6),
@STATUS INT,
@REFERENCENUMBER NVARCHAR (255),
@ADDITIONALDISCOUNT Decimal(18,6),
@FREIGHT Decimal(18,6),
@CREDITTERM INT,
@BILLINGADDRESS NVARCHAR (255),
@SHIPPINGADDRESS NVARCHAR (255),
@PAYMENT_DATE datetime,
@NEWREFERENCE nvarchar(255),
@MEMO1 nvarchar(255),
@MEMO2 nvarchar(255),
@MEMO3 nvarchar(255),
@FLAGS int,
@USER nvarchar(50),
@SALESMAN2 nvarchar(255) = 0,
@PAYMENT_MODE int = 0,
@SalesmanID int = 0,
@DocReference nvarchar(255) = N'',
@RoundOff Decimal(18, 6),
@AdjustmentValue Decimal(18, 6),@AmtRec Decimal(18, 6)=null,
@BranchCode nvarchar(255)=null,@TaxOnECP int = 0,
@InvSchemeID Integer = 0, @InvSchemeDisc Decimal(18,6) = 0, @InvSchemeVal Decimal(18,6) = 0,
@ExciseDuty Decimal(18,6) = 0, @gPriceExciseDuty Decimal(18,6) = 0, @gDiscExciseDuty Decimal(18,6) = 0,
@VatTaxAmount Decimal(18,6) = 0, @SONumber nVarchar(255)=N'',
@BeatId int = -1,
@GroupID nVarchar(1000) = null,
@DeliveryDate Datetime,
@InvoiceSchemeID nVarchar(510) = '',
@MultiSchemeDetail nVarchar(2000) = ''
,@OperatingYear nvarchar(50) = ''
,@CGCustomerName nvarchar(150) = ''
,@OriginalInvoiceID int = 0
,@RegisteredFlag int = 0)
AS
DECLARE @DocumentID int
DECLARE @MemoLabel1 nvarchar(255)
DECLARE @MemoLabel2 nvarchar(255)
DECLARE @MemoLabel3 nvarchar(255)
Declare @FromStateCode int
Declare @ToStateCode int
Declare @GSTIN nvarchar(30)
Declare @GSTFlag int
Declare @GSTDocID int
Declare @GSTFullDocID nvarchar(250)
Declare @GSTVoucherPrefix nvarchar(50)
Declare @Year as nvarchar(20)
Declare @SRInvoiceID int

Select @Year = Cast(Substring(@OperatingYear,3,3) as nvarchar) + Cast(Substring(@OperatingYear,8,2) as nvarchar)

Select Top 1 @FromStateCode = isnull(ShippingStateID,0) From Setup
Select @ToStateCode = isnull(BillingStateID,0), @GSTIN = GSTIN From Customer Where CustomerID = @CUSTOMERID

IF @INVOICETYPE = 4 and isnull(@OriginalInvoiceID,0) > 0
Begin
Set @SRInvoiceID = isnull(@OriginalInvoiceID,0)
Select @GSTIN = GSTIN From InvoiceAbstract Where InvoiceID = @SRInvoiceID
End

--When beatis deactivate even if the deactivated beat is set to customer already (before deactivate)
--then the Beat id is stored as 0. If beat is activate then that beat id only stored.
If @BeatId =  -1
select @BeatID = ISNULL((Select TOP 1 BeatID From Beat Where Active=1 And BeatID In (select BeatID from Beat_Salesman where CustomerID = @CUSTOMERID)), 0)

Select @GSTFlag = isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'

SELECT @MemoLabel1 = MemoLabel1, @MemoLabel2 = MemoLabel2, @MemoLabel3 = MemoLabel3 from Setup

BEGIN TRAN
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 4
SELECT @DocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 4

--IF @GSTFlag = 1
--Begin
--	IF @INVOICETYPE = 4
--	Begin
--		UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 102
--		Select @GSTDocID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 102
--		Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'GST_SALESRETURN'
--		Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar(10))
--	End
--	ELSE
--	Begin
--		UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 101
--		Select @GSTDocID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 101
--		Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'GST_INVOICE'
--		Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar(10))
--	End
--End


IF @GSTFlag = 1
Begin
IF @INVOICETYPE = 4
Begin
UPDATE GSTDocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 102 and OperatingYear = @OperatingYear
Select @GSTDocID = DocumentID - 1 FROM GSTDocumentNumbers WHERE DocType = 102 and OperatingYear = @OperatingYear
Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'GST_SALESRETURN'
Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar(10))
End
ELSE
Begin
UPDATE GSTDocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 101 and OperatingYear = @OperatingYear
Select @GSTDocID = DocumentID - 1 FROM GSTDocumentNumbers WHERE DocType = 101 and OperatingYear = @OperatingYear
Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'GST_INVOICE'
Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar(10))
End
End
COMMIT TRAN

Insert into InvoiceAbstract
(InvoiceType,
InvoiceDate,
CustomerID,
GrossValue,
DiscountPercentage,
DiscountValue,
NetValue,
Status,
ReferenceNumber,
AdditionalDiscount,
Freight,
CreditTerm,
BillingAddress,
ShippingAddress,
PaymentDate,
DocumentID,
NewReference,
Memo1,
Memo2,
Memo3,
MemoLabel1,
MemoLabel2,
MemoLabel3,
Flags,
Balance,
Username,
SalesmanID,
BeatID,
Salesman2,
PaymentMode,
DocReference,
RoundOffAmount,
AdjustmentValue,AmountRecd,BranchCode,TaxOnMRP,
SchemeID, SchemeDiscountPercentage, SchemeDiscountAmount, ClaimedAmount, ClaimedAlready,
ExciseDuty,SalePriceBeforeExcise,DiscountBeforeExcise,VatTaxAmount,SONumber, GroupID,DeliveryDate,
InvoiceSchemeID,MultipleSchemeDetails, TaxDiscountFlag,FromStateCode,ToStateCode,GSTIN,GSTFlag,GSTDocID,
GSTFullDocID,AlternateCGCustomerName,SRInvoiceID)
values
(@INVOICETYPE,
@INVOICEDATE,
@CUSTOMERID,
@GROSSVALUE,
@DISCOUNTPERCENTAGE,
@DISCOUNTVALUE,
@NETVALUE,
@STATUS,
@REFERENCENUMBER,
@ADDITIONALDISCOUNT,
@FREIGHT,
@CREDITTERM,
@BILLINGADDRESS,
@SHIPPINGADDRESS,
@PAYMENT_DATE,
@DocumentID,
@NEWREFERENCE,
@MEMO1,
@MEMO2,
@MEMO3,
@MemoLabel1,
@MemoLabel2,
@MemoLabel3,
@FLAGS,
@NETVALUE + @RoundOff,
@USER,
@SalesmanID,
@BeatID,
@SALESMAN2,
@PAYMENT_MODE,
@DocReference,
@RoundOff,
@AdjustmentValue,
@AmtRec,
@BranchCode,@TaxOnECP,
@InvSchemeID, @InvSchemeDisc, @InvSchemeVal, 0, 0,
@ExciseDuty, @gPriceExciseDuty , @gDiscExciseDuty,@VatTaxAmount,@SONumber,
@GroupID,@DeliveryDate,@InvoiceSchemeID, @MultiSchemeDetail, @FLAGS, @FromStateCode, @ToStateCode, @GSTIN, @GSTFlag,@GSTDocID,@GSTFullDocID,@CGCustomerName,@SRInvoiceID)
Select @@Identity, @DocumentID
