CREATE Procedure Spr_ser_Customer_Summary_Detail (@CustomerID nvarchar(300), @FromDate DateTime,      
@ToDate DateTime)      
As      
      
Select CustomerID, "TransactionID" = (Select Prefix From       
VoucherPrefix Where TranID = N'INVOICE') + Cast(DocumentID As nvarchar),      
"Type" = Case InvoiceType When 1 Then N'Invoice' When 3 Then N'Amend Invoice'       
When 4 Then Case When Status & 32 = 0 Then N'Sales Return Salable' Else N'Sales Return Damages'      
End Else N'' End,      
"Doc Ref" = DocReference, 
"Date" = Cast(DatePart(DD, InvoiceDate) As nvarchar)+N'/'+      
Cast(DatePart(MM, InvoiceDate) As nvarchar)+N'/'+Cast(DatePart(YYYY, InvoiceDate) As nvarchar),      
"Amount" = (Case InvoiceType When 4 Then       
-1 Else 1 End) * (NetValue - IsNull(Freight, 0))      
From InvoiceAbstract Where CustomerID = @CustomerID And InvoiceDate Between @FromDate And      
@ToDate And IsNull(Status,0) & 192 = 0


Union      
      
Select FullDocID, "TransactionID" = FullDocID,      
"Type" = N'Collections',      
"Doc Ref" = DocumentReference, 
"Date" = Cast(DatePart(DD, DocumentDate) As nvarchar)+N'/'+      
Cast(DatePart(MM, DocumentDate) As nvarchar)+N'/'+Cast(DatePart(YYYY, DocumentDate) As nvarchar),      
"Amount" = Value      
From Collections Where CustomerID = @CustomerID And DocumentDate Between @FromDate And      
@ToDate And IsNull(Status,0) & 192 = 0
      
Union      
      
Select CustomerID, "TransactionID" = (Select Prefix From       
VoucherPrefix Where TranID = N'DEBIT NOTE') + Cast(DocumentID As nvarchar),      
"Type" = N'Debit Note',      
"Doc Ref" = DocumentReference, 
"Date" = Cast(DatePart(DD, DocumentDate) As nvarchar)+N'/'+      
Cast(DatePart(MM, DocumentDate) As nvarchar)+N'/'+Cast(DatePart(YYYY, DocumentDate) As nvarchar),      
"Amount" = NoteValue      
From DebitNote Where CustomerID = @CustomerID And DocumentDate Between @FromDate And      
@ToDate And IsNull(Status, 0) & 192 = 0
      
Union      
      
Select CustomerID, "TransactionID" = (Select Prefix From       
VoucherPrefix Where TranID = N'CREDIT NOTE') + Cast(DocumentID As nvarchar),      
"Type" = N'Credit Note',      
"Doc Ref" = DocumentReference, 
"Date" = Cast(DatePart(DD, DocumentDate) As nvarchar)+N'/'+      
Cast(DatePart(MM, DocumentDate) As nvarchar)+N'/'+Cast(DatePart(YYYY, DocumentDate) As nvarchar),      
"Amount" = -1 * NoteValue      
From CreditNote Where CustomerID = @CustomerID And DocumentDate Between @FromDate And      
@ToDate And IsNull(Status, 0) & 192 = 0
    
union

Select CustomerID, "TransactionID" = (Select Prefix From VoucherPrefix 
Where TranID = N'SERVICEINVOICE') + Cast(DocumentID As nvarchar),      
"Type" = N'Service Invoice',
"Doc Ref" = DocReference, 
"Date" = Cast(DatePart(DD, ServiceInvoiceDate) As nvarchar)+N'/'+      
Cast(DatePart(MM, ServiceInvoiceDate) As nvarchar)+N'/'+Cast(DatePart(YYYY, ServiceInvoiceDate) As nvarchar),      
"Amount" = (IsNull(NetValue,0) - IsNull(Freight, 0))      
From ServiceInvoiceAbstract Where CustomerID = @CustomerID 
And ServiceInvoiceDate Between @FromDate And @ToDate 
And IsNull(Status,0) & 192 = 0
And IsNull(ServiceInvoiceType,0) = 1

Order By "Date"
