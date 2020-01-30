CREATE FUNCTION LocateReport(@COMPANY nvarchar(50), @REPORT nvarchar(250), @FROMDATE datetime, @TODATE datetime)
RETURNS INT
AS
BEGIN
DECLARE @ReportID int
IF @TODATE Is Null
	BEGIN
	Select @ReportID = Max(ReportID) From Reports Where ReportName = @REPORT And CompanyID = @COMPANY And dbo.StripDateFromTime(ReportDate) = dbo.StripDateFromTime(@FROMDATE)
	END
ELSE
	BEGIN
	Select @ReportID = Max(ReportID) From Reports Where ReportName = @REPORT And CompanyID = @COMPANY 
	And ParameterID in (Select ParameterID From dbo.GetReportParameters(@COMPANY, @REPORT) 
	Where FromDate = dbo.StripDateFromTime(@FROMDATE) And ToDate = dbo.StripDateFromTime(@TODATE))
	END
RETURN  @ReportID
END
