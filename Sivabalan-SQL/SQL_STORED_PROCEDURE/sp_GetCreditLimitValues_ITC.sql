
Create Procedure sp_GetCreditLimitValues_ITC(@CustID as nvarchar(30))
As
Begin
	Select ISNull(CreditTerm.Value,0) Value,Customer.CreditLimit, Customer.NoOfBillsOutstanding 
		From CreditTerm
		Left Outer Join Customer On Customer.CreditTerm = CreditTerm.CreditID  Where Customer.CustomerID = @CustID
End

