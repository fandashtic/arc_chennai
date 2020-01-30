CREATE procedure [dbo].[spr_ser_negative_margin] (@ItemCode varchar(2550), @CustomerId varchar(2550), @FromDate datetime, @ToDate datetime)
as

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  
Create table #tmpItem(ItemCode varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
Create table #tmpCust(CustomerName varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
if @ItemCode='%'   
   Insert into #tmpItem select Product_Code from Items  
Else  
   Insert into #tmpItem select * from dbo.sp_ser_SplitIn2Rows(@ItemCode,@Delimeter)  
  
if @CustomerId='%'  
   Insert into #tmpCust select Company_Name from Customer  
Else  
   Insert into #tmpCust select * from dbo.sp_ser_SplitIn2Rows(@CustomerId,@Delimeter)  

Create Table #LowMarginTemp(CustID nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Customer ID] nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Customer Name] nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Document Id] nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
DocRef nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Invoice Date] datetime,
[Item Code] nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Item Name] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
Batch varchar(128) COLLATE SQL_Latin1_General_CP1_CI_AS,
UOM varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Sale Price] Decimal(18,6),
[Purchase Price] Decimal(18,6),
[Diff in Rate] Decimal(18,6),
[Add Margin] Decimal(18,6),
[Total Diff per Unit] Decimal(18,6),
[Quantity] Decimal(18,6),
[Value] Decimal(18,6))

Insert into #LowMarginTemp

select  cast (Invoicedetail.product_code as varchar) + ';' + cast (Invoiceabstract.invoiceid as varchar),
	"Customer ID" = InvoiceAbstract.Customerid,  
	"Customer Name" = Customer.Company_Name,
	"Document Id" = VoucherPrefix.Prefix + Cast(Invoiceabstract.documentid as varchar), 
	"DocRef" = Invoiceabstract.DocReference, 
	"Invoice Date" = Invoiceabstract.Invoicedate, 
	"Item Code" = Invoicedetail.product_code, 
	"Item Name" = Items.ProductName, 
	"Batch" = Invoicedetail.Batch_Number,
	"UOM" = UOM.Description, 
	"Sale Price" = Cast(Sum(Amount) / Sum(Quantity) as Decimal(18,6)),
	"Purchase Price" = Cast((sum(Invoicedetail.PurchasePrice) / sum(quantity)) + ( (sum(Invoicedetail.PurchasePrice) / sum(quantity)) * dbo.sp_ser_GetTaxSuff(max(InvoiceDetail.Batch_Code)) / 100 ) as Decimal(18,6)),
	"Diff in Rate" = Cast((Sum(Amount) / sum(Quantity)) - (sum(PurchasePrice) / sum(Quantity)+ ( (sum(Invoicedetail.PurchasePrice) 
			/ sum(quantity)) * dbo.GetTaxSuff_service(max(InvoiceDetail.Batch_Code)) / 100 )) as Decimal(18,6)),  
	"Add Margin" = dbo.sp_ser_GetMargin(Invoicedetail.product_code, Invoiceabstract.invoiceid,1,0), -- sum(InvoiceDetail.PTR) - sum(InvoiceDetail.PTS),  

	"Total Diff per Unit" = dbo.sp_ser_GetDiffPerUnit(Invoicedetail.product_code, Invoiceabstract.invoiceid, InvoiceAbstract.Customerid, max(Invoicedetail.Batch_Code) ) 
	- ((sum(Amount) / sum(Quantity)) 
	- (abs(sum(isnull(stpayable,0))) + abs(sum(isnull(cstpayable,0)))) /sum(Quantity)  
	- (SalePrice * max(InvoiceDetail.TaxSuffered) / 100)),

	"Quantity" = sum(Quantity), "Value" = sum(InvoiceDetail.Amount)
From 	invoiceabstract, invoicedetail, Items, UOM, VoucherPrefix, Customer
where 	Invoiceabstract.Invoiceid = InvoiceDetail.Invoiceid 
	and InvoiceAbstract.InvoiceDate between @Fromdate and @Todate
	and (Invoiceabstract.status & 128) = 0 
	and InvoiceAbstract.InvoiceType in (1,3)
	and VoucherPrefix.TranID = 'INVOICE'
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


Insert into #LowMarginTemp

