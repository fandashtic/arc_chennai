CREATE Procedure Spr_Customer_Summary_Detail (@CustomerID nvarchar(255), @FromDate DateTime,      
@ToDate DateTime)      
As      

Declare @INVOICE nvarchar(20)          
Declare @AMENDINVOICE nvarchar(20)          
Declare @SALESRETURNSALABLE nvarchar(20) 
Declare @SALESRETURNDAMAGES nvarchar(20) 
Declare @COLLECTIONS nvarchar(20) 
Declare @CREDITNOTE nvarchar(20) 
Declare @DEBITNOTE nvarchar(20) 

Select @INVOICE = dbo.LookupdictionaryItem(N'Invoice',Default)
Select @AMENDINVOICE = dbo.LookupdictionaryItem(N'Amend Invoice',Default)
Select @SALESRETURNSALABLE = dbo.LookupdictionaryItem(N'Sales Return Salable',Default)
Select @SALESRETURNDAMAGES = dbo.LookupdictionaryItem(N'Sales Return Damages',Default)
Select @COLLECTIONS = dbo.LookupdictionaryItem(N'Collections',Default)
Select @CREDITNOTE = dbo.LookupdictionaryItem(N'Credit Note',Default)
Select @DEBITNOTE = dbo.LookupdictionaryItem(N'Debit Note',Default)

  
Select CustomerID, "TransactionID" = Case IsNull(GSTFlag,0) when 0 then (Select Prefix From       
VoucherPrefix Where TranID = N'INVOICE') + Cast(DocumentID As nvarchar)else ISNULL(InvoiceAbstract.GSTFullDocID,'') END,        
"Type" = Case InvoiceType When 1 Then @INVOICE When 3 Then @AMENDINVOICE       
When 4 Then Case When Status & 32 = 0 Then @SALESRETURNSALABLE Else @SALESRETURNDAMAGES      
End Else N'' End,      
"Doc Ref" = DocReference, "Date" = Cast(DatePart(DD, InvoiceDate) As nvarchar)+N'/'+      
Cast(DatePart(MM, InvoiceDate) As nvarchar)+N'/'+Cast(DatePart(YYYY, InvoiceDate) As nvarchar),      
 "Amount" = (Case InvoiceType When 4 Then       
-1 Else 1 End) * (NetValue) -- IsNull(Freight, 0))      
From InvoiceAbstract Where CustomerID = @CustomerID And InvoiceDate Between @FromDate And      
@ToDate And Status & 192 = 0
      
Union      
      
Select FullDocID, "TransactionID" = FullDocID,      
"Type" = @COLLECTIONS,      
"Doc Ref" = DocumentReference, "Date" = Cast(DatePart(DD, DocumentDate) As nvarchar)+N'/'+      
Cast(DatePart(MM, DocumentDate) As nvarchar)+N'/'+Cast(DatePart(YYYY, DocumentDate) As nvarchar)      
, "Amount" = Value      
From Collections Where CustomerID = @CustomerID And DocumentDate Between @FromDate And      
@ToDate And Status & 192 = 0
      
Union      
      
Select CustomerID, "TransactionID" = (Select Prefix From       
VoucherPrefix Where TranID = @DEBITNOTE) + Cast(DocumentID As nvarchar),      
"Type" = @DEBITNOTE,      
"Doc Ref" = DocumentReference, "Date" = Cast(DatePart(DD, DocumentDate) As nvarchar)+N'/'+      
Cast(DatePart(MM, DocumentDate) As nvarchar)+N'/'+Cast(DatePart(YYYY, DocumentDate) As nvarchar),      
"Amount" = NoteValue      
From DebitNote Where CustomerID = @CustomerID And DocumentDate Between @FromDate And      
@ToDate And IsNull(Status, 0) & 192 = 0
      
Union      
      
Select CustomerID, "TransactionID" = (Select Prefix From       
VoucherPrefix Where TranID = N'CREDIT NOTE') + Cast(DocumentID As nvarchar),      
"Type" = @CREDITNOTE,      
"Doc Ref" = DocumentReference, "Date" = Cast(DatePart(DD, DocumentDate) As nvarchar)+N'/'+      
Cast(DatePart(MM, DocumentDate) As nvarchar)+N'/'+Cast(DatePart(YYYY, DocumentDate) As nvarchar),      
 "Amount" = -1 * NoteValue      
From CreditNote Where CustomerID = @CustomerID And DocumentDate Between @FromDate And      
@ToDate And IsNull(Status, 0) & 192 = 0
