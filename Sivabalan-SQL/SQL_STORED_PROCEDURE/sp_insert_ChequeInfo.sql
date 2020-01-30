
CREATE PROCEDURE sp_insert_ChequeInfo(	@CHEQUE_BOOK_NAME NVARCHAR(50),
					@CHEQUE_START INTEGER,
					@TOTAL_LEAVES INTEGER,
					@BANKCODE NVARCHAR(10),
					@ACCOUNTID INT)
AS
INSERT INTO Cheques(	Cheque_Start,
			Total_Leaves,
			BankCode,
			Active,
			Cheque_Book_Name,
			BankID)
VALUES
		   (	@CHEQUE_START,
			@TOTAL_LEAVES,
			@BANKCODE,
			1,
			@CHEQUE_BOOK_NAME,
			@ACCOUNTID) 


