Create Procedure sp_get_Report_Disclaimer (@ID int)
As
Select IsNull(Header, N''), IsNull(Footer, N'') From ReportData Where ID = @ID
