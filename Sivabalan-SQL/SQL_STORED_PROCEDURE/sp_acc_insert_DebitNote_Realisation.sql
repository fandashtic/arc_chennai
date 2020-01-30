CREATE procedure sp_acc_insert_DebitNote_Realisation( @PartyType int,      
       @PartyID nvarchar(15),      
       @Value float,      
       @DocDate datetime,      
       @Remarks nvarchar(255),           
       @ExpenseAccount Int,      
       @Flag int = 0,      
       @DocRef nVarchar(50) = N''  
)      
as      
declare @DocumentID int      
DECLARE @SalesmanID int      
Declare @ExpenseID as Int      
Declare @DefaultBeat as Int --Specific to ITC     
      
begin tran      
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 11      
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 11      
commit tran      
      
If @Flag=2       
begin      
 Select @ExpenseID=AccountID from Bank where BankID=@ExpenseAccount      
End      
Else      
Begin      
 Set @ExpenseID=@ExpenseAccount      
End      
      
If @PartyType = 0       
Begin      
 Select @DefaultBeat = IsNull(DefaultBeatID,0) From Customer Where CustomerID = @PartyID  
 IF @DefaultBeat > 0  
 	select @SalesmanID = SalesmanID from Beat_Salesman where BeatID = @DefaultBeat  
 Else  
  	select @SalesmanID = ISNULL((select Distinct SalesmanID from Beat_Salesman where CustomerID = @PartyID), 0)      
  
 insert into DebitNote (DocumentID,      
    CustomerID,      
    NoteValue,      
    DocumentDate,      
    Balance,      
    Memo,      
    SalesmanID,      
    AccountID,      
    Flag,      
    DocRef)      
 values      
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
Else if @PartyType = 1 or @PartyType = 2      
Begin      
 insert into DebitNote (DocumentID,      
    Others,      
    NoteValue,      
    DocumentDate,      
    Balance,      
    Memo,      
    SalesmanID,      
    AccountID,      
    Flag,      
    DocRef)      
 values      
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
      
 /*Set @OthersID=cast(@PartyID as Int)      
 If Not exists(Select top 1 VendorID from Vendors where AccountID=@OthersID)      
 Begin      
        
  insert into DebitNote (DocumentID,      
     Others,      
     NoteValue,      
     DocumentDate,      
     Balance,      
     Memo,      
     SalesmanID,      
     AccountID,      
     Flag,      
     DocRef)      
  values      
           (@DocumentID,      
     @OthersID,      
     @Value,      
     @DocDate,      
     @Value,      
     @Remarks,      
     @SalesmanID,      
     @ExpenseAccount,      
     @Flag,      
     @DocRef)      
 End      
 Else      
 Begin      
  Select @VendorID=VendorID from Vendors where AccountID=@PartyID      
      
  insert into DebitNote (DocumentID,      
     VendorID,      
     NoteValue,      
     DocumentDate,      
     Balance,      
     Memo,      
     SalesmanID,      
     AccountID,      
     Flag,      
     DocRef)      
  values      
           (@DocumentID,      
     @VendorID,      
     @Value,      
     @DocDate,      
     @Value,      
     @Remarks,      
     @SalesmanID,      
     @ExpenseAccount,      
     @Flag,      
     @DocRef)       
 End      
 */      
End       
select @DocumentID, @@Identity      
      
      
      
      
      
      
      
      
    
  


