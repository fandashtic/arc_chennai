CREATE procedure sp_acc_updateapvabstract(@apvdate datetime,@partyaccountid integer,
@billno nvarchar(20),@billdate datetime,@billamount decimal(18,6),@amountapproved decimal(18,6),@otheraccountid integer,
@othervalue decimal(18,6),@expensefor integer,@approvedby integer,@apvremarks nvarchar(4000),@DocRef nvarchar(255) = NULL,@DocType nvarchar(100) = NULL)
as
Declare @documentid integer

begin tran
	update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 53
	select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 53
commit tran

insert APVAbstract(APVID,APVDate,PartyAccountID,BillNo,BillDate,BillAmount,AmountApproved,
OtherAccountID,OtherValue,Expensefor,Approvedby,APVRemarks,CreationTime,Balance,DocumentReference,DocSerialType)
values(@documentid,@apvdate,@partyaccountid,@billno,@billdate,@billamount,@amountapproved,
@otheraccountid,@othervalue,@expensefor,@approvedby,@apvremarks,getdate(),@amountapproved,@DocRef,@DocType)

select @@identity,@documentid
