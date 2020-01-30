CREATE PROCEDURE sp_consolidate_DebitNote(@CLIENT_ID int,
					  @DOCUMENTID int,
					  @DOCUMENTDATE datetime,
					  @CUSTOMER_ID nvarchar(20),
					  @VENDOR_ID nvarchar(20),
					  @NOTEVALUE Decimal(18,6),
					  @BALANCE Decimal(18,6),
					  @MEMO nvarchar(255),
					  @DEBITID int,
					  @SALESMAN_NAME nvarchar(50),
					  @FLAG int,
					  @DOCREF nvarchar(50))
AS
DECLARE @SALESMAN_ID int
DECLARE @CUSTOMERID nvarchar(15)
DECLARE @VENDORID nvarchar(15)

SELECT @CUSTOMERID = CustomerID FROM Customer WHERE AlternateCode = @CUSTOMER_ID
SELECT @VENDORID = VendorID FROM Vendors WHERE 	AlternateCode = @VENDOR_ID
SELECT @SALESMAN_ID = SalesmanID FROM Salesman WHERE Salesman_Name = @SALESMAN_NAME
INSERT INTO DebitNote  (DocumentID,
			DocumentDate,
			CustomerID,
			VendorID,
			NoteValue,
			Balance,
			Memo,
			SalesmanID,
			OriginalDebitID,
			Client_ID,
			Flag,
			DocRef)
VALUES(
			@DOCUMENTID,
			@DOCUMENTDATE,
			@CUSTOMERID,
			@VENDORID,
			@NOTEVALUE,
			@BALANCE,
			@MEMO,
			@SALESMAN_ID,
			@DEBITID,
			@CLIENT_ID,
			@FLAG,
			@DOCREF)	
