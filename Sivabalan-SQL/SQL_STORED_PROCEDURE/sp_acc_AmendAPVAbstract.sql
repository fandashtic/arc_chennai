CREATE procedure sp_acc_AmendAPVAbstract(@apvdate datetime,@partyaccountid integer,
@billno nvarchar(20),@billdate datetime,@billamount decimal(18,6),@amountapproved decimal(18,6),@otheraccountid integer,
@othervalue decimal(18,6),@expensefor integer,@approvedby integer,@apvremarks nvarchar(4000),@DocRef nvarchar(255),@DocType nvarchar(100),@RefDocID Integer)
as
Declare @documentid integer

Update APVAbstract
Set Status = (isnull(Status,0) | 128)
where [DocumentID]= @RefDocID

Update Batch_Assets
Set Saleable = 3
where [APVID] = @RefDocID

Select @documentid = APVID from APVAbstract Where DocumentID = @RefDocID
If @documentid = N''
 Begin
  begin tran
   update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 53
   select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 53
  commit tran
 End

insert APVAbstract(APVID,APVDate,PartyAccountID,BillNo,BillDate,BillAmount,AmountApproved,
OtherAccountID,OtherValue,Expensefor,Approvedby,APVRemarks,CreationTime,Balance,DocumentReference,DocSerialType,RefDocID)
values(@documentid,@apvdate,@partyaccountid,@billno,@billdate,@billamount,@amountapproved,
@otheraccountid,@othervalue,@expensefor,@approvedby,@apvremarks,getdate(),@amountapproved,@DocRef,@DocType,@RefDocID)

select @@identity,@documentid

