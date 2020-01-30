CREATE Procedure Spr_list_Overdue_Collections_detail(@docid integer=1,@Fromdate datetime,@Todate datetime)  
as  
 Select InvoiceAbstract.InvoiceID,  
 "InvoiceID" = Case IsNULL(InvoiceAbstract.GSTFlag ,0) when 0 then 
 VoucherPrefix.Prefix+ cast(InvoiceAbstract.DocumentID as nvarchar) else IsNULL(InvoiceAbstract.GSTFullDocID,'')
                End,  
 "Doc Reference"=Invoiceabstract.DocReference,"Invoice Date" = InvoiceAbstract.InvoiceDate,  
 "Payment Date" = InvoiceAbstract.PaymentDate,"Customer" = Customer.Company_Name,  
 "Amount" = Sum(InvoiceAbstract.NetValue),  
 "OutStanding Amount" = case InvoiceAbstract.InvoiceType  
   when 1 then Sum(InvoiceAbstract.Balance)  
   when 3 then Sum(InvoiceAbstract.Balance)  
   when 2 then Sum(InvoiceAbstract.Balance)  
   when 4 then 0 - Sum(InvoiceAbstract.Balance)  
   when 5 then 0 - Sum(InvoiceAbstract.Balance)  
   when 6 then 0 - Sum(InvoiceAbstract.Balance)  
   end,  
 "Due Days" = DateDiff(dd, InvoiceAbstract.InvoiceDate, @Todate),  
 "OverDue Days" = DateDiff(dd, InvoiceAbstract.PaymentDate, @Todate)  
 From Invoiceabstract,Customer, VoucherPrefix  
 Where Invoiceabstract.Invoiceid in  
 ( Select  distinct(Collectiondetail.Documentid)   
  From  Collectiondetail,Collections,Invoiceabstract  Where  
  Invoiceabstract.Paymentdate < Collectiondetail.PaymentDate and   
  Invoiceabstract.Balance > 0 and  
  Collectiondetail.DocumentType In (4, 6) and  
  Collectiondetail.Collectionid =Collections.Documentid  
  and Collections.Documentdate between @Fromdate and @todate and  
  Collections.Customerid Is Not Null and  
  (IsNull(Collections.Status, 0) & 192) = 0 And   
  (IsNull(Collections.Status, 0) & 64) = 0   
  Union  
  SELECT distinct(InvoiceID) FROM InvoiceAbstract    
   WHERE PaymentDate <= getdate() and    
   InvoiceDate between @FromDate and @ToDate  
   and Balance <> 0 and    
   InvoiceType in (1,2,3) and   
   Isnull(PaymentDetails,0) = 0 and   
   Isnull(Status,0) & 128 = 0    
  )  
 and VoucherPrefix.TranID = 'INVOICE' and  
 InvoiceAbstract.CustomerID = Customer.CustomerID   
 and Invoiceabstract.Balance >0  
 and Invoiceabstract.Balance+Invoiceabstract.AdjustmentValue >0  
 --Criteria for Overdue Added.  
 and DateDiff(dd, InvoiceAbstract.PaymentDate,@Todate ) >= 0  
 Group by InvoiceAbstract.InvoiceID,VoucherPrefix.Prefix,InvoiceAbstract.DocumentID,  
 Invoiceabstract.DocReference,InvoiceAbstract.InvoiceDate,InvoiceAbstract.PaymentDate,  
 Customer.Company_Name,InvoiceAbstract.InvoiceType,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID          
 order by  Sum(Invoiceabstract.Balance) desc  

