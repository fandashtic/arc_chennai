CREATE Procedure Sp_ser_dropCreditList(@BankID int,          
@CreditCardID nvarchar(4000) = NULL,@Mode int)          
as          
if @mode = 1          
Begin          
  
 Create table #TempCredit(Creditid1 nvarchar(50) null)  
 Insert into  #TempCredit exec sp_ser_SqlSplit @CreditCardID,','  
  
 delete BankAccount_PaymentModes  
 where bankid = @bankid and CreditCardID not in(select Creditid1 from #TempCredit)  
 drop table #TempCredit  
End            
Else   
Begin            
 Delete BankAccount_PaymentModes               
 Where bankid = @bankid           
End          


