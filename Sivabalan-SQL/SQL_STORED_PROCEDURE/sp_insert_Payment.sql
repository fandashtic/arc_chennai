CREATE procedure sp_insert_Payment(@PaymentName nvarchar(255),@PaymentType int,@Active int,@SChargeCust Decimal(18,6),@SChargePro Decimal(18,6),@AccountId int=-1289)                  
         
AS  
if(@AccountId=-1289)                  
Begin  
insert into Paymentmode(value,PaymentType,active,ServiceChargeCustomer,ServiceChargeProvider) values(@paymentname,@PAymentType,@Active,@SchargeCust,@SChargePro)                  
Select @@identity                  
End  
Else  
Begin  
insert into Paymentmode(value,PaymentType,active,ServiceChargeCustomer,ServiceChargeProvider,Account_Id) values(@paymentname,@PAymentType,@Active,@SchargeCust,@SChargePro,@AccountId)                  
Select @@identity                  
End        
      
    
  




