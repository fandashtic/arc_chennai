IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'PrintingHistory')
BEGIN
	DROP TABLE PrintingHistory
END
GO
Create Table PrintingHistory
(
	DocumentId Nvarchar(255),
	PrintingDate DateTime,
	DocumentType Nvarchar(255),
	PrintedBy INT Default 0,
	PrintedSystem Nvarchar(255) Default Null
)
GO
