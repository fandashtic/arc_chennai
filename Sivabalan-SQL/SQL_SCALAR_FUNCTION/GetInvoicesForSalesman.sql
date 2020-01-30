CREATE FUNCTION GetInvoicesForSalesman(@SALESMAN int, @FROMDATE datetime, @TODATE datetime, @FROMNO nvarchar(50), @TONO nvarchar(50))
RETURNS nvarchar(4000)
begin
DECLARE @Invoices nvarchar(4000)
DECLARE @PREFIX nvarchar(15)
DECLARE @INVOICEID nvarchar(50)

IF @FROMNO = '%' OR @TONO = '%'
BEGIN
	Select @PREFIX = Prefix From VoucherPrefix Where TranID = 'INVOICE'  
	DECLARE GetInvoiceID CURSOR STATIC FOR  
	Select  @PREFIX + cast(DocumentID as nvarchar)  
	From InvoiceAbstract  
	Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And  
	 (InvoiceAbstract.Status & 128) = 0 And   
	 InvoiceAbstract.InvoiceType in (1, 3) And  
	 InvoiceAbstract.SalesmanID = @SALESMAN
	Order BY InvoiceAbstract.DocumentID  
END
ELSE
BEGIN
	Select @PREFIX = Prefix From VoucherPrefix Where TranID = 'INVOICE'  
	DECLARE GetInvoiceID CURSOR STATIC FOR  
	Select  @PREFIX + cast(DocumentID as nvarchar)  
	From InvoiceAbstract  
	Where InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And  
	 (InvoiceAbstract.Status & 128) = 0 And   
	 InvoiceAbstract.InvoiceType in (1, 3) And  
	 InvoiceAbstract.SalesmanID = @SALESMAN And  
	 InvoiceAbstract.DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)  
	Order BY InvoiceAbstract.DocumentID  
END

Open GetInvoiceID
Fetch From GetInvoiceID Into @INVOICEID
While @@FETCH_STATUS = 0
BEGIN
	Set @Invoices = IsNull(@Invoices, '') + ',' + @INVOICEID
	Fetch Next From GetInvoiceID Into @INVOICEID
END
Close GetInvoiceID
Deallocate GetInvoiceID
RETURN Substring(@Invoices, 2, 4000)
end

