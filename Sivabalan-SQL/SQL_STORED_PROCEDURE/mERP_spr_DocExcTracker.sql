CREATE Procedure mERP_spr_DocExcTracker(@FromDate as datetime, @ToDate as datetime)
As
Begin
 Create Table #TempResults
 ([ID] Int Identity(1,1), 
  [FromDate] nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
  [ToDate] nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
  [FileType] nVarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,
  [FileName] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
  [Activity] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
  [Generated] nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
  [Uploaded  - Download] nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS,
  [Acknowledgement Status] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS
 )	 
 Insert Into #TempResults([FromDate], [ToDate], [FileType], [FileName],[Activity],[Generated],[Uploaded  - Download],[Acknowledgement Status])
 Select 
 Convert(nVarchar(10),CreationDateTime,103) as 'FromDate',
 Convert(nVarchar(10),CreationDateTime,103) as 'ToDate',
 (Substring(xmldocname,(charindex(N'-',xmldocname))+9,(charIndex('-',(select Substring(xmldocname,charIndex('-',xmldocname)+9, len(xmldocname)))))-1)) as 'FileType',
 XMLDocName, N'Download', 
 convert(nvarchar(10),CreationDateTime,103) + ' ' + convert(nvarchar(10),CreationDateTime,108) as 'Generated', 
 convert(nvarchar(10),CreationDateTime,103) + ' ' + convert(nvarchar(10),CreationDateTime,108) 'DocDownload',
 Case RecdAckStatus 
 When 0 Then N'Acknowledgement Not uploaded' 
 When 1 Then N'Acknowledgement uploaded'
 Else N'Acknowledgement Not uploaded' End
 From tbl_mERP_RecdDocAck
 Where CreationDateTime between @FromDate and @ToDate
 Union
 Select 
  Convert(nVarchar(10),ReportFromDate,103) as 'FromDate',
  Convert(nVarchar(10),ReportToDate,103) as 'ToDate',
  RD.Node as 'FileType',
  URT.XMLDocName, N'Upload', 
 convert(nvarchar(10),URT.CreationDate,103) + ' ' + convert(nvarchar(10),URT.CreationDate,108) as 'Generated', 
 convert(nvarchar(10),URT.UploadDate,103) + ' ' + convert(nvarchar(10),URT.UploadDate,108) 'DocUpload',
 Case  
  When Isnull(URT.Ackstatus,0) & 1 = 1 and Isnull(URT.Ackstatus,0) & 64 = 0 and Isnull(URT.Ackstatus,0) & 132 = 0 and Isnull(URT.Ackstatus,0) & 128 = 0 Then N'Uploaded to Central' 
  When Isnull(URT.Ackstatus,0) & 1 = 1 and Isnull(URT.Ackstatus,0) & 128 = 128 and Isnull(URT.Ackstatus,0) & 132 = 128 and Isnull(URT.Ackstatus,0) & 192 = 128 Then N'Received at Central'
  When Isnull(URT.Ackstatus,0) & 1 = 1 and Isnull(URT.Ackstatus,0) & 128 = 128 and Isnull(URT.Ackstatus,0) & 132 = 132 Then N'Processed at Central'
  When Isnull(URT.Ackstatus,0) & 64 = 64 OR Isnull(URT.Ackstatus,0) & 192 = 192 Then N'Failed to Process at Central'
  When Isnull(URT.Ackstatus,0) & 256 = 256 Then N'Failed to Upload'
  Else N'Forum Central Upload pending'  

 End
 From 
     tbl_merp_UploadReportTracker URT, ReportData RD, 
     (Select 2 As "Reporttype",ReportID, ReportDataID from tbl_mERP_OtherReportsUpload Union
      Select 1 As "Reporttype", ReportID, ReportDataID from Reports_to_Upload) UR
 Where RD.ID = Case IsNull(URT.ARUMode,0) When 0 Then UR.ReportDataID  Else URT.ReportID End
  And URT.ReportID = Case IsNull(URT.ARUMode,0) When 0 Then UR.ReportID Else UR.ReportDataID End
/* Document tracker report did not show PLR report when it is sent from report viewer. (The report was hidden report previously)
So, Report Type will not be compared any longer.
*/
  And URT.Reporttype = Case IsNull(URT.ARUMode,0) When 1 Then URT.Reporttype Else UR.Reporttype End
  And URT.CreationDate between @FromDate and @ToDate
 Union All
 Select 
  Convert(nVarchar(10),CreationDate,103) as 'FromDate',
  Convert(nVarchar(10),CreationDate,103) as 'ToDate',
  'RFA' as 'FileType',
  IsNull(XMLDocName,'') as XMLDocName, N'Upload', 
  convert(nvarchar(10),CreationDate,103) + ' ' + convert(nvarchar(10),CreationDate,108) as 'Generated', 
  convert(nvarchar(10),UploadDate,103) + ' ' + convert(nvarchar(10),UploadDate,108) 'DocUpload',
 Case  
  When Isnull(Ackstatus,0) & 1 = 1 and Isnull(Ackstatus,0) & 64 = 0 and Isnull(Ackstatus,0) & 132 = 0 and Isnull(Ackstatus,0) & 128 = 0 Then N'Uploaded to Central' 
  When Isnull(Ackstatus,0) & 1 = 1 and Isnull(Ackstatus,0) & 128 = 128 and Isnull(Ackstatus,0) & 132 = 128 and Isnull(Ackstatus,0) & 192 = 128 Then N'Received at Central'
  When Isnull(Ackstatus,0) & 1 = 1 and Isnull(Ackstatus,0) & 128 = 128 and Isnull(Ackstatus,0) & 132 = 132 Then N'Processed at Central'
  When Isnull(Ackstatus,0) & 64 = 64 OR Isnull(Ackstatus,0) & 192 = 192 Then N'Failed to Process at Central'  
  Else N'Forum Central Upload pending'  
 End
 From tbl_Merp_RFAXmlStatus 
 Where CreationDate between @FromDate and @ToDate

select * from #TempResults order by [Generated]

End
