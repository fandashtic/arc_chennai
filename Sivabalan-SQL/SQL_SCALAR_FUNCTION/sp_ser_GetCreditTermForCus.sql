CREATE Function sp_ser_GetCreditTermForCus    
(@cuscode varchar(30)) Returns Varchar(50)    
as    
begin    
Declare @CreditDesc varchar(100)    
Declare @CreditVal integer    
Declare @CreditSub varchar(100)      
Select @CreditVal=Value,@CreditSub=Case when Type=1 then 'Days' else ' Day of Every Month' end    
from Creditterm,Customer    
Where Customer.Creditterm=Creditterm.CreditId    
and Customer.CustomerId=@cuscode    
  
Set @CreditDesc=Cast(@creditVal as varchar) + @creditsub    
Return(Select @CreditDesc)    
end    

