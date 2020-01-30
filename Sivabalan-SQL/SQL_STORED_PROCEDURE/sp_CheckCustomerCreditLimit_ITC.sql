

CREATE Procedure sp_CheckCustomerCreditLimit_ITC(
	@CustomerID nvarchar(30),
	@CreditLimit decimal(18,6),
	@NoOfBills int,
	@CreditTerm int)
As
Begin

	Declare @GroupCL decimal(18,6)
	Declare @GroupNOB int
	Declare @GroupCT int
	
	--If product category group is not definied in the master, allow to import the customer
       If (Select count(*) From CustomerCreditLimit Where GroupID=0 And CustomerID=@CustomerID)=1 Or 
	(Select count(*) From CustomerCreditLimit Where CustomerID=@CustomerID) =  0

--	If (Select count(*) From CustomerCreditLimit Where GroupID=0 And CustomerID=@CustomerID) <=1 
	Begin
		Select 0
		Goto Done
	End

	--When import check whether the customer overall exceeds the customer wise group wise limits
	Select @GroupCL =Case When  @CreditLimit = -1 Then Max(CreditLimit) Else Sum(CreditLimit) End, 
			@GroupNOB = Case When @NoOfBills = -1 then Max(NoOfBills) Else Sum(NoOfBills) End, 
			@GroupCT = Case When @CreditTerm = -1 Then  Max(CreditTermDays) Else
						IsNull((Select Max(Value) From CreditTerm Where CreditID in (Select CreditTermDays From CustomerCreditLimit Where CustomerID = @CustomerID)), -1)  End
			From CustomerCreditLimit Where CustomerID = @CustomerID

	If @CreditLimit <> @GroupCL And @GroupCL > -1
		Select 1 --CreditLimit not matched
	Else If @NoOfBills <> @GroupNOB And @GroupNOB > -1
		Select 2 -- NoOfBills not matched
	Else If @CreditTerm  <  @GroupCT And @GroupCT > -1
		Select 3 -- CreditTerm not matchex
	Else
		Select 0 --Do import
Done:


End




