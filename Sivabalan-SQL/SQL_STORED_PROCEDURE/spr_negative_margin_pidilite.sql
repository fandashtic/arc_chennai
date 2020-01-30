CREATE procedure [dbo].[spr_negative_margin_pidilite](@CustomerId nvarchar(2550), 
@FromDate datetime, @ToDate datetime, @ItemCode nVarChar(2550))
as

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Create table #tmpItem(ItemCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create table #tmpCust(CustomerName nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @ItemCode=N'%'   
   Insert into #tmpItem select Product_Code from Items  
Else  
   Insert into #tmpItem select * from dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter)  
  
if @CustomerId=N'%'  
   Insert into #tmpCust select Company_Name from Customer  
Else  
   Insert into #tmpCust select * from dbo.sp_SplitIn2Rows(@CustomerId,@Delimeter)  

select  cast (Invoicedetail.product_code as nvarchar) + N';' + cast (Invoiceabstract.invoiceid as nvarchar),
	"Customer ID" = InvoiceAbstract.Customerid,  
	"Customer Name" = Customer.Company_Name,
	"Document Id" = VoucherPrefix.Prefix + Cast(Invoiceabstract.documentid as nvarchar), 
	"DocRef" = Invoiceabstract.DocReference, 
	"Invoice Date" = Invoiceabstract.Invoicedate, 
	"Item Code" = Invoicedetail.product_code, 
	"Item Name" = Items.ProductName, 
	"Batch" = Invoicedetail.Batch_Number,
	"UOM" = UOM.Description, 
-------- sp + (sp * (tax suff / 100))
	"Sale Price" = Cast(Sum(Amount) / Sum(Quantity) as Decimal(18,6)),
--------------------------
-- linking invoice detail and batch product table using batch code to get the tax suffered
-- now, pp + (pp * (tax suff / 100)), where PP is (purchase price in inv detail table) / sum (qty)
	"Purchase Price" = Cast((sum(Invoicedetail.PurchasePrice) / sum(quantity)) + ( (sum(Invoicedetail.PurchasePrice) / sum(quantity)) * dbo.GetTaxSuff(max(InvoiceDetail.Batch_Code)) / 100 ) as Decimal(18,6)),
--------------------------
	"Diff in Rate" = Cast((Sum(Amount) / sum(Quantity)) - (sum(PurchasePrice) / sum(Quantity)+ ( (sum(Invoicedetail.PurchasePrice) 
			/ sum(quantity)) * dbo.GetTaxSuff(max(InvoiceDetail.Batch_Code)) / 100 )) as Decimal(18,6)),  
	"Add Margin" = dbo.GetMargin(Invoicedetail.product_code, Invoiceabstract.invoiceid), -- sum(InvoiceDetail.PTR) - sum(InvoiceDetail.PTS),  
--------------------------
	"Total Diff per Unit" = dbo.GetDiffPerUnit( Invoicedetail.product_code, Invoiceabstract.invoiceid, InvoiceAbstract.Customerid, max(Invoicedetail.Batch_Code) ) 
	- ((sum(Amount) / sum(Quantity)) 
	- (abs(sum(isnull(stpayable,0))) + abs(sum(isnull(cstpayable,0)))) /sum(Quantity)  
	- (SalePrice * max(InvoiceDetail.TaxSuffered) / 100)),
-- "ptr or pts or company price" (based on customer type ) - original (saleprice)
-- if csp set then ptr or pts can be taken from batch_products or from item master
--------------------------
	"Quantity" = sum(Quantity), 
	"Reporting UOM" = sum(Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 0) End),  
	"Conversion Factor" = sum(Quantity * IsNull(ConversionFactor, 0)),  
	"Value" = sum(InvoiceDetail.Amount)
From 	invoiceabstract, invoicedetail, Items, UOM, VoucherPrefix, Customer
where 	Invoiceabstract.Invoiceid = InvoiceDetail.Invoiceid 
	and InvoiceAbstract.InvoiceDate between @Fromdate and @Todate
	and (Invoiceabstract.status & 128) = 0 
	and InvoiceAbstract.InvoiceType in (1,3)
	and VoucherPrefix.TranID = N'INVOICE'
	and InvoiceAbstract.CustomerID = Customer.CustomerID
	and Customer.Company_Name In (Select CustomerName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)  
	and InvoiceDetail.Product_Code In (Select ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem)  
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
--	Invoicedetail.Batch_code
having 
	((sum(amount) - (abs(sum(isnull(stpayable,0))) + abs(sum(isnull(cstpayable,0)))) - (sum(SalePrice * Quantity) * max(InvoiceDetail.TaxSuffered) / 100)) - (sum(PurchasePrice))) <= 0

Drop table #tmpItem
Drop table #tmpCust
