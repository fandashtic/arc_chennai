CREATE procedure spr_list_CollectionDetail (@CollectionID integer)  
as  

Declare @SALESRETURN NVarchar(50)
Declare @CREDITNOTE NVarchar(50)
Declare @COLLECTION NVarchar(50)
Declare @INVOICE NVarchar(50)
Declare @DEBITNOTE NVarchar(50)
Declare @RETAILINVOICE NVarchar(50)
Declare @RETINVOICESALESRETURN NVarchar(50)
Declare @SERVICEINV NVarchar(50)

Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)
Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)
Set @COLLECTION = dbo.LookupDictionaryItem(N'Collections', Default)
Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)
Set @DEBITNOTE = dbo.LookupDictionaryItem(N'Debit Note', Default)
Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice', Default)
Set @RETINVOICESALESRETURN = dbo.LookupDictionaryItem(N'Retail Invoice Sales Return', Default)
Set @SERVICEINV = dbo.LookupDictionaryItem(N'Service Invoice', Default)

  
select "Document ID" = OriginalID,   
"Document ID" = OriginalID,   
"Date" = CollectionDetail.DocumentDate,   
"Doc Ref" = CollectionDetail.DocRef,  
"Type" = case DocumentType  
when 1 then @SALESRETURN
when 2 then @CREDITNOTE
when 3 then @COLLECTION
when 4 then @INVOICE
when 5 then @DEBITNOTE
when 6 then @RETAILINVOICE
when 7 then @RETINVOICESALESRETURN
when 12 then @SERVICEINV -- DocumentType 12 is handled for Service Invoice - Service Module
end,  
"Doc Value" = DocumentValue,  

"Adjustments in Invoice" = 
Case 
When DocumentType in (2,5) Then 
DocumentValue 
Else 0
End,

"Adj Amount" = case DocumentType  
when 1 then N'-'  
when 2 then N'-'  
when 3 then N'-'  
when 4 then N''  
when 5 then N'+'  
when 6 then N''
when 7 then N'-'
when 12 then N'' -- DocumentType 12 is handled for Service Invoice - Service Module
end  
+ cast(CollectionDetail.AdjustedAmount as nvarchar),

"Additional Adjustment"=
Case 
  /* Show Adjustment when negative otherwise ExtraCollection */	
  When Adjustment<0 then Isnull(Adjustment,0)
  Else Isnull(ExtraCollection,0)
end

  
from CollectionDetail    
Where CollectionDetail.CollectionID = @CollectionID




