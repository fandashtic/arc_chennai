CREATE Procedure spr_list_Credit_Period
( 
@From_Date DateTime, 
@To_Date DateTime
 )
AS

Declare @DAYS NVarchar(50)
Set @DAYS = dbo.LookupDictionaryItem(N'Days', Default) 


Select 
BillAbstract.DocumentID,
"Bill Number" = VoucherPrefix.Prefix + CAST(BillAbstract.DocumentID AS nVARCHAR),
"Invoice Number" = BillAbstract.InvoiceReference, 
"INVOICE DATE" = CASE WHEN ISNULL(RECDINVOICEID, N'') = N'' THEN BILLABSTRACT.BILLDATE
 ELSE
 (SELECT INVOICEDATE FROM INVOICEABSTRACTRECEIVED
 WHERE  BILLABSTRACT.GRNID = GRNABSTRACT.GRNID
 AND PAYMENTDETAIL.DOCUMENTID = BILLABSTRACT.BILLID 
 AND GRNABSTRACT.RECDINVOICEID = INVOICEABSTRACTRECEIVED.INVOICEID
 AND PAYMENTS.DOCUMENTID = PAYMENTDETAIL.PAYMENTID )
 END,
"Invoice Amount" = BillAbstract.Value, + TaxAmount + AdjustmentAmount, 
"Stock Received On" = GRNAbstract.GRNDate, 
"Stock Transit Time" =
Case When Isnull(RecdInvoiceID, N'') <> N'' Then 
(Select Cast(DateDiff(Day, InvoiceAbstractReceived.InvoiceDate, GRNAbstract.GRNDate) as nVarchar) + ' '+ @DAYS  
from InvoiceAbstractReceived
Where  BillAbstract.GRNID = GRNAbstract.GRNID
and PaymentDetail.DocumentID = BillAbstract.BillID 
and GRNAbstract.RecdInvoiceID = InvoiceAbstractReceived.InvoiceID
and Payments.DocumentID = PaymentDetail.PaymentID)
Else Cast(DateDiff(Day, GRNAbstract.GRNDate, BillAbstract.BillDate) as nVarchar) + ' '+ @DAYS  End ,
"Cheque Number" = Payments.Cheque_Number,
"Cheque Date" = Payments.Cheque_Date, 
"Cheque Amount" = 
Case PaymentMode When 1  Then Payments.Value Else 0 End,
"Encashed on date" = Payments.DocumentDate,
"Cheque transit time" =
Cast(Datediff(day,Payments.DocumentDate,Payments.Cheque_Date) as nVarchar) + ' '+ @DAYS,
"Effective credit period" =
Cast(DateDiff(day, GRNAbstract.GRNDate, Payments.DocumentDate) as nVarchar) + ' ' + @DAYS
From BillAbstract, Payments, GRNAbstract, PaymentDetail, VoucherPrefix
Where BillAbstract.GRNID = GRNAbstract.GRNID
and PaymentDetail.DocumentID = BillAbstract.BillID 
and VoucherPrefix.TranID = N'BILL'
and Payments.DocumentDate Between @From_Date and @To_Date
and Payments.DocumentID = PaymentDetail.PaymentID
and PaymentDetail.DocumentType = 4
And (IsNull(Payments.Status,0) & 64) = 0 and (IsNull(Payments.Status,0) <> 192)
And IsNull(Payments.Status,0) <> 128
Order by BillAbstract.DocumentID


