CREATE Procedure mERP_sp_SendRep_Validation (@RepID int)
As
If Exists(Select 'x' From Reports_To_Upload Where ReportDataID = @RepID)
Select IsNull(SendParamValidate,0) From Reports_To_Upload Where IsNull(Frequency,0) <> 0 And ReportDataID = @RepID
Else
Select ISNULL(SendParamValidate,0) From tbl_mERP_OtherReportsUpload  Where IsNull(Frequency,0) <> 0 And ReportDataID = @RepID
