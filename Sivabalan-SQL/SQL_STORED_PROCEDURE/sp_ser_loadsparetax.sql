CREATE procedure sp_ser_loadsparetax(@Mode Int,@CustomerID nvarchar(50))
as
Declare @TaxSuffered Int
Declare @SaleTax Int
Declare @Locality Int

Set @TaxSuffered = 1
Set @SaleTax = 2

If @Mode = @TaxSuffered
Begin
	Select Percentage,Tax_Code from Tax
End
Else If @Mode = @SaleTax
Begin
	Select @Locality = IsNull(Locality,1) from Customer Where CustomerID = @CustomerID
	If @Locality = 1 
	Begin
		Select Percentage,Tax_Code from Tax
	End
	Else If @Locality = 2
	Begin
		Select 'Percentage' = IsNull(CST_Percentage,0),
		Tax_Code from Tax
	End
End


