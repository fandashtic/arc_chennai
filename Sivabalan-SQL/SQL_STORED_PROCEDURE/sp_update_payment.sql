CREATE PROCEDURE sp_update_payment(@paymentname nvarchar(255),@PaymentType int,        
          @ACTIVE int,@SChargeCust Decimal(18,6),@SChargePro Decimal(18,6),@AccountId int=-1289)           
as           
if(@AccountId=-1289)  
UPDATE paymentmode SET PAymentType = @PaymentType ,active = @active,ServiceChargeCustomer=@SChargeCust,ServiceChargeProvider=@SChargePro WHERE value = @paymentname        
else  
UPDATE paymentmode SET PAymentType = @PaymentType ,active = @active,ServiceChargeCustomer=@SChargeCust,ServiceChargeProvider=@SChargePro,Account_Id=@AccountID WHERE value = @paymentname  
  
    
    
  
  
    
  





