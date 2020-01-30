Create Procedure mERP_sp_isTransTax(@TaxCode int)
AS
Begin
If EXISTS ( SELECT TOP 1 Tax_Code From InvoiceTaxComponents Where Tax_Code = @TaxCode) Or
   EXISTS ( SELECT TOP 1 TaxID From InvoiceDetail Where TaxID = @TaxCode) Or
   EXISTS ( SELECT TOP 1 TaxCode From Batch_Products Where TaxCode = @TaxCode) Or
   EXISTS ( SELECT TOP 1 GRNTaxID From Batch_Products Where GRNTaxID = @TaxCode) Or
   EXISTS ( SELECT TOP 1 Tax_Code From BillTaxComponents Where Tax_Code = @TaxCode) Or
   EXISTS ( SELECT TOP 1 TaxCode From BillDetail Where TaxCode = @TaxCode) Or
   EXISTS ( SELECT TOP 1 Tax_Code From STITaxComponents Where Tax_Code = @TaxCode) Or
   EXISTS ( SELECT TOP 1 Tax_Code From STOTaxComponents Where Tax_Code = @TaxCode)
SELECT 1
Else
SELECT 0
End
