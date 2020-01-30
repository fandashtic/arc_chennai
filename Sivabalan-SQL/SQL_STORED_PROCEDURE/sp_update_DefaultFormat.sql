Create Procedure sp_update_DefaultFormat (@PrintID Int,
					  @TransactionName nvarchar(255))
As
Update CustomPrinting Set DefaultFileName = 1 Where PrintID = @PrintID And
TransactionName = @TransactionName
Update CustomPrinting Set DefaultFileName = 0 
Where TransactionName = @TransactionName And
PrintID <> @PrintID
