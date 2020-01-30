
CREATE PROCEDURE sp_insert_Bank(	@ACCOUNT_NO NVARCHAR(50),
				@ACCOUNT_NAME NVARCHAR(50),
				@BANK_CODE nvarchar(50),
				@BRANCH_CODE nvarchar(50))
AS
INSERT INTO Bank(Account_Number,
		 Account_Name,
		 BankCode,
		 BranchCode,
		 Active)
Values		(@ACCOUNT_NO,
		 @ACCOUNT_NAME,
		 @BANK_CODE,
		 @BRANCH_CODE,
		 1)
SELECT @@IDENTITY

