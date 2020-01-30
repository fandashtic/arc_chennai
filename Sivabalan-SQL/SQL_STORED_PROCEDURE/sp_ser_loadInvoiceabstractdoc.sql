create procedure sp_ser_loadInvoiceabstractdoc(@FromID Int,@ToID Int,
@Mode Int)
as
Declare @Prefix nvarchar(15)
select @Prefix = Prefix from VoucherPrefix
where TranID = 'SERVICEINVOICE'

If @Mode = 1 -- Close 1 -- View 2
Begin
	select ServiceInvoiceID,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),ServiceInvoiceDate,
	Company_Name, DocReference, 'Status'=IsNull(Status,0),
	'NetValue'=IsNull(NetValue,0),'Balance'=IsNull(Balance,0)
	from ServiceInvoiceAbstract,Customer
	Where DocumentID between @FromID and @ToID
	and (IsNull(Status, 0) & 192) = 0 
	and ServiceInvoiceAbstract.CustomerID = Customer.CustomerID
	order by Company_Name, ServiceInvoiceID
End
Else If @Mode = 2
Begin
	select ServiceInvoiceID,'DocumentID' = @Prefix + cast(DocumentID as nvarchar(15)),ServiceInvoiceDate,
	Company_Name, DocReference, 'Status'=IsNull(Status,0),
	'NetValue'=IsNull(NetValue,0),'Balance'=IsNull(Balance,0) 
	from ServiceInvoiceAbstract,Customer
	Where DocumentID between @FromID and @ToID
	and ServiceInvoiceAbstract.CustomerID = Customer.CustomerID
	order by Company_Name, ServiceInvoiceID
End





