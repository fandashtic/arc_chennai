CREATE Procedure sp_ser_updateCreditCardInfo(@BankID int,    
@CreditCardID int,    
@ServiceChargePercentage Decimal(18,6))    
As    
If Not Exists(select * from BankAccount_PaymentModes where BankID = @BankID  
and CreditCardID = @CreditCardID)     
Begin    
 insert into BankAccount_PaymentModes(BankID,CreditCardID,ServiceChargePercentage)    
 values(@BankID,    
 @CreditCardID,    
 @ServiceChargePercentage)    
End    
Else  
Begin  
 Update BankAccount_PaymentModes  
 Set ServiceChargePercentage = @ServiceChargePercentage  
 Where BankID = @BankID and CreditCardID = @CreditCardID  
End  


