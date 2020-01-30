
CREATE procedure sp_insert_DebitNote( @PartyType int,  
     @PartyID nvarchar(15),  
     @Value Decimal(18,6),  
     @DocDate datetime,  
     @Remarks nvarchar(255),       
     @Flag int = 0,  
     @DocRef nvarchar(50) = N'',
	@SalesmanID int = 0)  
as  
Declare @DocumentID int  
Declare @DefaultBeat as Int --Specific to ITC  

IF @SalesmanID = 0
Begin
	Select @DefaultBeat = IsNull(DefaultBeatID,0) From Customer Where CustomerID = @PartyID  
	IF @DefaultBeat > 0  
		select @SalesmanID = SalesmanID from Beat_Salesman where BeatID = @DefaultBeat And CustomerID = @PartyID 
	Else  
		select @SalesmanID = ISNULL((select Distinct(SalesmanID) from Beat_Salesman where CustomerID = @PartyID), 0)  
End

begin tran  
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 11  
select @DocumentID = DocumentID - 1 from DocumentNumbers where DocType = 11  
commit tran  
if @PartyType = 0   
 insert into DebitNote (DocumentID,  
    CustomerID,  
    NoteValue,  
    DocumentDate,  
    Balance,  
    Memo,  
    SalesmanID,  
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
    @Flag,  
    @DocRef)   
else  
 insert into DebitNote (DocumentID,  
    VendorID,  
    NoteValue,  
    DocumentDate,  
    Balance,  
    Memo,  
    SalesmanID,  
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
    @Flag,  
    @DocRef)   
select @DocumentID, @@Identity  


