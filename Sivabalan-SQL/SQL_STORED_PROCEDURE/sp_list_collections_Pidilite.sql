CREATE procedure sp_list_collections_Pidilite(@CustomerID nvarchar(15),@CollectionDate DateTime = '')                              
as                              
if @CollectionDate = ''                     
 Select @CollectionDate=Getdate()       
  
Declare @ADVANCECOLLECTION nVarchar(50)               
Declare @SALESRETURN nVarchar(50)  
Declare @CREDITNOTE nVarchar(50)  
Declare @COLLECTIONS nVarchar(50)                   
Declare @RETAILINVOICE nVarchar(50)  
Declare @INVOICEAMND nVarchar(50)  
Declare @DEBITNOTE nVarchar(50)  
Declare @BANKCHARGES nVarchar(50)  
Declare @BOUNCED nVarchar(50)  
Declare @INVOICE nVarchar(50)  
  
  
Set @ADVANCECOLLECTION = dbo.LookupDictionaryItem(N'Advance Collection',Default)  
Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return',Default)  
Set @CREDITNOTE =  dbo.LookupDictionaryItem(N'Credit Note',Default)  
Set @COLLECTIONS =  dbo.LookupDictionaryItem(N'Collections',Default)  
Set @RETAILINVOICE =  dbo.LookupDictionaryItem(N'Retail Invoice',Default)  
Set @INVOICEAMND =  dbo.LookupDictionaryItem(N'Invoice Amd',Default)  
Set @DEBITNOTE =  dbo.LookupDictionaryItem(N'Debit Note',Default)  
Set @BANKCHARGES =  dbo.LookupDictionaryItem(N'Bank Charges',Default)  
Set @BOUNCED =  dbo.LookupDictionaryItem(N'Bounced',Default)  
Set @INVOICE =  dbo.LookupDictionaryItem(N'Invoice',Default)  
  
  
select "DocumentID" = VoucherPrefix.Prefix + CAST(DocumentID as nvarchar),                               
"DocumentDate" = InvoiceDate, NetValue, Balance,                           
InvoiceID,"Type" = case InvoiceType when 4 then 1 when 5 then 7 when 6 then 7 end,                          
@SALESRETURN, AdditionalDiscount, DocReference,              
"PaymentIncentiveDiscount" = 0              
from invoiceabstract, VoucherPrefix                              
where InvoiceType in(4,5,6) and                              
IsNull(Status, 0) & 128 = 0 and                              
CustomerID = @CustomerID and                              
ISNULL(Balance, 0) > 0 and                              
VoucherPrefix.TranID = N'SALES RETURN'                              
                         
union                              
                              
select "DocumentID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),                               
"DocumentDate" = DocumentDate,                               
NoteValue, Balance, CreditID, "Type" = 2,                        
Case IsNULL(Flag,0)                        
When 7 then                        
@SALESRETURN  
When 8 then                        
@ADVANCECOLLECTION  
Else                        
@CREDITNOTE  
end, 0, DocRef,              
"PaymentIncentiveDiscount" = 0    
from CreditNote, VoucherPrefix                              
where CustomerID = @CustomerID and                              
Balance > 0 and                              
VoucherPrefix.TranID = N'CREDIT NOTE'                              
                              
union                              
                              
select "DocumentID" = FullDocID,                               
"DocumentDate" = DocumentDate, Value,                               
Balance, DocumentID, "Type" = 3, @COLLECTIONS, 0, Null,              
"PaymentIncentiveDiscount" = 0        
from Collections, VoucherPrefix                              
where Balance > 0 and                              
CustomerID = @CustomerID and                              
(IsNull(Status, 0) & 192) = 0 And -- Cancelled collections                              
VoucherPrefix.TranID = N'COLLECTIONS'                              
                              
union                              
                              
select                               
"DocumentID" =                               
case InvoiceType                              
when 1 then                              
 VoucherPrefix.Prefix                               
When 2 then                        
 RPrefix.Prefix                        
when 3 then                              
 InvPrefix.Prefix                              
end                              
+ CAST(DocumentID as nvarchar), "DocumentDate" = InvoiceDate,                
"NetValue" = netvalue,        
"Balance"  =  balance ,           
InvoiceID, "Type" = case InvoiceType                             
 when 1 then   4                              
 when 2 then   6                              
 when 3 then   4 end,                              
case InvoiceType                              
when 1 then                              
  @INVOICE  
when 2 then                              
  @RETAILINVOICE  
when 3 then                              
  @INVOICEAMND  
end,                        
"AdditionalDiscount" = AdditionalDiscount,              
DocReference,              
"PaymentIncentiveDiscount" = (Case When datediff(dd,@CollectionDate,PaymentDate) >=0 Then  IsNull(AddCollDiscPercentage,0)               
else 0 end)    
from InvoiceAbstract, VoucherPrefix, VoucherPrefix as InvPrefix, VoucherPrefix as RPrefix ,Customer                       
where InvoiceType in (1, 3, 2) and                           
InvoiceAbstract.CustomerID = Customer.CustomerID and                         
IsNull(Status, 0) & 128 = 0 and                              
InvoiceAbstract.CustomerID = @CustomerID and                              
ISNULL(Balance, 0) > 0 and                              
VoucherPrefix.TranID = N'INVOICE' and                              
InvPrefix.TranID = N'INVOICE AMENDMENT' And                        
RPrefix.TranID = N'RETAIL INVOICE'                        
                              
union                              
                              
select "DocumentID" = VoucherPrefix.Prefix + cast(DocumentID as nvarchar),                               
"DocumentDate" = DocumentDate, NoteValue,                               
Balance, DebitID, "Type" = 5,                               
case Flag                              
when 0 then                              
@DEBITNOTE  
when 1 then                              
@BANKCHARGES  
when 2 then                              
@BOUNCED                            
When 4 then                        
@DEBITNOTE                  
When 5 then                        
@INVOICE  
end, 0, DocRef,              
"PaymentIncentiveDiscount" = 0    
from DebitNote, VoucherPrefix                            
where Balance > 0 and                               
CustomerID = @CustomerID and                               
VoucherPrefix.TranID = N'DEBIT NOTE'                              
    
order by DocumentDate                              
                        
  
