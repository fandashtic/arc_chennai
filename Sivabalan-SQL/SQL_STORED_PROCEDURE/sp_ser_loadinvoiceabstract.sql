CREATE procedure sp_ser_loadinvoiceabstract(@FromDate Datetime,@ToDate Datetime,
@Mode Int,@CUSTOMER NVARCHAR(15) = '')
as
Declare @Prefix nvarchar(15)
select @Prefix = Prefix from VoucherPrefix
where TranID = 'SERVICEINVOICE'

If @Mode = 1 -- Close 1 -- View 2
Begin
	select ServiceInvoiceID,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),ServiceInvoiceDate,
	Company_Name,'Status'=IsNull(Status,0), DocReference,
	'NetValue'=IsNull(NetValue,0),'Balance'=IsNull(Balance,0)
	from ServiceInvoiceAbstract,Customer
	Where dbo.stripdatefromtime(ServiceInvoiceDate) between @FromDate and @ToDate
	and (IsNull(Status, 0) & 192) = 0 
	and ServiceInvoiceAbstract.CustomerID = Customer.CustomerID
	and ServiceInvoiceAbstract.CustomerID LIKE @CUSTOMER
	order by Company_Name, ServiceInvoiceID
End
Else If @Mode = 2
Begin
	select ServiceInvoiceID,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),ServiceInvoiceDate,
	Company_Name,'Status'=IsNull(Status,0), DocReference,
	'NetValue'=IsNull(NetValue,0),'Balance'=IsNull(Balance,0)
	from ServiceInvoiceAbstract,Customer
	Where dbo.stripdatefromtime(ServiceInvoiceDate) between @FromDate and @ToDate
	and ServiceInvoiceAbstract.CustomerID = Customer.CustomerID
	and ServiceInvoiceAbstract.CustomerID LIKE @CUSTOMER
	order by Company_Name, ServiceInvoiceID
End