select  cast (ServiceInvoicedetail.Sparecode as varchar) + ';' + cast (ServiceInvoiceabstract.Serviceinvoiceid as varchar),
	"Customer ID" = ServiceInvoiceAbstract.Customerid,  
	"Customer Name" = Customer.Company_Name,
	"Document Id" = VoucherPrefix.Prefix + Cast(ServiceInvoiceabstract.documentid as varchar), 
	"DocRef" = ServiceInvoiceabstract.DocReference, 
	"Invoice Date" = ServiceInvoiceabstract.ServiceInvoicedate, 
	"Item Code" = ServiceInvoicedetail.Sparecode, 
	"Item Name" = Items.ProductName, 
	"Batch" = ServiceInvoicedetail.Batch_Number,
	"UOM" = UOM.Description, 
	"Sale Price" = Cast(Sum(ServiceInvoiceDetail.Netvalue) / Sum(ServiceInvoiceDetail.Quantity) as Decimal(18,6)),
	"Purchase Price" = Cast((sum(IssueDetail.PurchasePrice) / sum(ServiceInvoiceDetail.quantity)) + ( (sum(IssueDetail.PurchasePrice) / sum(quantity)) * dbo.sp_ser_GetTaxSuff(max(ServiceInvoiceDetail.Batch_Code)) / 100 ) as Decimal(18,6)),

	"Diff in Rate" = Cast((Sum(ServiceInvoiceDetail.NetValue) / sum(ServiceInvoiceDetail.Quantity)) - (sum(IssueDetail.PurchasePrice) / sum(ServiceInvoiceDetail.Quantity)+ ( (sum(IssueDetail.PurchasePrice) 
			/ sum(quantity)) * dbo.sp_ser_GetTaxSuff(max(ServiceInvoiceDetail.Batch_Code)) / 100 )) as Decimal(18,6)),  
	"Add Margin" = dbo.sp_ser_GetMargin(ServiceInvoicedetail.Sparecode, ServiceInvoiceabstract.Serviceinvoiceid,2,Issuedetail.SerialNo), -- sum(InvoiceDetail.PTR) - sum(InvoiceDetail.PTS),  

	"Total Diff per Unit" = dbo.sp_ser_GetDiffPerUnit( ServiceInvoicedetail.Sparecode, ServiceInvoiceabstract.Serviceinvoiceid, ServiceInvoiceAbstract.Customerid, max(ServiceInvoicedetail.Batch_Code) ) 
	- ((sum(ServiceInvoiceDetail.NetValue) / sum(ServiceInvoiceDetail.Quantity)) 
	- (abs(sum(isnull(ServiceInvoiceDetail.lstpayable,0))) + abs(sum(isnull(ServiceInvoiceDetail.cstpayable,0)))) /sum(ServiceInvoiceDetail.Quantity)  
	- (Price * max(ServiceInvoiceDetail.Tax_SufferedPercentage) / 100)),

	"Quantity" = sum(ServiceInvoiceDetail.Quantity), "Value" = sum(ServiceInvoiceDetail.NetValue)
From 	Serviceinvoiceabstract, Serviceinvoicedetail, Items, UOM, VoucherPrefix, Customer,Issuedetail
where 	ServiceInvoiceabstract.ServiceInvoiceid = ServiceInvoiceDetail.ServiceInvoiceid 
        and ServiceInvoicedetail.IssueID = Issuedetail.IssueID
        and Serviceinvoicedetail.Issue_serial = Issuedetail.SerialNo
	and ServiceInvoiceAbstract.ServiceInvoiceDate between @Fromdate and @Todate
	and Isnull(ServiceInvoiceabstract.status,0) & 192 = 0 
	and ServiceInvoiceAbstract.ServiceInvoiceType in (1)
        and Isnull(serviceinvoicedetail.sparecode,'') <> ''
	and VoucherPrefix.TranID = 'SERVICEINVOICE'
	and ServiceInvoiceAbstract.CustomerID = Customer.CustomerID
	and Customer.Company_Name In (Select CustomerName COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpCust)  
	and ServiceInvoiceDetail.SpareCode In (Select ItemCode COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpItem)  
	and ServiceInvoiceDetail.SpareCode = Items.Product_Code
	and Items.UOM *= UOM.UOM
group by
	Customer.Company_Name,
	ServiceInvoiceabstract.Documentid, 
	Serviceinvoiceabstract.ServiceInvoiceID, 
	ServiceInvoiceabstract.ServiceInvoiceDate, 
	ServiceInvoiceDetail.SpareCode,
        Issuedetail.SerialNo,
	Items.ProductName, 
	UOM.Description, 
	ServiceInvoicedetail.Price ,
	ServiceInvoicedetail.Batch_Number,
	ServiceInvoiceAbstract.Customerid,
	VoucherPrefix.Prefix,
	ServiceInvoiceabstract.DocReference
--	Invoicedetail.Batch_code
having 
	((sum(ServiceInvoiceDetail.Netvalue) - (abs(sum(isnull(lstpayable,0))) + abs(sum(isnull(cstpayable,0)))) - (sum(Price * ServiceInvoiceDetail.Quantity) * max(ServiceInvoiceDetail.Tax_SufferedPercentage) / 100)) - (sum(IssueDetail.PurchasePrice))) <= 0

Select * from #LowMarginTemp

Drop table #tmpItem
Drop table #tmpCust
Drop table #LowMarginTemp
