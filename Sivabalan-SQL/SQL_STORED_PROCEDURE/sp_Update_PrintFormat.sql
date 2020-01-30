Create Procedure sp_Update_PrintFormat (@TransactionName nvarchar(255),
					@OldFileName nvarchar(255),
					@PrintFileName nvarchar(255))
As
Update CustomPrinting Set PrintFileName = @PrintFileName 
Where TransactionName = @TransactionName And PrintFileName = @OldFileName
