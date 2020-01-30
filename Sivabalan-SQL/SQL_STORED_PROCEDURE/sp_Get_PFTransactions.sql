CREATE Procedure sp_Get_PFTransactions
As
Select TransactionName, PrintID From CustomPrinting
Where DefaultFileName = 1
