CREATE Procedure sp_acc_gj_grnbillcancellation(@billid integer,@BackDate DATETIME=Null)
as
DECLARE @BILLSPAYABLE INT
DECLARE @PURCHASE INT
DECLARE @DOCTYPE INT
DECLARE @value Decimal(18,6)
DECLARE @documentid INT
DECLARE @uniqueid INT
DECLARE @grndate DATETIME
DECLARE @grnid int
Declare @BillDate DateTime
Declare @GRNDetails nvarchar(255)  
Declare @VATAmount Decimal(18,6)
Declare @VATAccount Integer

SET @BILLSPAYABLE = 27
SET @PURCHASE = 34
Set @VATAccount = 117 /* Vat Receivable on DC account */

SET @DOCTYPE = 41

Create Table #TempBackdatedgrnbillcancellation(AccountID Int) --for backdated operation
Create Table #TempGRNID(GRNID Int)  

Select @BillDate = BillDate, @GRNDetails = GRNID from BillAbstract where [BillID]=@billid

Insert #TempGRNID    
Exec Sp_acc_SQLSplit @GRNDetails,N','    

DECLARE scanGRN CURSOR KEYSET FOR
Select GRNID from #TempGRNID  
OPEN scanGRN
FETCH FROM scanGRN INTO @grnid
While @@FETCH_STATUS=0
Begin
	If IsNull(@grnid,0) <> 0
	Begin
		select @value = max(Debit) from GeneralJournal where 
		isnull([DocumentReference],0)= @grnid and isnull([DocumentType],0)= 41

		select @VATAmount = Max(Isnull(Credit,0)) from GeneralJournal where 
		isnull([DocumentReference],0)= @grnid and isnull([DocumentType],0)= 41
		and AccountID = @VATAccount 

		begin tran
			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
			select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
		commit tran
		
		begin tran
			update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
			select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
		commit tran
		
		If @value <> 0
		Begin
			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
			Values(@documentid,@PURCHASE,@BillDate,(@value - Isnull(@VATAmount,0)),0,@grnid,@DOCTYPE,'Open GRN',@uniqueid,getdate())  
			Insert Into #TempBackdatedgrnbillcancellation(AccountID) Values(@PURCHASE) 

			If Isnull(@VATAmount,0) > 0 
			Begin
				insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
				[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
				Values(@documentid,@VATAccount,@BillDate,@VATAmount,0,@grnid,@DOCTYPE,'Open GRN',@uniqueid,getdate())  
				Insert Into #TempBackdatedgrnbillcancellation(AccountID) Values(@VATAccount) 
			End

			insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
			[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber],[CreationTime])
			Values(@documentid,@BILLSPAYABLE,@BillDate,0,@value,@grnid,@DOCTYPE,'Open GRN',@uniqueid,getdate())  
			Insert Into #TempBackdatedgrnbillcancellation(AccountID) Values(@BILLSPAYABLE) 
		End
	End
FETCH NEXT FROM scanGRN INTO @grnid	
End
CLOSE scanGRN
DEALLOCATE scanGRN
Drop Table #TempGRNID

If @BackDate Is Not Null  
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
	Select AccountID From #TempBackdatedgrnbillcancellation
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
Drop Table #TempBackdatedgrnbillcancellation

