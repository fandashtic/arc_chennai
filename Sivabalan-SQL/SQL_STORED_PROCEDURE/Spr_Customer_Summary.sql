Create Procedure Spr_Customer_Summary (@Beat nvarchar(255), @CustomerID nvarchar(2550),      
@FromDate DateTime, @ToDate DateTime)          
AS          
          
Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)        
      
Create table #tmpCus(Customer nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
      
if @CustomerID = '%'         
   Insert into #tmpCus select CustomerID from Customer   
   Where Customercategory not in (4,5)      
Else        
   Insert into #tmpCus select * from dbo.sp_SplitIn2Rows(@CustomerID, @Delimeter)        
      
      
Declare @CurrentDate DateTime          
Set @CurrentDate = DateAdd(DD, -1, @FromDate)          
          
If @Beat = '%'          
Begin          
Select Distinct c.CustomerID, "Customer Name" = Company_Name,           
  "Opening Amount" = dbo.sp_acc_getaccountbalance(c.AccountID, @CurrentDate),           
  "Invoice Amount" = (Select Sum(Case  When InvoiceType In (1, 3, 2) Then       
    NetValue -- IsNull(Freight, 0)          
    Else 0 End) From InvoiceAbstract Where CustomerID = c.CustomerID And       
    InvoiceDate Between @FromDate And @ToDate And IsNull(Status, 0) & 192 = 0),           
  "Sales Return Amount" = (Select Sum(Case InvoiceType When 4       
    Then -1 * (NetValue) -- IsNull(Freight, 0)) 
    Else 0 End)       
  From InvoiceAbstract       
  Where CustomerID = c.CustomerID And InvoiceDate Between          
    @FromDate And @ToDate And IsNull(Status, 0) & 192 = 0),           
  "Collections" = (Select Sum(Value) From Collections  Where           
    DocumentDate Between @FromDate And @ToDate And CustomerID = c.CustomerId And           
    IsNull(Status, 0) & 192  = 0),       
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
--Like @CustomerID       
End          
Else          
Begin          
Select Distinct c.CustomerID, "Customer Name" = Company_Name,           
"Opening Amount" = dbo.sp_acc_getaccountbalance(c.AccountID, @CurrentDate),           
"Invoice Amount" = (Select Sum(Case When InvoiceType In (1, 3) Then NetValue -- IsNull(Freight, 0)          
Else 0 End) From InvoiceAbstract Where CustomerID = c.CustomerID And InvoiceDate Between          
@FromDate And @ToDate And IsNull(Status, 0) & 192 = 0),           
"Sales Return Amount" = (Select Sum(Case InvoiceType When 4 Then -1 * (NetValue) -- IsNull(Freight, 0))          
Else 0 End) From InvoiceAbstract Where CustomerID = c.CustomerID And InvoiceDate Between          
@FromDate And @ToDate And IsNull(Status, 0) & 192 = 0),           
"Collections" = (Select Sum(Value) From Collections Where           
DocumentDate Between @FromDate And @ToDate And CustomerID = c.CustomerId And           
IsNull(Status, 0) & 192 = 0)          
, "Debit Note" = (Select Sum(NoteValue) From DebitNote Where DocumentDate Between           
@FromDate And @ToDate And CustomerID = c.CustomerID And CustomerID Is Not Null
And IsNull(Status, 0) & 192 = 0),           
"Credit Note" = (Select Sum(NoteValue) From CreditNote Where DocumentDate Between           
@FromDate And @ToDate And CustomerID = c.CustomerID And CustomerID Is Not Null
And IsNull(Status, 0) & 192 = 0),          
"Balance" = dbo.sp_acc_getaccountbalance(AccountID, @ToDate) From           
Customer c, Beat b, Beat_Salesman bs Where c.CustomerId = bs.CustomerID And           
bs.BeatID = b.BeatID And b.[Description] Like @Beat And       
c.CustomerID In (Select * From #tmpCus)   
--Like @CustomerID       
      
End          
      
drop table #tmpCus      
    
  


