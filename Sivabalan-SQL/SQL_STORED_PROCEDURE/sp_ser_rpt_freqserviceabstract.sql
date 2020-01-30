CREATE Procedure sp_ser_rpt_freqserviceabstract 
(@FromDate datetime, @ToDate datetime)
as
Declare @Total as Decimal(18,6) 

Select @Total = Count(*) from ServiceInvoiceAbstract a
Inner Join ServiceInvoiceDetail d On a.ServiceInvoiceID = d.ServiceInvoiceID and d.Type = 0 and 
(0 < (Select Count(*) from ServiceInvoiceDetail b where 
b.ServiceInvoiceID = d.ServiceInvoiceID and b.Type <> 0 and 
b.TaskID not in (Select t.TaskID from ServiceInvoiceDetail t Where 
t.ServiceInvoiceID = b.ServiceInvoiceID and isnull(t.TaskType,0) = 1)))
Where (IsNull(a.Status, 0) & 192 <> 192) and 
a.ServiceInvoiceDate between @FromDate and @ToDate 


Select d.Product_Code, d.Product_Code 'Item Code', i.ProductName 'Item Name', Count(*) 'No of Service', 
Cast( ((Count(*) * 100) / @Total) as Decimal(18,6)) 'Frequency%' from ServiceInvoiceAbstract a
Inner Join ServiceInvoiceDetail d On a.ServiceInvoiceID = d.ServiceInvoiceID and d.Type = 0 and 
(0 < (Select Count(*) from ServiceInvoiceDetail b where 
b.ServiceInvoiceID = d.ServiceInvoiceID and b.Type <> 0 and 
b.TaskID not in (Select t.TaskID from ServiceInvoiceDetail t Where 
t.ServiceInvoiceID = b.ServiceInvoiceID and isnull(t.TaskType,0) = 1)))
Inner Join items i On i.Product_Code = d.Product_Code 
Where (IsNull(Status, 0) & 192 <> 192) and 
a.ServiceInvoiceDate between @FromDate and @ToDate 
Group by d.Product_Code, i.ProductName


