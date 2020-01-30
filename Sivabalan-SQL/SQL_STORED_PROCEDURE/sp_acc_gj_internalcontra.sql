CREATE procedure sp_acc_gj_internalcontra(@contraid int,@BackDate DATETIME=Null)
as
Declare @documentid int
Declare @fromaccountid int
Declare @toaccountid int
Declare @contradate datetime
Declare @amounttransferred decimal(18,6)
Declare @paymenttype int
Declare @prevfromaccountid int
Declare @prevtoaccountid int
Declare @prevpaymenttype int
Declare @uniqueid int

Declare @DOCUMENTTYPE int
Set @DOCUMENTTYPE = 74

Create Table #TempBackdatedinternalcontra(AccountID Int) --for backdated operation

create table #TempContra(ContraDate datetime,FromAccountID int,ToAccountID int,
Amount decimal(18,6),PaymentType int) 

insert #TempContra
select max(ContraDate),max(FromAccountID),max(ToAccountID),
sum(AdditionalInfo_Amount),max(PaymentType)
from ContraAbstract,ContraDetail where ContraAbstract.ContraID = @contraid
and ContraAbstract.ContraID = ContraDetail.ContraID and isnull(Status,0)<> 192
group by FromAccountID,ToAccountID,PaymentType

DECLARE scancontra CURSOR KEYSET FOR 
select * from #TempContra
OPEN scancontra 
FETCH FROM scancontra INTO @contradate,@fromaccountid,@toaccountid,@amounttransferred,@paymenttype
WHILE @@FETCH_STATUS = 0
BEGIN
	begin tran
		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
		select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
	commit tran
	
	begin tran
		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
		select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
	commit tran	

	insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])	
	values(@documentid,@toaccountid,@contradate,@amounttransferred,0,@contraid,@DOCUMENTTYPE,'Internal Contra',@uniqueid)
	Insert Into #TempBackdatedinternalcontra(AccountID) Values(@toaccountid)
	
	insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])	
	values(@documentid,@fromaccountid,@contradate,0,@amounttransferred,@contraid,@DOCUMENTTYPE,'Internal Contra',@uniqueid)
	Insert Into #TempBackdatedinternalcontra(AccountID) Values(@fromaccountid)
	

	FETCH NEXT FROM scancontra INTO @contradate,@fromaccountid,@toaccountid,@amounttransferred,@paymenttype
END
CLOSE scancontra
DEALLOCATE scancontra
drop table #TempContra

If @BackDate Is Not Null  
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
	Select AccountID From #TempBackdatedinternalcontra
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
Drop Table  #TempBackdatedinternalcontra





