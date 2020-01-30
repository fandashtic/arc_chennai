CREATE procedure sp_Insert_ServiceAbstract
(
--@InvoiceId int,
@ServiceInvoiceNo int,
@ServiceInvoiceDate datetime,
@TransactionDate datetime,
@SelectReceipient nvarchar(50),
@Address nvarchar(255),
@ReferenceDescription nvarchar(50),
@TotalTaxAmount decimal(18, 6),
@TotalNetAmount decimal(18, 6),
@DocId nvarchar(100),
@DocRef nvarchar(100),
@TransType nvarchar(50),
@DistSC nvarchar(50),
@ReceipientSC nvarchar(50),
@RevChargeApplicable bit,
@ITCEligble bit,
@RecCompScheme bit,
@ServiceType nvarchar(100),
@OperatingYear nvarchar(20),
@GSTIN nvarchar(100),
@Code nvarchar(100),
@TotGrossVal Decimal(18,6),
@TotTaxableValue Decimal(18,6),
@ServiceFor integer,
@Balance decimal(18,6)
)
As
BEGIN
declare @GSTDocID nvarchar(100)
declare @GSTVoucherPrefix nvarchar(100)
declare @GSTFullDocID nvarchar(100)
declare @Year nvarchar(20)
declare @ConfigAmt decimal(18,6)
Select @Year = Cast(Substring(@OperatingYear,3,3) as nvarchar) + Cast(Substring(@OperatingYear,8,2) as nvarchar)
Declare @DocType as nvarchar(20)

Select @DocType = Case @ServiceType WHEN 'Inward' THEN   '105' WHEN 'Outward' THEN  '106' END

If Exists (Select 'x' from tbl_mERP_ConfigAbstract where ScreenCode = 'SrvInvRCM' and Flag = 1 )
Begin
Select @ConfigAmt = Value from tbl_mERP_ConfigDetail where ScreenCode = 'SrvInvRCM'

If(@TotalNetAmount >= (Isnull(@ConfigAmt,0))) And @ServiceType = 'Inward'
Set @RevChargeApplicable = 1
END

Begin Tran
--UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = @DocType
--Select @GSTDocID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = @DocType
--Select @GSTVoucherPrefix = Prefix From VoucherPrefix
--Where TranID = (CASE @ServiceType WHEN 'Inward' THEN 'INWARD SERVICE INVOICE' WHEN 'Outward' THEN 'OUTWARD SERVICE INVOICE' end)
--Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar(10))

UPDATE GSTDocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = @DocType and OperatingYear = @OperatingYear
Select @GSTDocID = DocumentID - 1 FROM GSTDocumentNumbers WHERE DocType = @DocType and OperatingYear = @OperatingYear
Select @GSTVoucherPrefix = Prefix From VoucherPrefix
Where TranID = (CASE @ServiceType WHEN 'Inward' THEN 'INWARD SERVICE INVOICE' WHEN 'Outward' THEN 'OUTWARD SERVICE INVOICE' end)
Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocID as nvarchar(10))

Commit Tran

Insert into ServiceAbstract(ServiceInvoiceNo,ServiceInvoiceDate,TransactionDate,SelectReceipient,Address,ReferenceDescription,TotalTaxAmount,TotalNetAmount,dateofcreation,Status,DocumentId,DocumentRef,TransactionType,DistributorSC,
ReceipientSC,ReverseChargeApplicable,ITCEligible,ReceivedCompositionSchemeTaxableSource,ServiceType,GSTIN,Code,TotGrossVal,TotTaxableValue,ServiceFor,Balance)
Values (@ServiceInvoiceNo,@TransactionDate,@TransactionDate,@SelectReceipient,@Address,@ReferenceDescription,@TotalTaxAmount,
@TotalNetAmount,getdate(),0,@GSTFullDocID,@DocRef,@TransType,@DistSC,@ReceipientSC,@RevChargeApplicable,@ITCEligble,@RecCompScheme,@ServiceType,
@GSTIN,@Code,@TotGrossVal,@TotTaxableValue,@ServiceFor,@Balance)

Select @@identity


END
