CREATE Procedure sp_GetOldItemInvoiceQty(@Invoiceid Int,   
@Prodid nvarchar(30),  
@batchid nvarchar(20),  
@saleprice Decimal(18,6),  
@TaxSuffered Decimal(18,6) = 0,  
@TaxSuffApplicable Integer = 0,   
@TaxSuffPartOff Decimal(18,6) = 0)  
as  
  
if (@batchid<>'NA')  
 begin  
  Select Sum(Quantity) from Invoicedetail   
  where Invoiceid=@Invoiceid and Product_code=@Prodid   
  and Batch_Number=@batchid and Saleprice=@saleprice  
  Group by serial -- TaxDetails stored only in the top row and not all rows
--   and TaxSuffApplicableOn = @TaxSuffApplicable  
--   and TaxSuffPartOff = @TaxSuffPartOff  
--   and TaxSuffered2 = @TaxSuffered  
 end  
else  
begin  
  Select Sum(Quantity) from Invoicedetail   
  where Invoiceid=@Invoiceid and Product_code=@Prodid   
  and Saleprice=@saleprice   
end  


