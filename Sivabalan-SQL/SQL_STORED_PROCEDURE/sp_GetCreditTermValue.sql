
CREATE Procedure sp_GetCreditTermValue( @Cust nvarchar(30))    
As    
Begin    
	Declare @CreditTerm int
	
	Select @CreditTerm = IsNull(CreditTerm,0) From Customer Where CustomerID = @Cust 
	If @CreditTerm =0
		Select 0
	Else
	Begin 
		Select @CreditTerm = CreditTerm.Value From CreditTerm, Customer    
		Where Customer.CreditTerm = CreditTerm.CreditID    
		And Customer.CustomerID = @Cust    
		And CreditTerm.Active = 1

		Select @CreditTerm
	End

End    
  


