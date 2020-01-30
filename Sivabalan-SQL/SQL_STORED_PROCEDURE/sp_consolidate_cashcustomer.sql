
CREATE PROCEDURE sp_consolidate_cashcustomer(@CUSTOMER nvarchar(250),
				    @ADDRESS nvarchar(255),
				    @DOB datetime)
AS
IF NOT EXISTS (SELECT CustomerID FROM Cash_Customer WHERE CustomerName = @CUSTOMER)
BEGIN
Insert Cash_Customer(CustomerName, Address, DOB)
VALUES(@CUSTOMER, @ADDRESS, @DOB)
END

