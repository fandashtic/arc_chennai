CREATE procedure sp_InvoiceHistory_Abstract_DataExport (@FromDate as datetime,@ToDate as DateTime,@SalesmanID as nvarchar(255))
AS 
Select IA.InvoiceID as SO_NO
,IA.CustomerID as CUST_CD
,null as DELIVERY_DATE
,null as INV_NO
,IA.NetValue as NET_AMOUNT
,null as PO_NO
,null as REMARKS
,IA.SalesmanID as SLSMAN_CD
,IA.InvoiceDate as TXN_DATE
,'V' as	TXN_STATUS
,'Y' as UPLOAD_STATUS 
,IA.PaymentMode as TYPE
,null as  SCHEME_CD
,IA.DiscountPercentage as ORD_DISC_PERCENT 
from invoiceabstract IA 
where  IA.InvoiceDate BETWEEN @FROMDATE AND @TODATE 
	and  IA.SalesmanID in (select  * from dbo.sp_SplitIn2Rows(@SalesmanID, ','))
	and (isnull(IA.Status,0) & 128 ) = 0 
	and (isnull(IA.Status,0) & 64 ) = 0 
	and IA.InvoiceType in (1,3)
	
