CREATE Procedure sp_acc_Insert_CreditNote_Realisation(@PartyType INT,@PartyID nVarChar(50),      
@Value Float,@DocDate DateTime,@Remarks nVarChar(255),@ExpenseAccount INT,@Flag INT=0,@DocRef nVarchar(50)=N'')      
as      
Declare @DocumentID INT      
Declare @SalesmanID INT      
Declare @ExpenseID INT     
Declare @DefaultBeat as Int --Specific to ITC     
 
      
Begin Tran      
 Update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 10      
 Select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 10      
Commit Tran      
      
If @Flag=5       
 Select @ExpenseID=AccountID from Bank where BankID=@ExpenseAccount      
Else      
 Set @ExpenseID=@ExpenseAccount      
      
If @PartyType=0       
 Begin      
  Select @DefaultBeat = IsNull(DefaultBeatID,0) From Customer Where CustomerID = @PartyID 
  Select @SalesmanID = SalesmanID from Beat_Salesman where BeatID = @DefaultBeat  and CustomerID=@PartyID  
  Insert Into CreditNote (DocumentID,      
    CustomerID,      
    NoteValue,      
    DocumentDate,      
    Balance,      
    Memo,      
    SalesmanID,      
    AccountID,      
    Flag,      
    DocRef)      
  Values      
   (@DocumentID,      
    @PartyID,      
    @Value,      
    @DocDate,      
    @Value,      
    @Remarks,      
    @SalesmanID,      
    @ExpenseID,      
    @Flag,      
    @DocRef)      
 End       
Else If @PartyType=1 Or @PartyType=2      
 Begin      
  Insert Into CreditNote (DocumentID,      
    Others,      
    NoteValue,      
    DocumentDate,      
    Balance,      
    Memo,      
    SalesmanID,      
    AccountID,      
    Flag,      
    DocRef)      
  Values      
   (@DocumentID,      
    @PartyID,      
    @Value,      
    @DocDate,      
    @Value,      
    @Remarks,      
    @SalesmanID,      
    @ExpenseID,      
    @Flag,      
    @DocRef)      
 End       
Select @DocumentID, @@Identity
