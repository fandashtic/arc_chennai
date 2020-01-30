CREATE PROCEDURE sp_ser_drop_bank(@BANK_CODE NVARCHAR(50),      
@ACCOUNT_NUMBER NVARCHAR(255))      
AS      
UPDATE Bank SET RealisationType = NULL,  
ServicechargePercentage = NULL  
WHERE  BankCode = @BANK_CODE and Account_Number = @ACCOUNT_NUMBER     
SELECT BankID from bank where BankCode = @BANK_CODE and Account_Number = @ACCOUNT_NUMBER    


