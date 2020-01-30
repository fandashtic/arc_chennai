Create PROCEDURE sp_count_LstTax_transactions(@TaxPercentage Decimal(18,6), @TaxCode int)  
AS  
IF EXISTS ( SELECT TOP 1 SaleTax From SODetail WHERE SaleTax  = @TaxPercentage ) Or
   EXISTS ( SELECT TOP 1 TaxCode From InvoiceDetail Where TaxCode = @TaxPercentage) Or	
   EXISTS ( SELECT TOP 1 TaxSuffered From Batch_Products Where TaxSuffered = @TaxPercentage ) Or
   EXISTS ( SELECT TOP 1 TaxSuffered From BillDetail where TaxSuffered = @TaxPercentage ) Or
   EXISTS ( SELECT TOP 1 Tax From AdjustmentReturnDetail Where Tax = @TaxPercentage) Or
   EXISTS ( SELECT TOP 1 TaxCode From stocktransferinDetail Where TaxCode = @TaxCode) Or
   EXISTS ( SELECT TOP 1 TaxSuffered From stocktransferoutDetail Where TaxSuffered = @TaxPercentage)
 SELECT 1   
ELSE  
 SELECT 0  
