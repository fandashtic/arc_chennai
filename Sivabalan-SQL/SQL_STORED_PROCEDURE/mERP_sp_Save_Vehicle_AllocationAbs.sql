CREATE PROCEDURE mERP_sp_Save_Vehicle_AllocationAbs
(         
    @Van nVarChar(50),
    @VanNumber nVarChar(50),
    @UserName nVarChar(50),
    @OperatingYear nVarChar(10)
)
AS  
Begin

Declare @DOCUMENTID Int
Declare @FullDocID nVarChar(255)
Declare @GSTVoucherPrefix nvarchar(10)

BEGIN TRAN
		UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 108
		Select @DOCUMENTID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 108
		Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'VEHICLE ALLOCATION'
		Select @FullDocID = @GSTVoucherPrefix + Cast(@DOCUMENTID as nvarchar(50))
COMMIT TRAN  

Insert Into VAllocAbstract 
(DocumentID, FullDocID, Van, VanNumber, GenType, OperatingYear, UserName) Values
(@DOCUMENTID, @FullDocID, @Van, @VanNumber, 1, @OperatingYear, @UserName)

Select @@IDENTITY , @FullDocID

End
