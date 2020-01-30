CREATE Procedure spr_List_TCNS_CreditNoteDetail(@Type nvarchar(50),               
 @FROMDATE datetime, @TODATE datetime)              
As              
              
If @Type = 'Credit Note'              
Begin              
 Select 1,"Doc Number" = CreditNote.DocumentReference, "Doc Date" = CreditNote.DocumentDate,               
  "CustomerName" = Customer.Company_Name, "Account" = AccountsMaster.AccountName,           
  "Value" = CreditNote.NoteValue From CreditNote, Customer, AccountsMaster           
  Where (IsNull(CreditNote.Status,0) & 192) = 0              
  And CreditNote.CustomerID = Customer.CustomerID And AccountsMaster.AccountID =           
  CreditNote.AccountID And CreditNote.DocumentDate Between @FromDate And @ToDate              
End              
Else if @Type = 'Retail Sales Return'              
Begin              
 Select 1, "Doc Number" = (Select Prefix from voucherprefix Where TranId = 'SALES RETURN')           
 + Cast(IAbstract.DocumentID As nvarchar), "Doc Date" = IAbstract.InvoiceDate,           
  "CustomerName" = Company_Name, "Account" = AccountsMaster.AccountName, "Value" = NetValue          
 From InvoiceAbstract IAbstract, Customer, AccountsMaster          
 Where (IsNull(IAbstract.Status,0) & 192) = 0 and IAbstract.InvoiceType In (5,6)           
 And Customer.CustomerId = IAbstract.CustomerId          
 And Customer.AccountID = AccountsMaster.AccountID      
 And IAbstract.InvoiceDate Between @FromDate And @ToDate                
End              
             
  


