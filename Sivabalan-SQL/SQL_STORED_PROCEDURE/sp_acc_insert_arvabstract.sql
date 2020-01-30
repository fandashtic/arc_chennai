CREATE procedure sp_acc_insert_arvabstract(@ARVDate datetime,
					   @PartyAccountID Int,
					   @Value Float,
					   @ARVemarks nvarchar(4000),
					   @ApprovedBy integer,
					   @DocRef nVarchar(255),
					   @TotalSalesTax Float,
					   @DocSerialType nvarchar(100) = NULL)
As
Declare @DocID nvarchar(50)
Begin Tran
 select @DocID = DocumentID from DocumentNumbers where Doctype = 54
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 54
Commit Tran

insert into ARVAbstract(ARVID,
			ARVDate,
			PartyAccountID,
			Amount,
			ARVRemarks,
			ApprovedBy,
			Balance,
			DocRef,
			TotalSalesTax,
			CreationTime,
			DocSerialType)
values
			(@DocID,
			@ARVDate,
			@PartyAccountID,
			@Value,
			@ARVemarks,
			@ApprovedBy,
			@Value,
			@DocRef,
			@TotalSalesTax,
			getdate(),
			@DocSerialType)
Set @DocID=dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + @DocID
Select @@IDENTITY, @DocID
