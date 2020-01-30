CREATE Procedure sp_acc_Insert_VendorCreditNote(           
     @PartyID nvarchar(15),            
     @Reference nvarchar(15),          
     @DocDate datetime,            
     @BillAmount float,          
     @Balance float,        
     @Remarks nvarchar(50),
     @Flag INT = 0)            
As            
DECLARE @DocumentID INT
DECLARE @SalesmanID INT
            
Select @SalesmanID = ISNULL((Select SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)
Begin Tran            
	Update DocumentNumbers Set DocumentID = DocumentID + 1 where DocType = 10            
	Select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 10            
Commit Tran            
            
Insert Into CreditNote (DocumentID,            
   VendorID,            
   NoteValue,            
   DocumentDate,            
   Balance,            
   DocRef,        
   Memo,           
   SalesmanID,
   Flag)
Values            
         (@DocumentID,            
   @PartyID,            
   @BillAmount,            
   @DocDate,            
   @Balance,            
   @Reference,            
   @Remarks,        
   @SalesmanID,
   @Flag)
Select @DocumentID,@@Identity

