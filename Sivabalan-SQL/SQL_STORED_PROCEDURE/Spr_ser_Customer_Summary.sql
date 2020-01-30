
Create Procedure Spr_ser_Customer_Summary (@Beat nvarchar(255), @CustomerID nvarchar(2550),      
@FromDate DateTime, @ToDate DateTime)          

AS          
          
Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)        
      
Create table #tmpCus(Customer nvarchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS)        
      
If @CustomerID = '%'         
	Insert into #tmpCus select CustomerID from Customer Where Customercategory not in (4,5)
Else        
	Insert into #tmpCus select * from dbo.sp_SplitIn2Rows(@CustomerID, @Delimeter)        
     
Declare @CurrentDate DateTime          
Set @CurrentDate = DateAdd(DD, -1, @FromDate)
          
If @Beat = '%'          
Begin          

Select c.CustomerID, "Customer Name" = Company_Name,           

"Opening Amount" = dbo.sp_acc_getaccountbalance(c.AccountID, @CurrentDate),           

"Invoice Amount" = (
IsNull((Select Sum(Case  When InvoiceType In (1, 3, 2) Then       
IsNull(NetValue,0) - IsNull(Freight, 0) Else 0 End) From 
InvoiceAbstract Where CustomerID = c.CustomerID 
And InvoiceDate Between @FromDate And @ToDate 
And IsNull(Status, 0) & 192 = 0),0)
+
IsNull((Select Sum(IsNull(NetValue,0) - IsNull(Freight, 0)) From 
ServiceInvoiceAbstract  Where CustomerID = c.CustomerID 
And ServiceInvoiceDate Between @FromDate And @ToDate 
And IsNull(Status, 0) & 192 = 0 and IsNull(ServiceInvoiceType,0) = 1),0)
),           

"Sales Return Amount" = (Select Sum(Case InvoiceType When 4       
Then -1 * (NetValue - IsNull(Freight, 0)) Else 0 End)       
From InvoiceAbstract Where CustomerID = c.CustomerID 
And InvoiceDate Between @FromDate And @ToDate And IsNull(Status, 0) & 192 = 0),           

"Collections" = (Select Sum(Value) From Collections  Where           
DocumentDate Between @FromDate And @ToDate And CustomerID = c.CustomerId 
And IsNull(Status, 0) & 192  = 0),       

"Debit Note" = (Select Sum(NoteValue) From DebitNote Where DocumentDate Between           
@FromDate And @ToDate And CustomerID = c.CustomerID And CustomerID Is Not Null
And IsNull(Status, 0) & 192 = 0),

"Credit Note" = (Select Sum(NoteValue) From CreditNote Where DocumentDate Between           
@FromDate And @ToDate And CustomerID = c.CustomerID And CustomerID Is Not Null
And IsNull(Status, 0) & 192 = 0),          

"Balance" = dbo.sp_acc_getaccountbalance(AccountID, @ToDate)       

From Customer c Full Join Beat_Salesman bs On c.CustomerID = bs.CustomerID Full Join       
Beat b On bs.BeatID = b.BeatID       
Where c.CustomerID In (Select * From #tmpCus)      

End          

Else          

Begin          

Select c.CustomerID, "Customer Name" = Company_Name,           

"Opening Amount" = dbo.sp_acc_getaccountbalance(c.AccountID, @CurrentDate),           

"Invoice Amount" = (
IsNull((Select Sum(Case When InvoiceType In (1, 3) Then NetValue - IsNull(Freight, 0)          
Else 0 End) From InvoiceAbstract Where CustomerID = C.CustomerID And InvoiceDate Between          
@FromDate And @ToDate And IsNull(Status, 0) & 192 = 0),0)
+
IsNull((Select Sum(IsNull(NetValue,0) - IsNull(Freight, 0)) From ServiceInvoiceAbstract 
Where CustomerID = c.CustomerID And ServiceInvoiceDate Between @FromDate And @ToDate 
And IsNull(Status, 0) & 192 = 0 and IsNull(ServiceInvoiceType,0) = 1),0)
),           

"Sales Return Amount" = (Select Sum(Case InvoiceType When 4 Then -1 * (IsNull(NetValue,0) - IsNull(Freight, 0))          
Else 0 End) From InvoiceAbstract Where CustomerID = c.CustomerID And InvoiceDate Between          
@FromDate And @ToDate And IsNull(Status, 0) & 192 = 0),           

"Collections" = (Select Sum(Value) From Collections Where           
DocumentDate Between @FromDate And @ToDate And CustomerID = c.CustomerId And           
IsNull(Status, 0) & 192 = 0), 

"Debit Note" = (Select Sum(NoteValue) From DebitNote Where DocumentDate Between           
@FromDate And @ToDate And CustomerID = c.CustomerID And CustomerID Is Not Null
And IsNull(Status, 0) & 192 = 0),           

"Credit Note" = (Select Sum(NoteValue) From CreditNote Where DocumentDate Between           
@FromDate And @ToDate And CustomerID = c.CustomerID And CustomerID Is Not Null
And IsNull(Status, 0) & 192 = 0),          

"Balance" = dbo.sp_acc_getaccountbalance(AccountID, @ToDate) 

From Customer c, Beat b, Beat_Salesman bs Where c.CustomerId = bs.CustomerID 
And bs.BeatID = b.BeatID And b.[Description] Like @Beat 
And C.CustomerID In (Select * From #tmpCus)   
      
End          
     
Drop table #tmpCus      

