Create Procedure sp_update_AmendGRN    (@GRNID Int,
					@GRNIDRef Int,
					@DocumentIDRef nvarchar(255))
As
Declare @DocumentID int
select @DocumentID=DocumentId from grnabstract where grnID=@GRNIDRef
Update GRNAbstract Set GRNStatus = GRNStatus | 16, GRNIDRef = @GRNIDRef,
DocumentIDRef = @DocumentIDRef,DocumentID=@DocumentID Where GRNID = @GRNID
--For AmendGRN  DocumentID Need not be Incremented and this is handled in sp_save_grnabstract
--so redecrementing it here in this procedure is not needed.
--BEGIN TRAN  
--UPDATE DocumentNumbers SET DocumentID = DocumentID - 1 WHERE DocType = 5  
--COMMIT TRAN 



