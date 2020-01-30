Create Procedure mERP_sp_Update_InvProcess_XMLAck(@RecdInvID int, @Status Int)
As
Begin
  Update tbl_mERP_RecdDocAck Set ProcessAckStatus = @Status, ProcessAckDateTime =GetDate() 
  Where DocTrackID = (Select Top 1 IsNull(RecdXMLAckDocID,0) as ID From InvoiceAbstractReceived Where InvoiceID = @RecdInvID)
  And IsNull(ProcessAckStatus,0) = 0
End
