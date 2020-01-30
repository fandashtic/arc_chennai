CREATE Function GetReportParameters_ClosingStk_DAILY(@REPORT VarChar(250))        
RETURNS @Parameters Table(ParameterID int,GivenDate DateTime)        
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
    
  Update @Parameters       
  Set GivenDate = (Select Cast(ParameterValue as datetime) From ReportParameters Where ParameterID = @ParameterID and ParameterName = 'Date')       
  Where ParameterID = @ParameterID        
  
  Fetch Next From GetParameters Into @ParameterID        
 End        
 Close GetParameters        
 DeAllocate GetParameters        
 RETURN        
 END

