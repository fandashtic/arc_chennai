
CREATE PROCEDURE sp_consolidate_Collection_abstract(@CLIENT_ID int,
						    @DOCUMENTID int,
					  	    @FULLDOCID nvarchar(30),
  					       	    @DOCUMENTDATE datetime,
					            @CHEQUEDATE datetime,
  					            @DEPOSITDATE datetime,
					            @VALUE Decimal(18,6),
					            @BALANCE Decimal(18,6),
					            @PAYMENTMODE int,
						    @CHEQUENUMBER nvarchar(30),
						    @CHEQUEDETAILS nvarchar(255),
						    @ALTERNATECODE nvarchar(20),
						    @STATUS int,
						    @BANK_NAME nvarchar(50),
						    @SALESMAN_NAME nvarchar(50),
						    @BANKNAME NVARCHAR(50),
						    @BRANCHNAME NVARCHAR(50),
						    @CLEARINGAMOUNT Decimal(18,6),
						    @REALISED INT,
						    @BANKCHARGES Decimal(18,6),
						    @BEAT NVARCHAR(255))
AS
DECLARE @BANK_ID int
DECLARE @SALESMAN_ID int
DECLARE @OLD_ID nvarchar(50)
DECLARE @CUSTOMERID nvarchar(15)
DECLARE @BEATID int
DECLARE @BANKCODE NVARCHAR(50)
DECLARE @BRANCHCODE NVARCHAR(50)

SELECT @CUSTOMERID = CustomerID FROM Customer WHERE AlternateCode = @ALTERNATECODE
SELECT @BANK_ID = BankID FROM Bank WHERE Bank_Name = @BANK_NAME
SELECT @SALESMAN_ID = SalesmanID FROM Salesman WHERE Salesman_Name = @SALESMAN_NAME
SELECT @BANKCODE = BankCode FROM BankMaster WHERE BankName = @BANKNAME
SELECT @BRANCHCODE = BranchCode FROM BranchMaster WHERE BranchName = @BRANCHNAME
SELECT @BEATID = BeatID FROM Beat WHERE Description = @BEAT
UPDATE Collections SET DocumentDate = @DOCUMENTDATE, @ChequeDate = @CHEQUEDATE, 
DepositDate = @DEPOSITDATE, Value = @VALUE, Balance = @BALANCE, PaymentMode = @PAYMENTMODE,
ChequeNumber = @CHEQUENUMBER, ChequeDetails = @CHEQUEDETAILS, CustomerID = @CUSTOMERID, 
Status = @STATUS, Deposit_To = @BANK_ID, SalesmanID = @SALESMAN_ID,
BankCode = @BANKCODE, BranchCode = @BRANCHCODE, Realised = @Realised,
ClearingAmount = @CLEARINGAMOUNT, BankCharges = @BANKCHARGES, 
BeatID = @BEATID
WHERE OriginalCollection = @DOCUMENTID AND Client_ID = @CLIENT_ID
IF @@ROWCOUNT = 0
BEGIN
	INSERT INTO Collections (DocumentDate, ChequeDate, DepositDate, Value, Balance,
	PaymentMode, ChequeNumber, ChequeDetails, CustomerID, FullDocID, Status, Deposit_To,
	SalesmanID, OriginalCollection, Client_ID, BankCode, BranchCode, Realised,
	ClearingAmount, BankCharges, BeatID)
	VALUES(@DOCUMENTDATE, @CHEQUEDATE, @DEPOSITDATE, @VALUE, @BALANCE, @PAYMENTMODE,
	@CHEQUENUMBER, @CHEQUEDETAILS, @CUSTOMERID, @FULLDOCID, @STATUS, @BANK_ID,
	@SALESMAN_ID, @DOCUMENTID, @CLIENT_ID, @BANKCODE, @BRANCHNAME, @REALISED,
	@CLEARINGAMOUNT, @BANKCHARGES, @BEATID)
	SELECT @@IDENTITY
END
ELSE
BEGIN
	SELECT @OLD_ID = DocumentID FROM Collections WHERE OriginalCollection = @DOCUMENTID
	Delete CollectionDetail WHERE DocumentID = @OLD_ID
	SELECT @OLD_ID 
END

