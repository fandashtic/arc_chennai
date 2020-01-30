CREATE procedure sp_acc_gj_cancelapv(@apvid integer,@BackDate DATETIME=Null)
as
declare @documentid integer
declare @uniqueid integer
declare @accountid integer
declare @value decimal(18,6)
declare @apvdate datetime
declare @amount decimal(18,6)
declare @partyid integer
declare @otheraccountid integer
declare @othervalue decimal(18,6)
declare @DOCUMENTTYPE integer

set @DOCUMENTTYPE = 47

Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation

select @apvdate = [APVDate],@amount = [AmountApproved],@partyid=[PartyAccountID],
@otheraccountid = isnull([OtherAccountID],0),@othervalue = isnull([OtherValue],0) from APVAbstract where [DocumentID]= @apvid  

begin tran
	update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
	select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24 
commit tran

begin tran
	update DocumentNumbers set DocumentID = DocumentID + 1 where DocType =51
	select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51 
commit tran

set @amount = @amount + isnull(@othervalue,0)

insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
Values(@documentid,@partyid,@apvdate,@amount,0,@apvid,@DOCUMENTTYPE,'Accounts Payable Voucher Cancellation',@uniqueid,getdate())
Insert Into #TempBackdatedAccounts(AccountID) Values(@partyid)

declare scanapvdetail cursor keyset for 
select AccountID,Amount from APVDetail where [DocumentID]= @apvid

open scanapvdetail
fetch from scanapvdetail into @accountid,@value
while @@fetch_status =0
begin
	insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
	Values(@documentid,@accountid,@apvdate,0,@value,@apvid,@DOCUMENTTYPE,'Accounts Payable Voucher Cancellation',@uniqueid,getdate())
	Insert Into #TempBackdatedAccounts(AccountID) Values(@accountid)

	fetch next from scanapvdetail into @accountid,@value
end
close scanapvdetail
deallocate scanapvdetail

if @othervalue <> 0 
begin
	begin tran
		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
		select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24 
	commit tran
	
	begin tran
		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType =51
		select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51 
	commit tran

	insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
	Values(@documentid,@otheraccountid,@apvdate,@othervalue,0,@apvid,@DOCUMENTTYPE,'Accounts Payable Voucher Cancellation',@uniqueid,getdate())	
	Insert Into #TempBackdatedAccounts(AccountID) Values(@otheraccountid)

	insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
	values(@documentid,@partyid,@apvdate,0,@othervalue,@apvid,@DOCUMENTTYPE,'Accounts Payable Voucher Cancellation',@uniqueid,getdate())
	Insert Into #TempBackdatedAccounts(AccountID) Values(@partyid)
end

If @BackDate Is Not Null  
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
	Select AccountID From #TempBackdatedAccounts
	OPEN scantempbackdatedaccounts
	FETCH FROM scantempbackdatedaccounts INTO @TempAccountID
	WHILE @@FETCH_STATUS =0
	Begin
		Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID
		FETCH NEXT FROM scantempbackdatedaccounts INTO @TempAccountID
	End
	CLOSE scantempbackdatedaccounts
	DEALLOCATE scantempbackdatedaccounts
End
Drop Table #TempBackdatedAccounts

