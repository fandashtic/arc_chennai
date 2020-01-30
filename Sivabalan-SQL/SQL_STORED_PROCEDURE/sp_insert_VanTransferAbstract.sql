CREATE PROCEDURE sp_insert_VanTransferAbstract (
					    @DocumentDate DateTime,
						@TransferType int,				
						@FromVanID  int,
						@ToVanID    int,
					    @CreationDate datetime,
						@UserName   nvarchar(100),
						@Value decimal(18,6)
						)
as
Declare @DocumentID int
Declare @DocPrefix nvarchar(255)
Select @DocPrefix = Prefix From VoucherPrefix Where TranID = 'VAN LOADING STATEMENT'

Begin Tran
	Update DocumentNumbers Set DocumentID =  DocumentID + 1 Where DocType = 14
	Select @DocumentID = DocumentID - 1 From DocumentNumbers Where DocType = 14
Commit Tran

Insert into VanTransferAbstract (
	DocumentID,
	DocPrefix,
	DocumentDate,
	TransferType,
	FromVanID,
	ToVanID,
	CreationDate,
	UserName,
	Value)  
Values	(
	@DocumentID,
	@DocPrefix,
	@DocumentDate,
	@TransferType,
	@FromVanID,
	@ToVanID,
	@CreationDate,
	@UserName,
	@Value)  
select @@Identity,@DocumentID


