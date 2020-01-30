CREATE procedure [dbo].[spr_ser_negative_margin_FMCG](@ItemCode varchar(15), @CustomerId varchar(100), @FromDate datetime, @ToDate datetime)  
as  

Create Table #LowMarginTemp(CustID nvarchar(100),[Customer ID] nvarchar(15),[Customer Name] nvarchar(150),
[Document Id] nvarchar(100),DocRef nvarchar(255),[Invoice Date] datetime,[Item Code] nvarchar(15),
[Item Name] nvarchar(255),Batch varchar(128),UOM varchar(255),[Sale Price] Decimal(18,6),
[Purchase Price] Decimal(18,6),
[Diff in Rate] Decimal(18,6),
[Total Diff per Unit] Decimal(18,6),
[Quantity] Decimal(18,6),
[Value] Decimal(18,6))

Insert into #LowMarginTemp

select  cast (Invoicedetail.product_code as varchar) + ';' + cast (Invoiceabstract.invoiceid as varchar),    
-------
 "Customer ID" = InvoiceAbstract.Customerid,    
 "Customer Name" = Customer.Company_Name,  
 "Document Id" = VoucherPrefix.Prefix + Cast(Invoiceabstract.documentid as varchar),   
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
 "Purchase Price" = Cast((sum(Invoicedetail.PurchasePrice) / sum(quantity)) + ( (sum(Invoicedetail.PurchasePrice) / sum(quantity)) * dbo.sp_ser_GetTaxSuff(max(InvoiceDetail.Batch_Code)) / 100 ) as Decimal(18,6)),  
--------------------------  
 "Diff in Rate" = ((sum(Amount) / sum(Quantity)) - (abs(sum(isnull(stpayable,0))) + abs(sum(isnull(cstpayable,0)))) - (SalePrice * max(InvoiceDetail.TaxSuffered) / 100)) - (sum(PurchasePrice) / sum(Quantity)),    
 "Total Diff per Unit" = dbo.sp_ser_GetDiffPerUnit_FMCG ( Invoicedetail.product_code, Invoiceabstract.invoiceid, InvoiceAbstract.Customerid, max(Invoicedetail.Batch_Code)) - ((sum(Amount) / sum(Quantity)) - (abs(sum(isnull(stpayable,0))) + abs(sum(isnull(

cstpayable,0)))) - (SalePrice * max(InvoiceDetail.TaxSuffered) / 100)),  
--------------------------  
 "Quantity" = sum(Quantity), "Value" = sum(InvoiceDetail.Amount)  
---------------------------------------
From  invoiceabstract, invoicedetail, Items, UOM, VoucherPrefix, Customer  
where  Invoiceabstract.Invoiceid = InvoiceDetail.Invoiceid   
 and InvoiceAbstract.InvoiceDate between @Fromdate and @Todate  
 and (Invoiceabstract.status & 128) = 0   
 and InvoiceAbstract.InvoiceType in (2)  
 and VoucherPrefix.TranID = 'RETAIL INVOICE' 
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


Insert into #LowMarginTemp

select  cast (serviceInvoicedetail.sparecode as varchar) + ';' + cast (serviceInvoiceabstract.serviceinvoiceid as varchar),    
-------
 "Customer ID" = serviceInvoiceAbstract.Customerid,    
 "Customer Name" = Customer.Company_Name,  
 "Document Id" = VoucherPrefix.Prefix + Cast(serviceInvoiceabstract.documentid as varchar),   
 "DocRef" = serviceInvoiceabstract.DocReference,   
 "Invoice Date" = serviceInvoiceabstract.serviceInvoicedate,   
 "Item Code" = serviceInvoicedetail.sparecode,   
 "Item Name" = Items.ProductName,   
 "Batch" = serviceInvoicedetail.Batch_Number,  
 "UOM" = UOM.Description,   
