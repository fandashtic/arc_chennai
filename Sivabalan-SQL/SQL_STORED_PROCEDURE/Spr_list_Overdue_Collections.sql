CREATE Procedure Spr_list_Overdue_Collections(@Fromdate datetime,@Todate datetime)    
  as    
  Select '1',"Number of Invoices"= Count(Invoiceabstract.Invoiceid),    
 "Value"=Sum(Invoiceabstract.Balance)    
 From Invoiceabstract    
 Where Invoiceabstract.Invoiceid in    
  
  (  
  Select distinct(Collectiondetail.Documentid)     
  From  Collectiondetail,Collections,Invoiceabstract   
  Where Invoiceabstract.Paymentdate < Collectiondetail.PaymentDate   
  and Invoiceabstract.Balance > 0 and    
  Collectiondetail.DocumentType In (4, 6) and    
  Collectiondetail.Collectionid =Collections.Documentid and   
  Collections.Documentdate between @Fromdate and @todate and    
  Collections.Customerid Is Not Null and    
  (IsNull(Collections.Status, 0) & 192) = 0 And     
  (IsNull(Collections.Status, 0) & 64) = 0 
  Union
	SELECT distinct(InvoiceID) FROM InvoiceAbstract  
  WHERE PaymentDate <= getdate() and  
  InvoiceDate between @FromDate and @ToDate and 
  Balance <> 0 and  
  InvoiceType in (1,2,3) and 
  Isnull(PaymentDetails,0) = 0 and 
  Status & 128 = 0  
  )    
  and Invoiceabstract.Balance >0    
  and Invoiceabstract.Balance+Invoiceabstract.AdjustmentValue >0    
  and DateDiff(dd, InvoiceAbstract.PaymentDate,@Todate ) >= 0 
