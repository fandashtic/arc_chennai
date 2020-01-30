CREATE procedure sp_ViewServiceInvoice
(
@FromDate datetime,
@ToDate datetime,
@ServiceType nvarchar(50)
)
As
BEGIN
SELECT DocumentId as 'Invoice No' ,SelectReceipient as 'Receipient Name',TransactionDate as 'Transaction Date',Cast(TotalNetAmount as decimal(18,2)) As 'Net Amount',CASE WHEN ServiceType = 'Inward' THEN 'Input' ELSE 'Output' End as ServiceType,CASE WHEN Status = 0 THEN 'Open' ELSE 'Cancel' end as Status,InvoiceId as 'Invoice ID',ServiceInvoiceNo,Cast(Balance as decimal(18,2)) as Balance
FROM ServiceAbstract
WHERE TransactionDate BETWEEN @FromDate AND @ToDate AND ServiceType=@ServiceType order by InvoiceId desc
END
