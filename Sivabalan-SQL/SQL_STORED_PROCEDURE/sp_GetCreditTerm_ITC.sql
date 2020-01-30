
Create Procedure sp_GetCreditTerm_ITC(@CustID  nvarchar(30), @GroupID int)
As
Begin
	Select CreditID, Description From CreditTerm Where CreditID =
		(Select Distinct(CreditTermDays) From CustomerCreditLimit Where CustomerID = @CustID And GroupID = @GroupID) 	
End

