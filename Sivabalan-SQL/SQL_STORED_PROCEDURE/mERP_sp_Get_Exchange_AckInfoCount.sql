Create Procedure mERP_sp_Get_Exchange_AckInfoCount  
As  
Begin  
  Select Sum(IsNull(FileCount,0)) From  
   (Select "FileCount" = Count(XMLDocName)  from tbl_merp_UploadReportTracker Where IsNull(AckStatus,0) & 132 <> 132 And IsNull(AckStatus,0) & 192 <> 192
    Union ALL  
    Select "FileCount" = Count(XMLDocName) from tbl_mERP_RecdDocAck Where isnull(RecdAckStatus,0) = 0
    Union All
    Select Count(XMLDocName) From tbl_Merp_RFAXmlStatus Where IsNull(XMLDocName,'') <> '' And IsNull(AckStatus,0) & 192 <> 192)A  
End
