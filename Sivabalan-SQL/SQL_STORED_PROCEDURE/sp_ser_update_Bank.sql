CREATE PROCEDURE sp_ser_update_Bank(@BANK_CODE NVARCHAR(50),        
@ACCOUNT_NUMBER NVARCHAR(255),      
@ServicechargePercentage Decimal(18,6),        
@RealisationType int)        
AS        
UPDATE Bank SET RealisationType = @RealisationType,      
ServicechargePercentage = @ServicechargePercentage      
WHERE  BankCode = @BANK_CODE and Account_Number = @ACCOUNT_NUMBER       
  
SELECT BankID from Bank  
WHERE  BankCode = @BANK_CODE and Account_Number = @ACCOUNT_NUMBER           


