Create Procedure mERP_sp_Update_XMLAck_ProcessUploadStatus(@XMLFileName nVarchar(510), @Status Int)
as
Begin
Update tbl_mERP_RecdDocAck Set ProcessAckStatus = @Status , ProcessAckDateTime = Getdate() Where XMLDocName = @XMLFileName
End
