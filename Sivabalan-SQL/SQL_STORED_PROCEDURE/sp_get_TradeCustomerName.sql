CREATE Procedure sp_get_TradeCustomerName(@CustName as nvarchar(255))    
As    
Select Company_Name from Customer 
Where CustomerCategory not in (4, 5) and Company_Name =@CustName   

