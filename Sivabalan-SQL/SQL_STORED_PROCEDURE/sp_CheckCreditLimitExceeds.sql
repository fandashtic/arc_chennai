
CREATE Procedure sp_CheckCreditLimitExceeds(@CustID nvarchar(30), @Value decimal(18,6))  
As  
Begin  
	Declare @CreditLimitCust as decimal(18,6)  
	Declare @CreditLimitGroup as decimal(18,6)  
	
	Select @CreditLimitCust = CreditLimit From Customer Where CustomerID = @CustID  
	---If no creditlimit defined for the customer then skip	
	If  @CreditLimitCust = 0 
		Select 0
	Else 
	Begin
		Select @CreditLimitGroup = Sum(CreditLimit) From CustomerCreditLimit Where CustomerID = @CustID  
		Set @CreditLimitGroup = @CreditLimitGroup + @Value  
		If @CreditLimitGroup > @CreditLimitCust   
			Select 1 --Exceeds  
		Else  
			Select 2
	End	
End  
  


