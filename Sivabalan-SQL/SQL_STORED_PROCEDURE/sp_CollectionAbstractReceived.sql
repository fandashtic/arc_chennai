CREATE PROCEDURE sp_CollectionAbstractReceived        
(@CollectionID VARCHAR(20), @DocumentDate datetime, @Value Decimal(18,6), @Balance Decimal(18,6),        
@PaymentMode INT, @ChequeNumber INT, @ChequeDate DateTime, @ChequeDetails nVarchar(256), @CustomerForumID nVarchar(30),
@Bank nVarchar(50), @Branch nVarchar(50), @Beat nVarchar(50), @DocReference nVarchar(256),@DocumentReference nVarchar(1024), @BranchForumID nVarchar(256))
AS        
DECLARE @RECCUSID AS VARCHAR(20)  
DECLARE @BankCode AS VARCHAR(20)
DECLARE @BranchCode As Varchar(20)
DECLARE @BeatID As INT

SELECT @RECCUSID = ISNULL(customerid,'') FROM CUSTOMER WHERE ALTERNATECODE = @CustomerForumID

IF @Bank <> '0' And @Bank <> ''
BEGIN
	IF EXISTS(SELECT * FROM BankMaster WHERE BankName = @Bank)
	BEGIN
	SELECT @BankCode = BankCode FROM BankMaster WHERE BankName = @Bank
	END
	ELSE
	BEGIN
	INSERT INTO BankMaster Values(LEFT(@Bank,10),@Bank,1)
	SELECT @BankCode = BankCode FROM BankMaster WHERE BankName = LEFT(@Bank,10)
	END
END

IF @BankCode <> '0' And @BankCode <> '' 
BEGIN
	IF EXISTS(SELECT * FROM BranchMaster WHERE BranchName = @Branch And BankCode = @BankCode)
	BEGIN
	SELECT @BranchCode = BranchCode FROM BranchMaster WHERE BranchName = @Branch And BankCode = @BankCode
	END
	ELSE
	BEGIN
	INSERT INTO BranchMaster Values(LEFT(@Branch,10),@Branch,1,@BankCode)
	SELECT @BranchCode = BranchCode FROM BranchMaster WHERE BranchName = LEFT(@Branch,10) And BankCode = @BankCode
	END
END

IF @Beat <> '0' And @Beat <> '' 
BEGIN
	IF NOT EXISTS(SELECT * FROM Beat WHERE [Description] = @Beat)
	BEGIN
	INSERT INTO Beat(Description, Active) Values(@Beat,1)
	END
END

SELECT @BeatID = BeatID FROM Beat WHERE [Description] = @Beat

Select @DocReference=(Case @DocReference WHEN 'FORUM*UDH*FIX' then '' Else @DocReference End)

INSERT INTO CollectionsReceived        
(FullDocID, DocumentDate, Value, Balance, PaymentMode, ChequeNumber, ChequeDate, 
ChequeDetails,CustomerID, Status, Bank, Branch, Beat, CreationTime, DocReference,DocumentReference, BranchForumCode)
VALUES        
(@CollectionID , @DocumentDate , @Value, @Balance, @PaymentMode, @ChequeNumber, @ChequeDate,
@ChequeDetails, @RECCUSID, 0, @BankCode, @BranchCode, @BeatID, GetDate(),@DocReference,@DocumentReference, @BranchForumID)




