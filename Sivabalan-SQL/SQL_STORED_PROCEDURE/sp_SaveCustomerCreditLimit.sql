
CREATE Procedure sp_SaveCustomerCreditLimit ( @CustID nvarchar(30), @GroupName nvarchar(250), @CreditDays int, @CreditLimit decimal(18,6), @NoOfBills int)
As
Begin
	
	Declare @GroupId as int

	Select @GroupId = GroupId From ProductCategoryGroupAbstract Where GroupName = @GroupName
	If @CreditDays >=0 
	Begin
		Exec sp_credit_ImportCreditTerm @CreditDays
		Select @CreditDays = CreditID From CreditTerm Where Value = @CreditDays
	End
	Insert Into CustomerCreditLimit Values(@CustID, @GroupID, @CreditDays, @CreditLimit, @NoOfBills )

End


