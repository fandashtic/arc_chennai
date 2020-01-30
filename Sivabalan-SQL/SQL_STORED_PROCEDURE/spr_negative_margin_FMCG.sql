CREATE procedure [dbo].[spr_negative_margin_FMCG] (@ItemCode nvarchar(15), @CustomerId nvarchar(100), @FromDate datetime, @ToDate datetime)  
as  
select  cast (Invoicedetail.product_code as nvarchar) + ';' + cast (Invoiceabstract.invoiceid as nvarchar),    
-------
 "Customer ID" = InvoiceAbstract.Customerid,    
 "Customer Name" = Customer.Company_Name,  
 "Document Id" = VoucherPrefix.Prefix + Cast(Invoiceabstract.documentid as nvarchar),   
 "DocRef" = Invoiceabstract.DocReference,   
 "Invoice Date" = Invoiceabstract.Invoicedate,   
 "Item Code" = Invoicedetail.product_code,   
 "Item Name" = Items.ProductName,   
 "Batch" = Invoicedetail.Batch_Number,  
 "UOM" = UOM.Description,   
-- sp + (sp * (tax suff / 100))  
 "Sale Price" = Cast(Sum(Amount) / Sum(Quantity) as Decimal(18,6)),
-- linking invoice detail and batch product table using batch code to get the tax suffered  
-- now, pp + (pp * (tax suff / 100)), where PP is (purchase price in inv detail table) / sum (qty)  
 "Purchase Price" = Cast((sum(Invoicedetail.PurchasePrice) / sum(quantity)) + ( (sum(Invoicedetail.PurchasePrice) / sum(quantity)) * dbo.GetTaxSuff(max(InvoiceDetail.Batch_Code)) / 100 ) as Decimal(18,6)),  
--------------------------  
 "Diff in Rate" = ((sum(Amount) / sum(Quantity)) - (abs(sum(isnull(stpayable,0))) + abs(sum(isnull(cstpayable,0)))) - (SalePrice * max(InvoiceDetail.TaxSuffered) / 100)) - (sum(PurchasePrice) / sum(Quantity)),    
 "Total Diff per Unit" = dbo.GetDiffPerUnit_FMCG( Invoicedetail.product_code, Invoiceabstract.invoiceid, InvoiceAbstract.Customerid, max(Invoicedetail.Batch_Code)) - ((sum(Amount) / sum(Quantity)) - (abs(sum(isnull(stpayable,0))) + abs(sum(isnull(cstpayable,0)))) - (SalePrice * max(InvoiceDetail.TaxSuffered) / 100)),  
--------------------------  
 "Quantity" = sum(Quantity), "Value" = sum(InvoiceDetail.Amount)  
---------------------------------------
From  invoiceabstract, invoicedetail, Items, UOM, VoucherPrefix, Customer  
where  Invoiceabstract.Invoiceid = InvoiceDetail.Invoiceid   
 and InvoiceAbstract.InvoiceDate between @Fromdate and @Todate  
 and (Invoiceabstract.status & 128) = 0   
 and InvoiceAbstract.InvoiceType in (1,3)  
 and VoucherPrefix.TranID = 'INVOICE'  
 and InvoiceAbstract.CustomerID = Customer.CustomerID  
 and Customer.Company_Name Like @CustomerId  
 and InvoiceDetail.Product_Code Like @ItemCode  
 and InvoiceDetail.Product_Code = Items.Product_Code  
 and Items.UOM *= UOM.UOM  
group by  
 Customer.Company_Name,  
 Invoiceabstract.Documentid,   
 invoiceabstract.InvoiceID,   
 Invoiceabstract.InvoiceDate,   
 InvoiceDetail.Product_Code,  
 Items.ProductName,   
 UOM.Description,   
 Invoicedetail.SalePrice ,  
 Invoicedetail.Batch_Number,  
 InvoiceAbstract.Customerid,  
 VoucherPrefix.Prefix,  
 Invoiceabstract.DocReference  
-- Invoicedetail.Batch_code  
having ((sum(amount) - (abs(sum(isnull(stpayable,0))) + abs(sum(isnull(cstpayable,0)))) - 
	(sum(SalePrice * Quantity) * max(InvoiceDetail.TaxSuffered) / 100)) - (sum(PurchasePrice))) <= 0
