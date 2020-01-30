CREATE PROCEDURE sp_Insert_Customers(@QuotationID INT, @CustomerID nVarchar(50))
AS
INSERT INTO [QuotationCustomers](QuotationID, CustomerID) Values(@QuotationID, @CustomerID)



