Create Function GetReportParameters_DSR(@REPORT nvarchar(250))    
RETURNS @Parameters Table(ParameterID int, FromDate datetime)    
AS    
BEGIN    
DECLARE @ParameterID int    
DECLARE GetParameters CURSOR STATIC FOR    
Select Distinct ReportParameters.ParameterID From Reports, ReportParameters    
Where ReportName = @REPORT And Reports.ParameterID = ReportParameters.ParameterID    
Open GetParameters    
Fetch From GetParameters Into @ParameterID    
While @@FETCH_STATUS = 0    
Begin    
 Insert Into @Parameters(ParameterID) Values(@ParameterID)    
 Update @Parameters Set FromDate = (Select Cast(ParameterValue as datetime) From ReportParameters     
 Where ParameterID = @ParameterID and ParameterName = 'FromDate') Where ParameterID = @ParameterID    
 Fetch Next From GetParameters Into @ParameterID    
End    
Close GetParameters    
DeAllocate GetParameters    
RETURN    
END    
    
