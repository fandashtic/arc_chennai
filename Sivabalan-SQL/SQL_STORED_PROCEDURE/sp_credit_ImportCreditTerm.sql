CREATE PROCEDURE sp_credit_ImportCreditTerm(@CreditValue int)      
As      
Declare @Desc nvarchar(50)      
If NOT EXISTS (Select CreditID From CreditTerm Where value = @CreditValue)       
Begin      
Select @Desc = Cast(@CreditValue as nvarchar(50)) + Dbo.LookupDictionaryItem(' - Day(s) Credit','LABEL') 
INSERT INTO CreditTerm (Description,Type,Value,Active) VALUES (@Desc,1,@CreditValue,1)        
End      
Select CreditID From CreditTerm Where value = @CreditValue  
  

