CREATE PROCEDURE sp_consolidate_CreditNote(@CLIENT_ID int,					
					   @DOCUMENTID int,
					   @DOCUMENTDATE datetime,
					   @CUSTOMER_ID nvarchar(20),
					   @VENDOR_ID nvarchar(20),
					   @NOTEVALUE Decimal(18,6),
					   @BALANCE Decimal(18,6),
					   @MEMO nvarchar(255),
					   @CREDITID int,					
					   @SALESMAN_NAME nvarchar(50),
					   @DocPrefix nvarchar(50),
					   @DocRef nvarchar(50))
AS
DECLARE @SALESMAN_ID int
DECLARE @CUSTOMERID nvarchar(15)
DECLARE @VENDORID nvarchar(15)

SELECT @CUSTOMERID = CustomerID FROM Customer WHERE AlternateCode = @CUSTOMER_ID
SELECT @VENDORID = VendorID FROM Vendors WHERE AlternateCode = @VENDOR_ID
SELECT @SALESMAN_ID = SalesmanID FROM Salesman WHERE Salesman_Name = @SALESMAN_NAME
INSERT INTO CreditNote(	DocumentID,
			DocumentDate,
			CustomerID,
			VendorID,
			NoteValue,
			Balance,
			Memo,
			SalesmanID,
			OriginalCreditID,
			Client_ID,
			DocPrefix,
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
			@CREDITID,
			@CLIENT_ID,
			@DocPrefix,
			@DocRef)
