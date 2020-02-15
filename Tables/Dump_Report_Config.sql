IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'Dump_Report_Config')
BEGIN
	DROP TABLE Dump_Report_Config
END
GO
Create Table Dump_Report_Config
(
	Id Int Identity(1,1),
	DumpName Nvarchar(255),
	DumpProc Nvarchar(255),
	Active int Default 1 Not Null,
	CreationDate DateTime Default Getdate()
)
GO
Insert into Dump_Report_Config(DumpName, DumpProc) select 'All Customer Outstanding Breakup', 'SP_ARC_CustomerOutstandingBreakup'
GO
