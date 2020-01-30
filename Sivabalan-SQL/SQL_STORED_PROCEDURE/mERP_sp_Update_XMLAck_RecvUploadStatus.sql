Create Procedure mERP_sp_Update_XMLAck_RecvUploadStatus(@XMLFileName nVarchar(510), @Status Int)
as
Begin
  Declare @DocType as nvarchar(50)
  Declare @Delimiter as Char(1)
  Set @Delimiter = N'-'
  
  /*Get Doc Type*/
  Select * into #tmpDocSplitup from dbo.sp_splitin2rows_withID( @XMLFileName, @Delimiter)
  Select @DocType = ItemValue from #tmpDocSplitup Where RowID = 4 
  Drop table #tmpDocSplitup

  If @DocType = N'RFA'
  Begin
    Update tbl_Merp_RFAXmlStatus Set AckStatus = @Status , AcknowledgeDate = Getdate() Where IsNull(XMLDocName,'') = @XMLFileName
  End 
  Else
  Begin
    Update tbl_mERP_RecdDocAck Set RecdAckStatus = @Status , RecdAckDateTime = Getdate() Where XMLDocName = @XMLFileName
  End
End
