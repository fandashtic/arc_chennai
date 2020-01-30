
Create Procedure dbo.FSU_sp_GetRelStatReportParm
As 
Begin

Select "ReportDataID" = ReportData.ID, "FromDate" =IsNull(A.FromDate,''), "ToDate" = IsNull(A.ToDate,'') ,ActionData,DetailCommand,ForwardParam,  
"ParameterId"=B. ParameterId ,  
"DetailProcName"=Case Detailcommand When 0 Then N''  
Else (Select Rep.Actiondata From Reportdata Rep Where Rep.ID=Reportdata.Detailcommand) end,  
Node,"ReportID"=B.ReportID 
From ReportData , tblFSUSetup A , Reports_to_Upload B
Where ReportData.Action=1 and ReportData.ID=B.ReportDataID
And B.ReportName = 'Release Status Report'

End
