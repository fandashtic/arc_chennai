Create Procedure mERP_sp_Insert_XMLAck_DocDwnldInfo(@XMLFileName nVarchar(510))
as
Begin
If Not exists(Select DocTrackID from tbl_mERP_RecdDocAck Where XMLDocName = @XMLFileName And RecdAckStatus = 0)
  Begin
  Insert into tbl_mERP_RecdDocAck(XMLDocName) Values (@XMLFileName)
  End
End
