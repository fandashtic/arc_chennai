CREATE Procedure spr_list_Invoice_Summary_Report (@From_Date DateTime, @To_Date DateTime)  
As
Declare @SALESCREATED As NVarchar(50)
Declare @SALESCANCELLEDORAMENDED As NVarchar(50)
Set @SALESCREATED = dbo.LookupDictionaryItem(N'Sales Created',Default)
Set @SALESCANCELLEDORAMENDED = dbo.LookupDictionaryItem(N'Sales Cancelled/Amended',Default)

SELECT 1,"Activity " = @SALESCREATED,"Invoice Value (%c)" = (Select Isnull(sum(Amount),0) + isnull(sum(Freight),0)
from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @From_Date  and @To_Date  
And InvoiceAbstract.Status & 128 = 0 
and InvoiceAbstract.InvoiceType in (1,2,3)),  
"Sales Return Damages(%c)" = (Select ISNULL(sum(Amount),0) from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @From_Date and @To_Date  
And InvoiceAbstract.Status & 128 = 0   
and ((InvoiceAbstract.Status & 32 <> 0  
and InvoiceAbstract.InvoiceType=4) or (InvoiceAbstract.InvoiceType=6))),  
"Sales Return Saleable(%c)" = (Select ISNULL(sum(Amount),0) from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and invoicedate between @From_Date and @To_Date  
And InvoiceAbstract.Status & 128 = 0   
and ((InvoiceAbstract.Status & 32 = 0  
and InvoiceAbstract.InvoiceType=4) or (InvoiceAbstract.InvoiceType=5)))
union
Select 2,@SALESCANCELLEDORAMENDED, (Select Isnull(sum(Amount),0)
from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and 
(
((CancelDate between @From_Date and @To_Date) and InvoiceAbstract.Status & 64 = 64)
      or 
((InvoiceDate between @From_Date and @To_Date) and InvoiceAbstract.Status & 128 = 128 And InvoiceAbstract.Status & 64 <> 64)
) 
and InvoiceAbstract.InvoiceType in (1,2,3)),
(Select ISNULL(sum(Amount),0) from invoicedetail,InvoiceAbstract  
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID   
and CancelDate between @From_Date and @To_Date   
and InvoiceAbstract.Status & 64 = 64  
and ((InvoiceAbstract.Status & 32 <> 0  
and InvoiceAbstract.InvoiceType=4) or (InvoiceAbstract.InvoiceType=6))),  

(Select ISNULL(sum(Amount),0) from invoicedetail,InvoiceAbstract
where invoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID
and CancelDate between @From_Date and @To_Date  
and InvoiceAbstract.Status & 64 = 64  
and ((InvoiceAbstract.Status & 32 = 0  
and InvoiceAbstract.InvoiceType=4) or (InvoiceAbstract.InvoiceType=5)))  



