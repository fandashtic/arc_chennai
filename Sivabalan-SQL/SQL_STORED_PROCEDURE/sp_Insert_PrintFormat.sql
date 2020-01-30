Create Procedure sp_Insert_PrintFormat (@TransactionName nvarchar(255),
					@PrintFileName nvarchar(255))
As
Insert Into CustomPrinting (TransactionName, PrintFileName, DefaultFileName)
Values(@TransactionName, @PrintFileName, 0)
