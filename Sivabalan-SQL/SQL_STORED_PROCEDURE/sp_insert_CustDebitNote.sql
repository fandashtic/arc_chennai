Create procedure sp_insert_CustDebitNote(   
     @PartyID nvarchar(15),    
     @Reference nvarchar(50),    
     @DocDate datetime,    
     @BillAmount Decimal(18,6),    
     @Balance Decimal(18,6),  
     @remarks nvarchar(255),  
     @Flag int = 0)    
as    
declare @DocumentID int    
DECLARE @SalesmanID int    
    
select @SalesmanID = ISNULL((select Top 1 SalesmanID from Beat_Salesman where CustomerID = @PartyID And BeatID = (Select isNull(DefaultBeatID,0) From Customer Where CustomerID = @PartyID )), 0)    
begin tran    
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 11    
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 11    
commit tran    
 insert into DebitNote (DocumentID,    
    CustomerID,    
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

