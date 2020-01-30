Create Procedure mERP_sp_GenerateRecdAck_XML(@XMLDocID int)
As
Begin
  Select XMLDocName, Case ProcessAckStatus When 0 Then 'Received' When 1 Then 'Processed' When 64 Then 'Rejected' When 128 Then 'Failed' End as Status, 
  Case ProcessAckStatus When 0 Then  Convert(nVarchar(20),CreationDateTime,113) Else Convert(nVarchar(20),ProcessAckDateTime,113) End as ProcessDate
  From tbl_mERP_RecdDocAck as ACK Where DocTrackID = @XMLDocID  FOR XML Auto, Root('Root')
End
