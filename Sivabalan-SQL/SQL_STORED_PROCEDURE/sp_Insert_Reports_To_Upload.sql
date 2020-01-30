CREATE Procedure sp_Insert_Reports_To_Upload (@ReportName nvarchar(255),
					  	@Frequency int,
						@ParameterID int,
						@CompanyID int,
						@ReportDataID int,
						@DayOfMonthWeek int)
As
Insert Into Reports_To_Upload (ReportName, Frequency, ParameterID, CompanyID, ReportDataID, 
DayOfMonthWeek) Values (@ReportName, @Frequency, @ParameterID, @CompanyID, @ReportDataID,
@DayOfMonthWeek)
