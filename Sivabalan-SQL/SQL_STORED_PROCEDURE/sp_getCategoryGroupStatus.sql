
Create Procedure sp_getCategoryGroupStatus(@Cust nvarchar(15),@GrpID int)	-- @Src -> 0-CustomerID, 1-CustomerName
As
Begin
	Declare @GLStatus int	-- General Status
	Declare @CTStatus int	-- CreditTerm Status
	Declare @CLStatus int	-- CreditLimit Status
	Declare @BOStatus int	-- Bills O/S Status
	Declare @CT int, @CL decimal(18,6), @BO int

	Select @CT=CreditTermDays, @CL=CreditLimit, @BO=NoOfBills From CustomerCreditLimit 
	where CustomerID=@Cust And GroupID=@GrpID
	
	If IsNull(@CT,0)=0 And IsNull(@CL,0)=0 And IsNull(@BO,0)=0 
		Set @GLStatus=0
	Else
	Begin
		Set @GLStatus=1

		-- Validation for credit term
		If @CT = 0
			Set @CTStatus=0			
		Else
			Set @CTStatus=1			

		-- Validation for credit limit
		If @CL = 0
			Set @CLStatus=0			-- Alert not needed
		Else
			Set @CLStatus=1			-- Alert needed

		-- Validation for bills outstanding
		If @BO = 0
			Set @BOStatus=0			-- Alert not needed
		Else
			Set @BOStatus=1			-- Alert needed

	End
	Select Isnull(@GLStatus,0), IsNull(@CTStatus,0), IsNull(@CLStatus,0), IsNull(@BOStatus,0), IsNull(@CT,0), IsNull(@CL,0), IsNull(@BO,0)
End
