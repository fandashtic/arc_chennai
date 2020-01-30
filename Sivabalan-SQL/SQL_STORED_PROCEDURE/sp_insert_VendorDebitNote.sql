CREATE procedure sp_insert_VendorDebitNote(       
     @PartyID nvarchar(15),        
     @Reference nvarchar(15),        
     @DocDate datetime,        
     @BillAmount float,        
     @Balance float,      
     @remarks nvarchar(50),      
     @Flag int = 0)        
as        
declare @DocumentID int        
DECLARE @SalesmanID int        
        
select @SalesmanID = ISNULL((select SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)        
begin tran        
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 11        
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 11        
commit tran        
 insert into DebitNote (DocumentID,        
    VendorID,        
    NoteValue,        
    DocumentDate,        
    Balance,        
    DocRef,        
    SalesmanID,        
    Memo,      
    Flag)        
 values        
          (@DocumentID,        
    @PartyID,        
    @BillAmount,        
    @DocDate,        
    @Balance,        
    @Reference,        
    @SalesmanID,        
    @remarks,      
    @Flag)         
select @DocumentID, @@Identity        

