CREATE procedure sp_ser_insert_collections(@DocumentDate datetime,
@Value float, @Balance float, @PaymentMode integer, @ChequeNumber integer,
@ChequeDate datetime, @ChequeDetails nvarchar(128), @CustomerID nvarchar(15),
@DocPrefix nvarchar(50), @BankCode nvarchar(10), @BranchCode nvarchar(10), 
@PaymentModeID int = 0, @CustomerServiceCharge decimal(18,6) = 0, 
@ProviderServiceCharge decimal(18,6) = 0, @BankID int = 0, @CardHolder nvarchar(256) = '', 
@CreditCardNo as nvarchar(20) = '', @DirectCollection as int = 0, 
@SalesmanID int = 0, @DocReference nvarchar(128) = '', @AmendmentFlag Int = 0,
					@AmendmentDocID Varchar(50) = '')
as

/* 
@DirectCollection is to check the procedure is called from service invoice or collects
@SalesmanID int, @DocReference nvarchar(128) = '', @AmendmentFlag Int = 0,
					@AmendmentDocID Varchar(50) = '' 
are not send in Service invoice
these are used in collcetion module, this procedure is common to both */

Declare @DocID nvarchar(50)
DECLARE @BeatID int
If @DirectCollection > 0 
	select @BeatID = ISNULL(BeatID, 0) from Beat_Salesman where CustomerID = @CustomerID
If @AmendmentFlag = 0
Begin
	Begin Tran
	update DocumentNumbers set DocumentID = DocumentID + 1, @DocID = DocumentID
	where DocType = 12
	Commit Tran
	SET @DocID = @DocPrefix + @DocID
End
Else
Begin
	SET @DocID = @AmendmentDocID
End

Declare @IssuingBankCode varchar(20) 
Select @IssuingBankCode = BankCode from BankMaster Where BankName = Isnull(@ChequeDetails, '') 

Insert into Collections 
(FullDocID, DocumentDate, Value, Balance, PaymentMode, ChequeNumber, ChequeDate, 
ChequeDetails, CustomerID, SalesmanID, BankCode, BranchCode, BeatID, DocReference, 
PaymentModeID, CustomerServiceCharge, ProviderServiceCharge, BankID, CardHolder, 
CreditCardNumber, DocumentReference)
values
(@DocID, @DocumentDate, @Value, @Balance, @PaymentMode, @ChequeNumber, @ChequeDate,
@IssuingBankCode, @CustomerID, @SalesmanID, @BankCode, @BranchCode, @BeatID, @DocReference, 
@PaymentModeID, @CustomerServiceCharge, @ProviderServiceCharge, @BankID, @CardHolder, 
@CreditCardNo, @DocID)

select @@IDENTITY, @DocID
/* @DocID will be stored in DocumentReference (design as per ERP invoice :: dated 27.07.06 */

/* salesmanID, Beat ID and Doc Reference stored as 0, 0 and '' in service invoice implicit collection*/


