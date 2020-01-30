CREATE Function GetInvoiceTaxComponentValue_Mobile (@InvoiceID Int,
						@Product_Code nvarchar(15),
						@TaxID Int,
						@TaxComponentCode Int,
						@Locality Int, @Serial Int)
Returns Decimal(18, 6)
As
Begin
Declare @Qty Decimal(18, 6)
Declare @CustomerLocality Int
Declare @TaxValue Decimal(18, 6)
Declare @InvoiceType Int

Select @InvoiceType = InvoiceType From InvoiceAbstract Where InvoiceID = @InvoiceID
If @InvoiceType = 2
Begin
	Set @CustomerLocality = 1
End
Else
Begin
	Select @CustomerLocality = IsNull(Locality, 1) From InvoiceAbstract, Customer
	Where InvoiceID = @InvoiceID And InvoiceAbstract.CustomerID = Customer.CustomerID
End

If @CustomerLocality = @Locality
Begin
	set @Qty = 0
	Select @Qty = Sum(Quantity) from InvoiceDetail where InvoiceID = @InvoiceID and 
	Product_Code = @Product_Code and TaxID = @TaxID

	Select @TaxValue = Tax_Value From InvoiceTaxComponents
	Where InvoiceID = @InvoiceID
	And Product_Code = @Product_Code
	And Tax_Code = @TaxID
	And Tax_Component_Code = @TaxComponentCode
	if @Qty > 0 set @TaxValue = @TaxValue / @qty 
	
	select @TaxValue = (sum(Quantity) * @TaxValue) from InvoiceDetail 
	where InvoiceId = @InvoiceID and 
	Product_Code = @Product_Code and TaxID = @TaxID and Serial = @Serial
End
Else
	Set @TaxValue = 0
Return @TaxValue
End

