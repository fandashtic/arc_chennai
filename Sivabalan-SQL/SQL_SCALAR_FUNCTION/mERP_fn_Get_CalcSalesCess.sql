CREATE Function mERP_fn_Get_CalcSalesCess
(@InvoiceID nvarchar(30), @TaxCode int = 0)  
Returns Decimal(18,6)  
AS  
BEGIN  
Declare @Cess Decimal(18,6)
Declare @temp Table (Amt Decimal(18,6))
IF Exists(Select * From Taxcomponents Where Tax_Code = @TaxCode)
Begin
	Insert into @temp
	Select ((Tax_Percentage) * Sum(InvoiceDetail.Quantity * SalePrice) / 100) / 100 From InvoiceDetail
	INNER JOIN TaxComponents ON TaxComponents.Tax_Code = InvoiceDetail.TaxID Where InvoiceID = @InvoiceID
	And ApplicableOn = 'Price' And LST_Flag=1 And InvoiceDetail.TaxID = @TaxCode
	Group By Tax_Percentage, Serial

	Select @Cess = Sum(Amt) From @temp
	END
	Else
	BEGIN
	Insert into @temp
	Select ((Percentage * Sum(InvoiceDetail.Quantity * SalePrice) / 100) * 100/101) / 100 From InvoiceDetail
	INNER JOIN Tax ON Tax.Tax_Code = InvoiceDetail.TaxID Where InvoiceID = @InvoiceID
	And InvoiceDetail.TaxID = @TaxCode Group By Percentage, Serial

	Select @Cess = Sum(Amt) From @temp
END
Return IsNull(@Cess, 0)
END
