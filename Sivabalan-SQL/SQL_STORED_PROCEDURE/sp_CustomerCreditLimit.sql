Create Procedure sp_CustomerCreditLimit (
					@CustomerID [nVarChar] (30),
					@GroupID [int],
					@CreditTermDays [Int],
					@CreditLimit [Decimal]  (18, 6),
					@NoOfBills [int],
					@AM [int]
					)
As

If @AM = 2
Begin
	Delete From [CustomerCreditLimit] Where [CustomerID] Like @CustomerID
End

Insert InTo [CustomerCreditLimit] ([CustomerID], [GroupID], [CreditTermDays], 
	    [CreditLimit], [NoOfBills]) Values (@CustomerID, @GroupID, @CreditTermDays,
 @CreditLimit, @NoOfBills)

