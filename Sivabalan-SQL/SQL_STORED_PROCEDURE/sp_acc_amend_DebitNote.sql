CREATE procedure sp_acc_amend_DebitNote(   
     @Debit_Note Int,  
     @PartyType int,  
     @PartyID nvarchar(15),  
     @Value float,  
     @DocDate datetime,  
     @Remarks nvarchar(255),       
     @Flag int = 0,  
     @DocRef nVarchar(50) = N'',@Multiple INT = 0)  
as  
declare @DocumentID int  
DECLARE @SalesmanID int  
Declare @PrevID  Int    
    
Set @PrevId = @Debit_Note    
/* First Cancel the Credit Note previously Entered basis the Creditid*/    
Update DebitNote  
Set    
Status = Isnull(Status,0) | 128,    
Balance = 0    
Where DebitId = @Debit_Note          
    
/*  Get the Document ID for the cancelled document , for it has to be stored in the    
 RefDocId field.This helps to identify easily to which document it refers to    
*/    
Select @Documentid = DocumentId from Debitnote where DebitID = @Debit_Note    
  
select @SalesmanID = ISNULL((select SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)  
  
if @PartyType = 0   
 insert into DebitNote (DocumentID,  
    CustomerID,  
    NoteValue,  
    DocumentDate,  
    Balance,  
    Memo,  
    SalesmanID,  
    Flag,  
    DocRef,  
    RefDocid,AccountMode)  
 values  
       (@DocumentID,  
    @PartyID,  
    @Value,  
    @DocDate,  
    @Value,  
    @Remarks,  
    @SalesmanID,  
    @Flag,  
    @DocRef,  
    @PrevID,@Multiple)  
else if @PartyType = 1  
 insert into DebitNote (DocumentID,  
    VendorID,  
    NoteValue,  
    DocumentDate,  
    Balance,  
    Memo,  
    SalesmanID,  
    Flag,  
    DocRef,  
    RefDocid,AccountMode)  
 values  
       (@DocumentID,  
    @PartyID,  
    @Value,  
    @DocDate,  
    @Value,  
    @Remarks,  
    @SalesmanID,  
    @Flag,  
    @DocRef,  
    @PrevID,@Multiple)  
else if @PartyType = 2  
 insert into DebitNote (DocumentID,  
    Others,  
    NoteValue,  
    DocumentDate,  
    Balance,  
    Memo,  
    SalesmanID,  
    Flag,  
    DocRef,  
    RefDocid,AccountMode)  
 values  
       (@DocumentID,  
    @PartyID,  
    @Value,  
    @DocDate,  
    @Value,  
    @Remarks,  
    @SalesmanID,  
    @Flag,  
    @DocRef,  
    @PrevID,@Multiple)  
select @DocumentID, @@Identity  
  
  
  



