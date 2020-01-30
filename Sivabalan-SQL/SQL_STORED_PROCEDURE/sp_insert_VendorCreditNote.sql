CREATE procedure sp_insert_VendorCreditNote(             
     @PartyID nvarchar(15),              
     @Reference nvarchar(50),            
     @DocDate datetime,              
     @BillAmount float,            
     @Balance float,          
     @Remarks nvarchar(50))              
as              
declare @DocumentID int              
DECLARE @SalesmanID int              
              
select @SalesmanID = ISNULL((select SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)              
begin tran              
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 10              
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 10              
commit tran              
              
 insert into CreditNote (DocumentID,              
    VendorID,              
    NoteValue,              
    DocumentDate,              
    Balance,              
    DocRef,          
    Memo,             
    SalesmanID)              
 values              
          (@DocumentID,              
    @PartyID,              
    @BillAmount,              
    @DocDate,              
    @Balance,              
    @Reference,              
    @Remarks,          
    @SalesmanID)               
select @DocumentID              
