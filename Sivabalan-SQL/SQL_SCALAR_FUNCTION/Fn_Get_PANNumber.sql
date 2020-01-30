CREATE FUNCTION Fn_Get_PANNumber(@Inv_Bill_ID int, @TranType nvarchar(30), @PANType nvarchar(30))  
RETURNS nvarchar(100)
AS
BEGIN
	Declare @CustomerID nvarchar(30)
	Declare @VendorID nvarchar(30)
	Declare @Vend_PANNumber nvarchar(100)
	Declare @Cust_PANNumber nvarchar(100)
	Declare @WD_PANNumber nvarchar(100)
	Declare @MaxValue Decimal(18,6)

	Declare @PANNumber nvarchar(100)

	Set @PANNumber = ''
	Set @CustomerID = ''
	Set @VendorID = ''

	IF Exists(Select 'x' from tbl_merp_ConfigAbstract Where ScreenCode = 'PRINTPAN' and isnull(Flag,0) = 1)
	BEGIN
		Select @MaxValue = isnull(Value, 0) From tblConfigPAN Where ScreenCode = 'PRINTPAN'
		
		IF @TranType = 'INVOICE'
		BEGIN
			Select @CustomerID = CustomerID From InvoiceAbstract Where InvoiceID = @Inv_Bill_ID and NetValue >= @MaxValue

			IF @CustomerID <> ''
			Begin
				Select @Cust_PANNumber = isnull(PANNumber,'') From Customer Where CustomerID = @CustomerID
				Select @WD_PANNumber = isnull(PANNumber,'') From Setup
			End
			Else
				Select @Cust_PANNumber = '', @WD_PANNumber = ''

			IF @PANType = 'CUSTOMER'
				Set @PANNumber = @Cust_PANNumber
			Else 
				Set @PANNumber = @WD_PANNumber
		END	
		Else
		BEGIN
			Select @VendorID = VendorID From BillAbstract Where BillID = @Inv_Bill_ID and Value >= @MaxValue

			IF @VendorID <> ''
			Begin
				Select @Vend_PANNumber = isnull(PANNumber,'') From Vendors Where VendorID = @VendorID
				Select @WD_PANNumber = isnull(PANNumber,'') From Setup
			End
			Else
				Select @Vend_PANNumber = '', @WD_PANNumber = ''

			IF @PANType = 'VENDOR'
				Set @PANNumber = @Vend_PANNumber
			Else 
				Set @PANNumber = @WD_PANNumber
		END
	END

	Return @PANNumber
END
