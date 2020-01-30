CREATE Function GetInvoiceTaxComponentValue    (@InvoiceID Int,
						@Product_Code nvarchar(15),
						@TaxID Int,
						@TaxComponentCode Int,
						@Locality Int)
Returns Decimal(18, 6)
As
Begin
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
	Select @TaxValue = Tax_Value From InvoiceTaxComponents
	Where InvoiceID = @InvoiceID
	And Product_Code = @Product_Code
	And Tax_Code = @TaxID
	And Tax_Component_Code = @TaxComponentCode
End
Else
	Set @TaxValue = 0
Return @TaxValue
End
