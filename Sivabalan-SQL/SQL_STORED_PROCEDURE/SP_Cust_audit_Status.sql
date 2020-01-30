CREATE PROCEDURE SP_Cust_audit_Status
@CustomerID nvarchar(20)
AS
BEGIN
Select Active From Customer
Where  Customer.CustomerID = @CustomerID
END
