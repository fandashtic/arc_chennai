CREATE PROCEDURE sp_create_ClaimsNote
		 (@VendorID NVARCHAR(15), 
		  @ClaimDate DATETIME,
		  @ClaimType INT,
		  @ClaimValue Decimal(18,6) = 0,
		  @DocReference nvarchar(50),
		  @GSK_Flag Integer = 0,
		  @GVNO nVarchar(255) = Null)
AS
DECLARE @DocumentID int



SELECT @DocumentID = DocumentID FROM DocumentNumbers WHERE DocType = 7
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 7

If @GSK_Flag = 1 
INSERT INTO 
CLAIMSNOTE      (VendorID ,
		 ClaimDate,
		 DocumentID,
		 ClaimType,
		 ClaimValue,
		 DocumentReference,
		 Balance)
VALUES		
		(@VendorID ,
		 @ClaimDate,
		 @DocumentID,
		 @ClaimType,
		 @ClaimValue,
		 @DocReference,
		 0)
Else
INSERT INTO 
CLAIMSNOTE      (VendorID ,
		 ClaimDate,
		 DocumentID,
		 ClaimType,
		 ClaimValue,
		 DocumentReference,
		 Balance, 
		 Remarks)
VALUES		
		(@VendorID ,
		 @ClaimDate,
		 @DocumentID,
		 @ClaimType,
		 @ClaimValue,
		 @DocReference,
		 @ClaimValue,@GVNO)
SELECT @@IDENTITY, @DocumentID

