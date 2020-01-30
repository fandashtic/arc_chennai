Create Procedure sp_get_PrintFormat (@TransactionType nvarchar(255))
As
Select PrintID, PrintFileName From CustomPrinting
Where TransactionName = @TransactionType
