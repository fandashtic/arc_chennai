
CREATE PROCEDURE sp_consolidate_Payment_abstract(@CLIENT_ID int,
						 @DOCUMENTID int,
					  	 @FULLDOCID nvarchar(30),
  					       	 @DOCUMENTDATE datetime,
					         @CHEQUEDATE datetime,
					         @VALUE Decimal(18,6),
					         @BALANCE Decimal(18,6),
					         @PAYMENTMODE int,
						 @ACCOUNT_NUMBER nvarchar(50),
						 @CHEQUENUMBER nvarchar(30),
						 @VENDOR nvarchar(50),
						 @CHEQUE_ID int)
AS
DECLARE @BANK_ID int
DECLARE @VENDOR_ID nvarchar(15)
DECLARE @OLD_ID nvarchar(50)

SELECT @BANK_ID = BankID FROM Bank WHERE Account_Number = @ACCOUNT_NUMBER
SELECT @VENDOR_ID = VendorID FROM Vendors WHERE AlternateCode = @VENDOR
UPDATE Payments SET DocumentDate = @DOCUMENTDATE, Cheque_Date = @CHEQUEDATE, 
Value = @VALUE, Balance = @BALANCE, PaymentMode = @PAYMENTMODE,
Cheque_Number = @CHEQUENUMBER, VendorID = @VENDOR_ID, 
BankID = @BANK_ID, Cheque_ID = @CHEQUE_ID WHERE OriginalPayment = @DOCUMENTID AND Client_ID = @CLIENT_ID
IF @@ROWCOUNT = 0
BEGIN
	INSERT INTO Payments (DocumentDate, Cheque_Date, Value, Balance,
	PaymentMode, Cheque_Number, VendorID, FullDocID, BankID, OriginalPayment, 
	Client_ID, Cheque_ID)
	VALUES(@DOCUMENTDATE, @CHEQUEDATE, @VALUE, @BALANCE, @PAYMENTMODE,
	@CHEQUENUMBER, @VENDOR_ID, @FULLDOCID, @BANK_ID, @DOCUMENTID, @CLIENT_ID,
	@CHEQUE_ID)
	SELECT @@IDENTITY
END
ELSE
BEGIN
	SELECT @OLD_ID = DocumentID FROM Payments WHERE OriginalPayment = @DOCUMENTID
	Delete PaymentDetail WHERE DocumentID = @OLD_ID
	SELECT @OLD_ID 
END

