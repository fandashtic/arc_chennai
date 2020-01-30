Create Procedure  mERP_sp_Get_Exchange_AckInfoXML  
as  
Begin  
 Select "CompanyID" = RegisteredOwner,  "Version" = Version,
 (Select "FileName" = XMLDocName , "Status" = 'Sent', "Date" = Convert(nVarchar(20),CreationDate,113)  From tbl_merp_UploadReportTracker as RPTACKREQ   
         Where IsNull(AckStatus,0) & 132 <> 132 And IsNull(AckStatus,0) & 192 <> 192 For XML Auto, Type),  
 (Select "FileName" = IsNull(XMLDocName,'') , "Status" = 'Sent', "Date" = Convert(nVarchar(20),CreationDate,113)  From tbl_Merp_RFAXmlStatus as RPTACKREQ
         Where IsNull(XMLDocName,'') <> '' And IsNull(AckStatus,0) & 132 <> 132 And IsNull(AckStatus,0) & 192 <> 192 For XML Auto, Type),
 (Select "FileName" = XMLDocName, "Status" = Case ProcessAckStatus When 0 Then 'Received' When 1 Then 'Processed' When 64 Then 'Rejected' When 128 Then 'Failed' End,   
      "Date" = Case ProcessAckStatus When 0 Then  Convert(nVarchar(20),CreationDateTime,113) Else Convert(nVarchar(20),ProcessAckDateTime,113) End   
  From tbl_mERP_RecdDocAck as RECDACK Where isnull(RecdAckStatus,0) = 0 FOR XML Auto,Type)  
 From SetUp as ACKINFO
For XML Auto,Root('Root')
End
