CREATE Procedure sp_acc_Insert_CustCreditNote(
     @PartyID nvarchar(15),      
     @Reference nvarchar(15),    
     @DocDate datetime,      
     @BillAmount Decimal(18,6),    
     @Balance Decimal(18,6),  
     @Remarks nvarchar(50),
     @Flag INT = 0)      
As      
DECLARE @DocumentID int      
DECLARE @SalesmanID int      
      
Select @SalesmanID = ISNULL((Select SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)      
Begin Tran      
	Update DocumentNumbers Set DocumentID = DocumentID + 1 where DocType = 10      
	Select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 10      
Commit Tran      
      
Insert Into CreditNote 
         (DocumentID,      
    CustomerID,      
    NoteValue,      
    DocumentDate,      
    Balance,      
    DocRef,  
    Memo,     
    SalesmanID,
    Flag)      
values      
         (@DocumentID,      
    @PartyID,      
    @BillAmount,      
    @DocDate,      
    @Balance,      
    @Reference,      
    @Remarks,  
    @SalesmanID,
    @Flag)       
Select @DocumentID

