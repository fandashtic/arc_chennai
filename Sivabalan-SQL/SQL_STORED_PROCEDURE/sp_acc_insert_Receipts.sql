




CREATE procedure sp_acc_insert_Receipts(@DocumentDate datetime,
					@Value float,
					@Balance float,
					@PaymentMode integer,
					@ChequeNumber integer,
					@ChequeDate datetime,
					@DocPrefix nvarchar(50),
					@BankCode nvarchar(10),
					@BranchCode nvarchar(10),
					@OtherID integer,
					@Denomination nVarchar(250))

as
Declare @DocID nvarchar(50)


Begin Tran
select @DocID = DocumentID from DocumentNumbers where Doctype = 12
update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 12
Commit Tran
SET @DocID = @DocPrefix + @DocID
insert into Collections(FullDocID,
			DocumentDate,
			Value,
			Balance,
			PaymentMode,
			ChequeNumber,
			ChequeDate,
			BankCode,
			BranchCode,
			Others,
			Denomination)

values
		       (@DocID,
			@DocumentDate,
			@Value,
			@Balance,
			@PaymentMode,
			@ChequeNumber,
			@ChequeDate,
			@BankCode,
			@BranchCode,
			@OtherID,
			@Denomination)


select @@IDENTITY, @DocID








