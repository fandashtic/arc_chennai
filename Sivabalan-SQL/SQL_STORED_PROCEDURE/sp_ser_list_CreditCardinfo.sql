CREATE procedure sp_ser_list_CreditCardinfo(@BANKCODE nvarchar(50),  @ACCOUNTNUMBER nvarchar(255)    
)    
as    
select Bank.ServiceChargePercentage,'RealisationType'= IsNull(RealisationType,0),  
"CreditcardName" = [Value], "CardServicePercentage" = IsNull(BankAccount_PaymentModes.ServiceChargePercentage,0),  
CreditCardID from Bank   
Left Outer Join BankAccount_PaymentModes On BankAccount_PaymentModes.BankID  = bank.bankid   
Left Outer Join paymentmode  On BankAccount_PaymentModes.Creditcardid = paymentmode.mode     
where BankCode = @BANKCODE AND Account_Number = @ACCOUNTNUMBER   
order by CreditcardName  


