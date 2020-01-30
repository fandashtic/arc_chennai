Create Function fn_GetCreditTermForCus
(@cuscode nvarchar(30)) Returns nvarchar(50)
as
begin
	declare @CreditDesc nvarchar(50)
        Declare @CreditVal integer
        Declare @CreditSub nvarchar(30)


	Select @CreditVal=Value,@CreditSub=Case when Type=1 then dbo.lookupdictionaryitem(' Days',default) 
	else dbo.lookupdictionaryitem(' Day of Every Month',default) end
	from Creditterm,Customer
	Where Customer.Creditterm=Creditterm.CreditId
	and Customer.CustomerId=@cuscode
    
        Set @CreditDesc=Cast(@creditVal as nvarchar) + @creditsub

Return(Select @CreditDesc)
end

