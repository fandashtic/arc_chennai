CREATE procedure sp_acc_updatcollectionabstract(@DocumentDate datetime,
					@Value float,
					@ChequeNumber integer,
					@ChequeDate datetime,
					@BankCode nvarchar(20),
					@BranchCode nvarchar(20))
					
as
Declare @DocID nvarchar(50)
Declare @DocPrefix nvarchar(50)
Declare @RETAIL_CUSTOMER Int


Set @RETAIL_CUSTOMER = 93

Begin Tran
	select @DocID = DocumentID from DocumentNumbers where Doctype = 57
	update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 57
Commit Tran

select @DocPrefix = Prefix from VoucherPrefix
where TranID = N'FA COLLECTIONS'

SET @DocID = @DocPrefix + @DocID

insert into Collections(FullDocID,
			DocumentDate,
			Value,
			Balance,
			PaymentMode,
			ChequeNumber,
			ChequeDate,
			Others,
			BankCode,
			BranchCode)
values
		       (@DocID,
			@DocumentDate,
			@Value,
			0,
			1,
			@ChequeNumber,
			@ChequeDate,
			@RETAIL_CUSTOMER,
			@BankCode,
			@BranchCode)

select @@IDENTITY, @DocID











