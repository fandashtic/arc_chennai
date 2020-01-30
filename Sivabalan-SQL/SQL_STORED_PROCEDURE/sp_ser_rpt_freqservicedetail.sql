CREATE procedure sp_ser_rpt_freqservicedetail 
(@ItemCode varchar(15), @FromDate datetime, @ToDate datetime)
as

Declare @SIPrefix as nvarchar(15) 
Declare @JCPrefix as nvarchar(15) 

Select @SIPrefix = Prefix from VoucherPrefix where TranID = 'SERVICEINVOICE'
Select @JCPrefix = Prefix from VoucherPrefix where TranID = 'JOBCARD'

Select 0, @SIPrefix + Cast(a.DocumentID as varchar(15)) 'ServiceInvoiceID', 
a.ServiceInvoiceDate 'Service Invoice Date', c.Company_Name 'Customer', 
a.DocReference 'Reference', @JCPrefix + Cast(j.DocumentID as varchar(15)) 'JobCardID'
from ServiceInvoiceAbstract a
Inner Join JobCardAbstract j on j.JobCardId = a.JobCardID 
Inner Join Customer c On c.CustomerID = a.CustomerID
Inner Join ServiceInvoiceDetail d On a.ServiceInvoiceID = d.ServiceInvoiceID and d.Type = 0 and 
(0 < (Select Count(*) from ServiceInvoiceDetail b where 
b.ServiceInvoiceID = d.ServiceInvoiceID and b.Type <> 0 and 
b.TaskID not in (Select t.TaskID from ServiceInvoiceDetail t Where 
t.ServiceInvoiceID = b.ServiceInvoiceID and isnull(t.TaskType,0) = 1)))
Where (IsNull(a.Status, 0) & 192 <> 192) and
a.ServiceInvoiceDate between @FromDate and @ToDate and
d.Product_Code like @ItemCode
Order by a.ServiceInvoiceID





