
Create Procedure spr_list_PromptPaymentIncentive_PIDILITE(@Customer nVarchar(4000))  
As  
Declare @Delimeter As Char(1)      
Set @Delimeter=Char(15)      
    
Create Table #tmpCust(CustomerId nVarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)    
  
If @Customer = N'%'    
   Insert Into #tmpCust Select CustomerId From Customer    
Else    
   Insert Into #tmpCust Select * From dbo.sp_SplitIn2Rows(@Customer,@Delimeter)    
  
Select  Ia.CustomerId,"Customer ID" = Ia.CustomerId,  
"Customer Name" = C.Company_Name,  
"Invoice Id" = (Select Prefix From VoucherPrefix Where TranId = N'INVOICE' ) + Cast(Ia.DocumentID As nVarchar),        
"Invoice Date" = Ia.InvoiceDate,   
"Invoice Amount" = Ia.NetValue,        
"Balance" =  Ia.Balance,         
"Credit Term" = (Select Description From CreditTerm Where CreditId = Ia.CreditTerm) ,  
"Due Days" =  DateDiff(dd, Ia.InvoiceDate, GetDate()),         
"Over Due Days" = (Case When PaymentDate < GetDate() Then DateDiff(dd,Ia.PaymentDate,GetDate()) Else 0 End),  
"Payment Date" = PaymentDate,   
"Eligible" = (Case When dbo.StripDateFromTime(PaymentDate) >= dbo.StripDateFromTime(GetDate()) Then N'Yes' Else N'No' End)  
From InvoiceAbstract Ia,Customer C 
Where Ia.CustomerId = C.CustomerId   
And Ia.CustomerID in (Select customerId From #tmpCust)  
And Ia.Status & 128 = 0 And        
Ia.InvoiceType in (1, 3) And        
Ia.Balance > 0   
Order By C.Company_Name, Ia.InvoiceId  
  
  
Drop Table #tmpCust  
  
