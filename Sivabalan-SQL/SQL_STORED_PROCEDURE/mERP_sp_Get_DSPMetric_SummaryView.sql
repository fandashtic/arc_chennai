Create Procedure mERP_sp_Get_DSPMetric_SummaryView(@MetricCode nVarchar(15), @FromMonth DateTime, @ToMonth DateTime, @Status Int)
As
Begin
  Select PMM.PMCode, PMM.Description, SubString(PMM.Period,1,3) + N' ' +  SubString(PMM.Period,5,4) as Period,
  Case PMM.Active When 1 Then (Case When dbo.stripTimefromDate(GetDate()) - (Day(dbo.stripTimefromDate(GetDate()))- 1) <= Cast('01' + '/' + SubString(Period,1,3) + '/' +  SubString(Period,5,4) as DateTime) Then 'Active' Else 'Expired' End) 
                  Else  N'Inactive' End as Status, PMM.CGGroups, PMM.PMID
  From tbl_mERP_PMMaster PMM
  Where PMCode = Case @MetricCode When N'%' Then PMCode Else @MetricCode End
    And Active = Case @Status When 0 Then Active When 1 Then 1 When 2 Then 0 End
	And Not ((Status & 2) = 2 And (Status & 1) = 1) 
    And Cast('01' + '/' + SubString(Period,1,3) + '/' +  SubString(Period,5,4) as DateTime) >= @FromMonth
    And Cast('01' + '/' + SubString(Period,1,3) + '/' +  SubString(Period,5,4) as DateTime) <= @ToMonth
  Order by PMM.PMCode, Cast('01' + '/' + SubString(Period,1,3) + '/' +  SubString(Period,5,4) as DateTime)
End
