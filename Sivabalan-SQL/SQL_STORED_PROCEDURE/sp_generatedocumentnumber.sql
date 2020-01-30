CREATE PROCEDURE sp_generatedocumentnumber(@doctype int = 51)
AS
DECLARE @DocumentID int

BEGIN TRAN
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = @doctype
SELECT @DocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = @doctype
COMMIT TRAN
Select @DocumentID
