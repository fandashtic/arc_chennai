Create PROCEDURE sp_count_CstTax_transactions(@TaxPercentage Decimal(18,6), @TaxCode int)  
AS  
IF EXISTS ( SELECT TOP 1 TaxCode2 From SODetail WHERE TaxCode2 = @TaxPercentage ) Or
   EXISTS ( SELECT TOP 1 TaxCode2 From InvoiceDetail Where TaxCode2 = @TaxPercentage) Or
   EXISTS ( SELECT TOP 1 TaxCode From BillDetail where TaxCode = @TaxCode) 
 SELECT 1   
ELSE  
 SELECT 0  
