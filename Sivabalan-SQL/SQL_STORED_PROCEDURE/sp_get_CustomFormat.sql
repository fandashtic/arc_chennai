Create Procedure sp_get_CustomFormat (@TransactionName nvarchar(255))
As
Select PrintID, PrintFileName, DefaultFileName From CustomPrinting
Where TransactionName = @TransactionName
