Create Procedure sp_get_DefinedValFromCatGroup(@Cust nvarchar(15),@GrpID nVarchar(1000))	-- @Src -> 0-CustomerID, 1-CustomerName
As
Begin
	Declare @CT int, @CL decimal(18,6), @BO int
	
	-- Get CreditTermDays, CreditLimit, NoOfBills from CustomerCreditLimit table for the specified customer and category group
	Select @CT=CreditTermDays, @CL=CreditLimit, @BO=NoOfBills From CustomerCreditLimit 
	where CustomerID=@Cust And GroupID in(Select * from dbo.sp_splitIn2Rows(@GrpID,','))

	-- Validation for CT, CL, BO. if nothing is defined in group, then take it from customer master
	If IsNull(@CT,-1) < 1
		Select @CT=IsNull(CreditTerm,-1) From Customer Where CustomerID=@Cust			-- Get credit term from customer master
	If IsNull(@CL,-1) < 0
		Select @CL=IsNull(CreditLimit,-1) From Customer Where CustomerID=@Cust			-- Get credit term from customer master
	If IsNull(@BO,-1) < 0
		Select @BO=IsNull(NoOfBillsOutStanding,-1) From Customer Where CustomerID=@Cust	-- Get credit term from customer master

	Select 'CT'=IsNull(@CT,-1), 'CL'=IsNull(@CL,-1), 'BO'=IsNull(@BO,-1)
End

