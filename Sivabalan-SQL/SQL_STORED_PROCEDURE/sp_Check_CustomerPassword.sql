Create Procedure sp_Check_CustomerPassword(@CustomerID nVarchar(50), @Password nVarchar(50))
as
IF EXISTS(SELECT * FROM Customer WHERE CustomerID = @CustomerID And IsNull(Customer_Password,N'') = @Password)
BEGIN
SELECT 1
END
ELSE
BEGIN
SELECT 0
END



