




CREATE Procedure sp_acc_insertdeposits(@DepositDate datetime,
					@BankID integer,
					@Value decimal(18,6),
					@StaffID Integer)
As
Declare @DocID nvarchar(50)
Declare @CHEQUEDEPOSIT INT
Set @CHEQUEDEPOSIT=5
Begin Tran
select @DocID = DocumentID from DocumentNumbers where DocType = 25
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 25
Commit Tran
SET @DocID = dbo.getvoucherprefix('Deposits') + @DocID
insert into Deposits(TransactionType,
			DepositDate,
			FullDocID,
			AccountID,
			Value,
			StaffID)
values
		       (@CHEQUEDEPOSIT,
			@DepositDate,
			@DOCID,	
			@BankID,			
			@Value,
			@StaffID)
select @@IDENTITY, @DocID





