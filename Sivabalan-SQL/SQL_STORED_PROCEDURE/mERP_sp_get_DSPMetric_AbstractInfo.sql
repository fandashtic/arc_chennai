Create Procedure mERP_sp_get_DSPMetric_AbstractInfo(@PMetricID as int)
AS
Begin
 Select PMCode, Description, CPM_PMID as RefCode, (SubString(Period,1,3) + ' ' +  SubString(Period,5,4)) as PMMonth, 
 Convert(nVarchar(10),CreationDate,103) + N' ' + Convert(nVarchar(8),CreationDate,108) , CGGroups, 
 Case Active When 0 Then N'Inactive' When 1 Then (Case When dbo.stripTimefromDate(GetDate()) - (Day(dbo.stripTimefromDate(GetDate()))- 1) <= Cast('01' + '/' + SubString(Period,1,3) + '/' +  SubString(Period,5,4) as DateTime) Then 'Active' Else 'Expired' End) End
 From tbl_mERP_PMMaster Where PMID = @PMetricID
End
