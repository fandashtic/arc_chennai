CREATE PROCEDURE spr_DSwiseBeatwiseOutstanding_detail(@customer nvarchar(250))                  
as                  
Declare @INVOICE NVarchar(50)        
Declare @SALESRETURN NVarchar(50)        
Declare @RETAILINVOICE NVarchar(50)        
Declare @INVOICEAMENDMENT NVarchar(50)        
Declare @SALESRETURNSALEABLE NVarchar(50)        
Declare @SALESRETURNDAMAGE NVarchar(50)        
Declare @CREDITNOTE NVarchar(50)        
Declare @DEBITNOTE NVarchar(50)        
Declare @ADVANCE NVarchar(50)        
        

Declare @BeatID int    
Declare @CustomerID nvarchar(20)  
Declare @SalesmanID Int  
Declare @Pos1 int    
Declare @Pos2 int
Declare @Length int    

Set @Length = Len(@Customer)    
Set @Pos1 = CharIndex(N';', @Customer, 1)    
Set @Pos2 = CharIndex(N':', @Customer, 1)
Set @CustomerID = SubString(@Customer, 1, @Pos1 - 1) 
Set @SalesmanID = Cast(SubString(@Customer,@Pos1+1,(@Pos2 - @Pos1)- 1) as Int)    
Set @BeatID = Cast(SubString(@Customer,@Pos2+1,(@Length - @Pos2)) as int) 

Set @INVOICE = dbo.LookupDictionaryItem(N'Invoice', Default)        
Set @SALESRETURN = dbo.LookupDictionaryItem(N'Sales Return', Default)        
Set @RETAILINVOICE = dbo.LookupDictionaryItem(N'Retail Invoice', Default)        
Set @INVOICEAMENDMENT = dbo.LookupDictionaryItem(N'Invoice Amendment', Default)        
Set @SALESRETURNSALEABLE = dbo.LookupDictionaryItem(N'Sales Return Saleable', Default)        
Set @SALESRETURNDAMAGE = dbo.LookupDictionaryItem(N'Sales Return Damages', Default)        
Set @CREDITNOTE = dbo.LookupDictionaryItem(N'Credit Note', Default)        
Set @DEBITNOTE = dbo.LookupDictionaryItem(N'Debit Note', Default)        
Set @ADVANCE = dbo.LookupDictionaryItem(N'Advance', Default)     


   
   
declare @invtype nvarchar(100)            
select InvoiceAbstract.InvoiceID,             
"Transaction Type" = case ISNULL(InvoiceAbstract.GSTFlag,0) when 0 then  InvPrefix.Prefix + cast(InvoiceAbstract.DocumentID as nvarchar) else ISNULL(InvoiceAbstract.GSTFullDocID,'')end,            
"Doc Reference"=DocReference,            
"Date" = InvoiceAbstract.InvoiceDate,       
"Amount (%c)" = case InvoiceType when 4 then 0 - InvoiceAbstract.NetValue else InvoiceAbstract.NetValue end,            
"Balance (%c)" = case InvoiceType when 4 then 0 - InvoiceAbstract.Balance else InvoiceAbstract.Balance end,             
"Due Days" = datediff(dd, InvoiceAbstract.InvoiceDate, GetDate()),            
"Invoice Type" = case InvoiceAbstract.InvoiceType            
when 1 then @INVOICE when 3 then @INVOICEAMENDMENT        
when 4 then @SALESRETURN else N'' end        
from InvoiceAbstract, VoucherPrefix as InvPrefix            
where InvoiceAbstract.CustomerID = @CustomerID and            
InvoiceAbstract.Status & 128 = 0 and  
--InvoiceAbstract.BeatID = @BeatID and
--InvoiceAbstract.SalesmanID =@SalesmanID and          

Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else 
IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End = @SalesmanID and

Case IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '')
When '' Then ISNULL(InvoiceAbstract.BeatId, 0) Else 
IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos 
Where dsos.InvoiceDocumentID = InvoiceAbstract.DocumentID), '') End = @BeatID and 

InvoiceAbstract.InvoiceType in (1, 3, 4) and            
InvoiceAbstract.Balance > 0 and            
InvPrefix.TranID = N'INVOICE'            
union            
select creditnote.creditid,  VoucherPrefix.Prefix + cast(Creditnote.DocumentID as nvarchar),           
DocRef,          
Creditnote.DocumentDate,0 - Creditnote.Notevalue,            
0 - Creditnote.Balance ,     
datediff(dd, Creditnote.DocumentDate, GetDate()), @CREDITNOTE        
from Creditnote, VoucherPrefix,Customer             
where Creditnote.CustomerID = @CustomerID and     
creditNote.customerID = Customer.CustomerID
and CreditNote.SalesmanID = @SalesmanID
and Customer.DefaultBeatID = @BeatID           
and Creditnote.Balance > 0 and            
Voucherprefix.TranID = N'CREDIT NOTE'            
union            
select debitnote.debitid,  VoucherPrefix.Prefix + cast(Debitnote.DocumentID as nvarchar),           
DocRef,           
Debitnote.DocumentDate,            
Debitnote.Notevalue,            
Debitnote.Balance ,            
datediff(dd, Debitnote.DocumentDate, GetDate()), @DEBITNOTE        
from Debitnote, VoucherPrefix,Customer             
where Debitnote.CustomerID = @CustomerID 
and DebitNote.CustomerID = Customer.CustomerID
and DebitNote.SalesmanID = @SalesmanID  
and customer.defaultbeatID = @BeatID        
and Debitnote.Balance > 0 and  IsNull(Debitnote.Status, 0) & 192 = 0  And 
Voucherprefix.TranID = N'DEBIT NOTE'           
union          
Select Collections.DocumentID, Collections.FullDocID, Null, Collections.DocumentDate,          
0 - Collections.Value, 0 - Collections.Balance,           
DateDiff(dd, Collections.DocumentDate, GetDate()), @ADVANCE        
From Collections          
Where Collections.CustomerID = @CustomerID          
and Collections.SalesmanID = @salesmanID
and Collections.BeatID = @BeatID
and Collections.Balance > 0          
Order By "Date"     

