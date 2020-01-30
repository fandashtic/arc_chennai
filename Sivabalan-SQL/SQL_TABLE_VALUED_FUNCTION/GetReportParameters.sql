CREATE Function GetReportParameters(@COMPANY nvarchar(50), @REPORT nvarchar(250))
RETURNS @Parameters Table(ParameterID int, FromDate datetime, ToDate datetime)
AS
BEGIN
DECLARE @ParameterID int
DECLARE GetParameters CURSOR STATIC FOR
Select Distinct ReportParameters.ParameterID From Reports, ReportParameters
Where ReportName = @REPORT And CompanyID Like @COMPANY And Reports.ParameterID = ReportParameters.ParameterID
Open GetParameters
Fetch From GetParameters Into @ParameterID
While @@FETCH_STATUS = 0
Begin
	Insert Into @Parameters(ParameterID) Values(@ParameterID)
	Update @Parameters Set FromDate = (Select Cast(ParameterValue as datetime) From ReportParameters 
	Where ParameterID = @ParameterID and ParameterName = 'From Date') Where ParameterID = @ParameterID
	Update @Parameters Set ToDate = (Select Cast(ParameterValue as datetime) From ReportParameters 
	Where ParameterID = @ParameterID and ParameterName = 'To Date') Where ParameterID = @ParameterID
	Fetch Next From GetParameters Into @ParameterID
End
Close GetParameters
DeAllocate GetParameters
RETURN
END