-- sp + (sp * (tax suff / 100))  
 "Sale Price" = Cast(Sum(serviceinvoicedetail.netvalue) / Sum(Quantity) as Decimal(18,6)),
-- linking invoice detail and batch product table using batch code to get the tax suffered  
-- now, pp + (pp * (tax suff / 100)), where PP is (purchase price in inv detail table) / sum (qty)  
 "Purchase Price" = Cast((sum(issuedetail.PurchasePrice) / sum(quantity)) + ( (sum(issuedetail.PurchasePrice) / sum(quantity)) * dbo.sp_ser_GetTaxSuff(max(serviceInvoiceDetail.Batch_Code)) / 100 ) as Decimal(18,6)),  
--------------------------  
 "Diff in Rate" = ((sum(serviceinvoicedetail.netvalue) / sum(Quantity)) - (abs(sum(isnull(lstpayable,0))) + abs(sum(isnull(cstpayable,0)))) - (Price * max(serviceInvoiceDetail.Tax_SufferedPercentage) / 100)) - (sum(issuedetail.PurchasePrice) / sum(Quantity)),    
 "Total Diff per Unit" = dbo.sp_ser_GetDiffPerUnit_FMCG ( serviceInvoicedetail.sparecode, serviceInvoiceabstract.serviceinvoiceid, serviceInvoiceAbstract.Customerid, max(serviceInvoicedetail.Batch_Code)) - ((sum(serviceinvoicedetail.netvalue) / sum(Quantity)) - (abs(sum(isnull(lstpayable,0))) + abs(sum(isnull(cstpayable,0)))) - (Price * max(serviceInvoiceDetail.Tax_Sufferedpercentage) / 100)),  
--------------------------  
 "Quantity" = sum(Quantity), "Value" = sum(serviceInvoiceDetail.netvalue)  
---------------------------------------
From  serviceinvoiceabstract, serviceinvoicedetail, Items, UOM, VoucherPrefix, Customer,Issuedetail
where serviceInvoiceabstract.serviceInvoiceid = serviceInvoiceDetail.serviceInvoiceid   
and ServiceInvoicedetail.IssueID = Issuedetail.IssueID
and Serviceinvoicedetail.Issue_serial = Issuedetail.SerialNo
 and serviceInvoiceAbstract.serviceInvoiceDate between @Fromdate and @Todate  
 and isnull(serviceInvoiceabstract.status,0) & 192  = 0   
 and serviceInvoiceAbstract.serviceInvoiceType in (1)  
 and Isnull(serviceinvoicedetail.sparecode,'') <> ''
 and VoucherPrefix.TranID = 'SERVICEINVOICE'  
 and serviceInvoiceAbstract.CustomerID = Customer.CustomerID  
 and Customer.Company_Name Like @CustomerId  
 and serviceInvoiceDetail.spareCode Like @ItemCode  
 and serviceInvoiceDetail.spareCode = Items.Product_Code  
 and Items.UOM *= UOM.UOM  
group by  
Customer.Company_Name,  
serviceInvoiceabstract.Documentid,   
serviceinvoiceabstract.serviceInvoiceID,   
serviceInvoiceabstract.serviceInvoiceDate,   
serviceInvoiceDetail.spareCode,  
Issuedetail.SerialNo,
Items.ProductName,   
UOM.Description,   
serviceInvoicedetail.Price ,  
serviceInvoicedetail.Batch_Number,  
serviceInvoiceAbstract.Customerid,  
VoucherPrefix.Prefix,  
serviceInvoiceabstract.DocReference  
-- Invoicedetail.Batch_code  
having ((sum(serviceinvoicedetail.netvalue) - (abs(sum(isnull(lstpayable,0))) + abs(sum(isnull(cstpayable,0)))) - 
	(sum(Price * Quantity) * max(serviceInvoiceDetail.Tax_Sufferedpercentage) / 100)) - (sum(issuedetail.PurchasePrice))) <= 0
Select * from #LowMarginTemp
Drop Table #LowMarginTemp
