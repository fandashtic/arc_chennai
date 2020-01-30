CREATE Procedure mERP_sp_SendRep_ParamValidation (@RepID int,@Flag Int=0)
As
-- @Flag Used for Upload Report identification
Declare @ReportName nVarchar(255)

If @RepID = 1089
Set @Flag = 1

If @Flag = 1
Begin
IF Exists (Select 'x' From Reports_To_Upload Where ReportDataID = @RepID)
Select Parameter_Name From ReportParameters_Upload Where ParameterID = (Select ParameterID From Reports_To_Upload Where ReportDataID = @RepID)
Else
Select Parameter_Name From ReportParameters_Upload Where ParameterID = (Select ParameterID From tbl_mERP_OtherReportsUpload Where ReportDataID = @RepID)
End
Else
Begin
Select ParameterName From ParameterInfo Where ParameterID = (Select Parameters From ReportData Where [ID] = @RepID)
End
