Create Procedure sp_Insert_ConversionAbstract (	@DocDate datetime,
						@ConversionType int,
						@UserName nvarchar(50),
						@Remarks nvarchar(255) = N'')
As
Declare @DocID int
Declare @DocPrefix nvarchar(50)

Begin Tran
Update DocumentNumbers Set DocumentID = DocumentID + 1 Where DocType = 18
Select @DocID = DocumentID - 1 From DocumentNumbers Where DocType = 18
Commit Tran
Select @DocPrefix = Prefix From VoucherPrefix Where TranID = N'CONVERSION'
Insert into ConversionAbstract (DocumentID,
				DocumentDate,
				ConversionType,
				DocPrefix,
				UserName,
				Remarks)
Values(				@DocID,
				@DocDate,
				@ConversionType,
				@DocPrefix,
				@UserName,
				@Remarks)
Select @@Identity, @DocID
