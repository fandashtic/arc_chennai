CREATE procedure spr_ser_get_channelwisesales_details(      
	@channel varchar(50),
        @FromDate datetime,      
        @ToDate datetime)      
as  
DECLARE @Prefix nvarchar(50)  
DECLARE @Prefix1 nvarchar(50)  
Declare @Chennel1 integer

select @Chennel1 = customer.channeltype from 
customer,Customer_Channel where ChannelDesc = @channel
and Customer_Channel.ChannelType = Customer.ChannelType  

CREATE Table #ChennelTemp(CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Customer Name] nvarchar(150)COLLATE SQL_Latin1_General_CP1_CI_AS,
InvoiceID nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Invoice Date] datetime,[Total Sales] decimal(18,6))

Insert into #ChennelTemp
	--SELECT @Prefix = Prefix From VoucherPrefix Where TranID = 'INVOICE'  
	select customer.customerid, "Customer Name" = customer.company_name,
	"InvoiceID" = VoucherPrefix.Prefix + cast (InvoiceAbstract.DocumentID as varchar),
	"Invoice Date" = invoiceabstract.invoicedate,
	"Total Sales (%c)" =
	case invoicetype
	when 4 then
	 0-invoiceabstract.NetValue-IsNull(invoiceabstract.freight,0)
	else
	 invoiceabstract.NetValue-IsNull(invoiceabstract.freight,0)
	END
	from customer,invoiceabstract,VoucherPrefix where invoiceabstract.customerid=customer.customerid and
	IsNull(customer.channeltype, 0)= IsNull(@Chennel1, 0) and      
	invoiceabstract.invoicedate between @FromDate and @ToDate and      
	invoiceabstract.InvoiceType in (1, 3,4) AND( (Status & 128) = 0) and
	VoucherPrefix.tranid = 'INVOICE'       
  
Insert into #ChennelTemp
	--SELECT @Prefix1 = Prefix From VoucherPrefix Where TranID = 'SERVICEINVOICE'  
	select customer.customerid,"Customer Name" = customer.company_name,
	"InvoiceID" = VoucherPrefix.Prefix + cast (ServiceInvoiceAbstract.DocumentID as varchar),
	"Invoice Date" = serviceinvoiceabstract.serviceinvoicedate,      
	"Total Sales (%c)" =  Sum(Isnull(serviceinvoicedetail.NetValue,0)) 

	from customer,Serviceinvoiceabstract,Serviceinvoicedetail,VoucherPrefix,items where serviceinvoiceabstract.customerid=customer.customerid and       
	IsNull(customer.channeltype, 0)= IsNull(@Chennel1, 0) and      
	serviceinvoiceabstract.serviceinvoicedate between @FromDate and @ToDate and      
	Serviceinvoiceabstract.serviceinvoiceid  = serviceinvoicedetail.serviceinvoiceid
	And Isnull(serviceinvoicedetail.sparecode,'') <> '' And
        Serviceinvoicedetail.sparecode = items.product_code And
	serviceinvoiceabstract.serviceInvoiceType in (1) AND
	Isnull(Status,0) & 192 = 0 and   
	VoucherPrefix.tranid = 'SERVICEINVOICE'
	Group by customer.customerid,customer.company_name,VoucherPrefix.Prefix + cast (ServiceInvoiceAbstract.DocumentID as varchar),
	serviceinvoiceabstract.serviceinvoicedate	

Select * from #ChennelTemp order by [Invoice Date]
Drop table #ChennelTemp

