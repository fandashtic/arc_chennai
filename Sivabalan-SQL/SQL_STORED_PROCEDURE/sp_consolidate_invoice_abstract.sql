CREATE PROCEDURE sp_consolidate_invoice_abstract(@CLIENT_ID int,
					    @INVOICE_ID int,
					    @INVOICE_TYPE int,
					    @INVOICE_DATE datetime,
					    @CREATION_TIME datetime,
					    @PAYMENT_DATE datetime,
					    @CUSTOMERID nvarchar(250),
					    @BILLING_ADDRESS nvarchar(255),
					    @SHIPPING_ADDRESS nvarchar(255),
					    @GROSS_VALUE Decimal(18,6),
					    @DISCOUNT_PERCENTAGE Decimal(18,6),
					    @DISCOUNT_VALUE Decimal(18,6),
					    @NET_VALUE Decimal(18,6),
					    @STATUS int,
					    @TAX_LOCATION nvarchar(50),
					    @INVOICE_REFERENCE nvarchar(255),
					    @REFERENCE_NUMBER nvarchar(255),
					    @ADDITIONAL_DISCOUNT Decimal(18,6),
					    @FREIGHT Decimal(18,6),
					    @CREDIT_TERM nvarchar(50),
					    @DOCUMENT_ID int,
					    @NEW_REFERENCE nvarchar(255),
					    @NEW_INVOICE_REFERENCE nvarchar(255),
					    @MEMO1 nvarchar(255),
					    @MEMO2 nvarchar(255),
					    @MEMO3 nvarchar(255),
					    @MEMOLABEL1 nvarchar(255),
					    @MEMOLABEL2 nvarchar(255),
					    @MEMOLABEL3 nvarchar(255),
					    @FLAGS int,
					    @REFERREDBY nvarchar(255),
					    @BALANCE Decimal(18,6),
					    @SALESMAN_NAME nvarchar(255),
					    @BEATDESCRIPTION nvarchar(255),
					    @PAYMENTMODE int,
					    @PAYMENTDETAILS nvarchar(255),
					    @RETURNTYPE int,
					    @SALESMAN2 nvarchar(255),
					    @DocReference nvarchar(255),
					    @UserName nvarchar(50))
AS
DECLARE @CREDIT_ID int
DECLARE @OLD_ID int
DECLARE @BEAT_ID int
DECLARE @SALESMAN_ID int
DECLARE @DOCTOR_ID int
DECLARE @CUSTOMER_ID nvarchar(15)
DECLARE @SALESMAN_ID2 int

IF @INVOICE_TYPE = 2 
BEGIN
	SET @CUSTOMER_ID = (SELECT CustomerID FROM Cash_Customer WHERE CustomerName = @CUSTOMER_ID)
	SET @DOCTOR_ID = (SELECT ID FROM Doctor WHERE Name = @REFERREDBY)
END
ELSE
SELECT @CUSTOMER_ID = CustomerID FROM Customer WHERE AlternateCode = @CUSTOMERID
SET @DOCTOR_ID = 0
SET @SALESMAN_ID = (SELECT SalesmanID FROM Salesman WHERE Salesman_Name = @SALESMAN_NAME)
SET @BEAT_ID = (SELECT BeatID FROM Beat WHERE Description = @BEATDESCRIPTION)
SELECT @CREDIT_ID = CreditID FROM CreditTerm WHERE Description = @CREDIT_TERM
SELECT @SALESMAN_ID2 = SalesmanID FROM Salesman2 WHERE SalesmanName = @SALESMAN2
UPDATE  InvoiceAbstract SET InvoiceType = @INVOICE_TYPE, InvoiceDate = @INVOICE_DATE, PaymentDate = @PAYMENT_DATE, CreationTime = @CREATION_TIME,
	CustomerID = @CUSTOMER_ID, BillingAddress = @BILLING_ADDRESS, ShippingAddress = @SHIPPING_ADDRESS, 
	CreditTerm = @CREDIT_ID, GrossValue = @GROSS_VALUE, DiscountPercentage = @DISCOUNT_PERCENTAGE, DiscountValue = @DISCOUNT_VALUE, NetValue = @NET_VALUE, Status = @STATUS,
	TaxLocation = @TAX_LOCATION, InvoiceReference = @INVOICE_REFERENCE, ReferenceNumber = @REFERENCE_NUMBER, AdditionalDiscount = @ADDITIONAL_DISCOUNT,
	Freight = @FREIGHT, DocumentID = @DOCUMENT_ID, NewReference = @NEW_REFERENCE, NewInvoiceReference = @NEW_INVOICE_REFERENCE,
	Memo1 = @MEMO1, Memo2 = @MEMO2, Memo3 = @MEMO3, MemoLabel1 = @MEMOLABEL1, 
	MemoLabel2 = @MEMOLABEL2, 
	MemoLabel3 = @MEMOLABEL3, Flags = @FLAGS, ReferredBy = @DOCTOR_ID, 
	Balance = @BALANCE, SalesmanID = @SALESMAN_ID,
	BeatID = @BEAT_ID, PaymentMode = @PAYMENTMODE, PaymentDetails = @PAYMENTDETAILS,
	ReturnType = @RETURNTYPE, Salesman2 = @SALESMAN_ID2,
	DocReference = @DocReference, UserName = @UserName
WHERE   OriginalInvoice = @INVOICE_ID AND ClientID = @CLIENT_ID
IF @@ROWCOUNT = 0
BEGIN
	INSERT INTO InvoiceAbstract(OriginalInvoice, InvoiceType, InvoiceDate, 
	PaymentDate, CreationTime, ClientID, CustomerID, BillingAddress, ShippingAddress, 
	CreditTerm, GrossValue, DiscountPercentage, DiscountValue, NetValue, Status, 
	TaxLocation, InvoiceReference, ReferenceNumber, AdditionalDiscount, Freight, 
	DocumentID, NewReference, NewInvoiceReference, Memo1, Memo2, Memo3, MemoLabel1,
	MemoLabel2, MemoLabel3, Flags, ReferredBy, Balance, SalesmanID, BeatID,
	PaymentMode, PaymentDetails, ReturnType, Salesman2, DocReference, UserName)
	VALUES(@INVOICE_ID, @INVOICE_TYPE, @INVOICE_DATE, @PAYMENT_DATE, @CREATION_TIME, 
	@CLIENT_ID, @CUSTOMER_ID, @BILLING_ADDRESS, @SHIPPING_ADDRESS, @CREDIT_ID, 
	@GROSS_VALUE, @DISCOUNT_PERCENTAGE, @DISCOUNT_VALUE, @NET_VALUE, @STATUS, 
	@TAX_LOCATION, @INVOICE_REFERENCE, @REFERENCE_NUMBER, @ADDITIONAL_DISCOUNT, 
	@FREIGHT, @DOCUMENT_ID, @NEW_REFERENCE, @NEW_INVOICE_REFERENCE, @MEMO1, @MEMO2, 
	@MEMO3, @MEMOLABEL1, @MEMOLABEL2, @MEMOLABEL3, @FLAGS, @DOCTOR_ID, @BALANCE,
	@SALESMAN_ID, @BEAT_ID, @PAYMENTMODE, @PAYMENTDETAILS, @RETURNTYPE, @SALESMAN_ID2,
	@DocReference, @UserName)
	SELECT @@IDENTITY
END
ELSE
BEGIN
	SELECT @OLD_ID = InvoiceID FROM InvoiceAbstract WHERE OriginalInvoice = @INVOICE_ID
	Delete InvoiceDetail WHERE InvoiceID = @OLD_ID
	SELECT @OLD_ID
END
