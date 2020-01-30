CREATE Procedure spr_List_SalesReturnAdjustment (@FROMDATE datetime,            
       @TODATE datetime)        
As        
Declare @CreditNote nvarchar(50)        
Declare @RetailSalesReturn nvarchar(50)        
        
Set @CreditNote = 'Credit Note'        
Set @RetailSalesReturn = 'Retail Sales Return'        
    
Declare @Delimeter as Char(1)      
Declare @Invoice as Int        
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
        
Select @CreditNote, "DocumentType" = @CreditNote, "Total Value" = IsNull(Sum(CDetail.AdjustedAmount),0),         
 "No. of Documents" = Count(CAbstract.DocumentID) From #Temp1, InvoiceAbstract IAbstract,   
 Collections CAbstract, CollectionDetail CDetail Where (IsNull(IAbstract.Status,0) & 192) = 0   
 And IAbstract.InvoiceID = #Temp1.Invoice And IAbstract.InvoiceType = 2   
 And CAbstract.DocumentID = CDetail.CollectionID and CDetail.DocumentType = 2   
 And CDetail.AdjustedAmount <> 0 And CAbstract.DocumentID = #Temp1.Payment 
 And IAbstract.InvoiceDate Between @FromDate And @ToDate      
   
Union        
  
Select @RetailSalesReturn, "DocumentType" = @RetailSalesReturn, "Total Value" =   
 IsNull(Sum(CDetail.AdjustedAmount),0), "No. of Documents" = Count(CAbstract.DocumentID) From   
 #Temp1, InvoiceAbstract IAbstract, Collections CAbstract, CollectionDetail CDetail   
 Where (IsNull(IAbstract.Status,0) & 192) = 0 And IAbstract.InvoiceID = #Temp1.Invoice And   
 IAbstract.InvoiceType = 2 And CAbstract.DocumentID = CDetail.CollectionID and   
 CDetail.DocumentType = 7 And CAbstract.DocumentID = #Temp1.Payment And   
 CDetail.AdjustedAmount <> 0 And IAbstract.InvoiceDate Between @FromDate And @ToDate      
      
Drop Table #Temp1    
  



