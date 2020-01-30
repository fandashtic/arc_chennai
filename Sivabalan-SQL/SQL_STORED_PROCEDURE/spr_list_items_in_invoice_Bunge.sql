CREATE PROCEDURE spr_list_items_in_invoice_Bunge(@INVOICEID int)        
AS        
DECLARE @ADDNDIS AS Decimal(18,6)        
DECLARE @TRADEDIS AS Decimal(18,6)        
        
SELECT @ADDNDIS = isnull(AdditionalDiscount,0), @TRADEDIS = isnull(DiscountPercentage,0) FROM InvoiceAbstract        
WHERE InvoiceID = @INVOICEID        
        
SELECT  InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,         
 "Item Name" = Items.ProductName,         
 "Batch" = InvoiceDetail.Batch_Number,        
 "Quantity" = SUM(InvoiceDetail.Quantity),         
 "Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0),         
 "Sale Tax" = CAST(Round(MAX(InvoiceDetail.TaxCode+InvoiceDetail.TaxCode2), 2) AS VARCHAR) + '%',        
 "Tax Suffered" = CAST(ISNULL(MAX(InvoiceDetail.TaxSuffered), 0) AS VARCHAR) + '%',        
 "Discount" = CAST(SUM(DiscountPercentage) AS varchar) + '%',        
 "STCredit" = Round(IsNull(Sum(InvoiceDetail.STCredit),0),2),        
 "Total" = SUM(Amount),        
 "Forum Code" = Items.Alias,       
 "Tax Suffered Value (%c)" = IsNull(Sum((InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * IsNull(InvoiceDetail.TaxSuffered,0) /100),0),          
 "Sales Tax Value (%c)" = Isnull(Sum(STPayable + CSTPayable), 0),      
 "PKD date" = CASE when pkd is null then   
   ''  
     Else  
  '01/' +  convert(varchar,Month(pkd)) + '/' + convert(varchar,Year(pkd))    
     End   
FROM InvoiceDetail, Items     
,batch_products       
WHERE   InvoiceDetail.InvoiceID = @INVOICEID AND        
 InvoiceDetail.Product_Code = Items.Product_Code        
And InvoiceDetail.batch_code = Batch_products.Batch_code    
GROUP BY Invoicedetail.Serial,InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number,         
 InvoiceDetail.SalePrice, Items.Alias  
,batch_products.pkd       
      
      
      
    
  
    
  
  



