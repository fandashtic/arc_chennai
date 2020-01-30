CREATE Procedure sp_get_TradeCustomer(@CustID as nvarchar(255))  
As  
Select CustomerID from Customer Where CustomerCategory not in (4, 5) and CustomerID = @CustID  


