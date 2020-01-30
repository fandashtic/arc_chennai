CREATE Procedure spr_List_TCNS_CreditNote (@FROMDATE datetime,              
       @TODATE datetime)          
As          
Declare @CreditNote nvarchar(50)          
Declare @RetailSalesReturn nvarchar(50)          
          
Set @CreditNote = dbo.LookupDictionaryItem(N'Credit Note',Default)          
Set @RetailSalesReturn = dbo.LookupDictionaryItem(N'Retail Sales Return',Default)
          
Select @CreditNote, "DocumentType" = @CreditNote, "Total Value" = IsNull(Sum(NoteValue),0),           
 "No. of Documents" = Count(DocumentID) From CreditNote Where (IsNull(Status,0) & 192) = 0
 And IsNull(VendorID,N'') = N'' And IsNull(CustomerID,N'') <> N'' 
 And DocumentDate Between @FromDate And @ToDate        
Union          
Select @RetailSalesReturn, "DocumentType" = @RetailSalesReturn, "Total Value" =       
 IsNull(Sum(IAbstract.NetValue),0), "No. of Documents" = Count(IAbstract.InvoiceID) From       
 InvoiceAbstract IAbstract Where (IsNull(IAbstract.Status,0) & 192) = 0   
 And IAbstract.InvoiceType In (5,6) And IAbstract.InvoiceDate Between @FromDate And @ToDate        


