CREATE Procedure spr_List_SalesReturnAdjustmentDetail(@Type nvarchar(50),       
 @FROMDATE datetime, @TODATE datetime)      
As      
  
Declare @Delimeter as Char(1)        
Declare @Invoice as int  
Declare @Payment as nvarchar(50)  
Set @Delimeter = ','  

Create Table #Temp1 (Invoice int, Payment int)  
  
Declare PaymentCursor Cursor For  
 Select InvoiceID, PaymentDetails From InvoiceAbstract IAbstract Where   
 (IsNull(IAbstract.Status,0) & 192) = 0 and IAbstract.InvoiceType = 2   
  And IAbstract.PaymentMode = 1 And IAbstract.InvoiceDate Between @FromDate And @ToDate  
  
Open PaymentCursor  
Fetch Next From PaymentCursor Into @Invoice, @Payment  
  
While @@Fetch_Status = 0  
Begin  
 Insert Into #Temp1 Select @Invoice, * from dbo.sp_SplitIn2Rows(@Payment,@Delimeter)  
 Fetch Next From PaymentCursor Into @Invoice, @Payment  
End  
  
Close PaymentCursor  
DeAllocate PaymentCursor  
  
If @Type = 'Credit Note'      
Begin      
 Select 1,"Doc Number" = CreditNote.DocumentReference, "Doc Date" = CreditNote.DocumentDate,       
  "CustomerName" = Customer.Company_Name, "Value" = CreditNote.NoteValue,      
  "Adjustment Date" = IAbstract.InvoiceDate, "AdjustedAmount" = CDetail.AdjustedAmount,       
  "Adjustment InvoiceNo" = (Select Prefix from voucherprefix Where TranId = 'RETAIL INVOICE')     
  +  Cast(IAbstract.DocumentID As nvarchar), "Adjusted CollectionNo" = CAbstract.FullDocID      
 From #Temp1, InvoiceAbstract IAbstract, CreditNote, Customer, Collections CAbstract, 
 CollectionDetail CDetail Where (IsNull(IAbstract.Status,0) & 192) = 0 And IAbstract.InvoiceID = 
 #Temp1.Invoice And IAbstract.InvoiceType = 2 And CDetail.AdjustedAmount <> 0
 And CAbstract.DocumentID = CDetail.CollectionID and CDetail.DocumentType = 2 
 And IAbstract.CustomerID = Customer.CustomerID And CDetail.DocumentID = CreditNote.DocumentID 
 And CAbstract.DocumentID = #Temp1.Payment And IAbstract.InvoiceDate Between @FromDate And @ToDate      
End      
Else if @Type = 'Retail Sales Return'      
Begin      
 Select 1,"Doc Number" = (Select Prefix from voucherprefix Where TranId = 'RETAIL INVOICE')     
  +  Cast((Select IA.InvoiceID from InvoiceAbstract IA Where IA.InvoiceId = 
  Substring(CDetail.OriginalID,2,len(CDetail.OriginalID))) As nvarchar), "Doc Date" = 
 (Select IA.InvoiceDate from InvoiceAbstract IA Where IA.InvoiceId = 
  Substring(CDetail.OriginalID,2,len(CDetail.OriginalID))),       
  "CustomerName" = Customer.Company_Name, "Value" = (Select IA.NetValue from InvoiceAbstract IA 
  Where IA.InvoiceId = Substring(CDetail.OriginalID,2,len(CDetail.OriginalID))),      
  "Adjustment Date" = IAbstract.InvoiceDate, "AdjustedAmount" = CDetail.AdjustedAmount,       
  "Adjustment InvoiceNo" = (Select Prefix from voucherprefix Where TranId = 'RETAIL INVOICE')     
  +  Cast(IAbstract.DocumentID As nvarchar), "Adjusted CollectionNo" = CAbstract.FullDocID      
 From #Temp1, InvoiceAbstract IAbstract, Customer, Collections CAbstract, 
 CollectionDetail CDetail Where (IsNull(IAbstract.Status,0) & 192) = 0 
 And IAbstract.InvoiceID = #Temp1.Invoice And IAbstract.InvoiceType = 2 
 And CAbstract.DocumentID = CDetail.CollectionID and CDetail.DocumentType = 7 
 And IAbstract.CustomerID = Customer.CustomerID And CDetail.AdjustedAmount <> 0 
 And CAbstract.DocumentID = #Temp1.Payment And IAbstract.InvoiceDate Between @FromDate And @ToDate 
End      

 Drop Table #Temp1  
  



